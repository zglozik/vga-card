

module vga_display
   import vga_pkg::*;
#(
   ST_DATA_WIDTH        = FB_PIXEL_WIDTH,
   MM_CSR_START_ADDRESS = 0
)
(
   input  logic clk,
   input  logic reset,
   
   // Avalon ST source interface, one ready cycle per pixel
   output logic                     st_ready,
   input  logic [ST_DATA_WIDTH-1:0] st_data,
   input  logic                     st_startofpacket,
   input  logic                     st_endofpacket,
   input  logic                     st_valid,

   // SDRAM Avalon MM Master signals for prefetcher CSR interface:
   // Word offset 0:
   //    - bit 0: start a new frame when asserted

   output logic                         mm_csr_write,
   output logic [MM_MEM_ADDR_WIDTH-1:0] mm_csr_address,
   output logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata,
   input  logic                         mm_csr_waitrequest,

   // Output RGB values, HSYNC/VSYNC signals
   output logic vga_hs_out,
   output logic vga_vs_out,
   output logic [DISPLAY_CDEPTH-1:0] vga_r,
   output logic [DISPLAY_CDEPTH-1:0] vga_g,
   output logic [DISPLAY_CDEPTH-1:0] vga_b
);
   function automatic [DISPLAY_CDEPTH-1:0] cdepth_fb_to_display(
      input logic [FB_CDEPTH-1:0] rgb
   );
      assert (DISPLAY_CDEPTH == FB_CDEPTH) else $fatal("framebuffer and display color depth must match");
      cdepth_fb_to_display = rgb;

      /*
      if (rgb == '0)
         cdepth_fb_to_display = '0;
      else if (rgb == '1)
         cdepth_fb_to_display = '1;
      else
         cdepth_fb_to_display = rgb << (DISPLAY_CDEPTH - FB_CDEPTH);
      */
   endfunction: cdepth_fb_to_display

   // VGA sync timing and address generation
   logic vga_hs, vga_vs;
   logic addr_x_valid, addr_y_valid;
   
   vga_horiz_fsm vga_horiz_fsm0(
      .clk,
      .reset,
      .vga_hs,
      .addr_x_valid
   );

   vga_vert_fsm vga_vert_fsm0(
      .clk,
      .reset,
      .vga_hs,
      .vga_vs,
      .addr_y_valid
   );

   // Need a pixel in the next cycle when both addr X and Y are valid
   wire framebuffer_rden = addr_x_valid && addr_y_valid;
   
   // Delay hsync/vsync signals by one clock cycle to match RGB values output delay
   always_ff @(posedge clk)
   begin: sync_update
      if (reset) begin
         vga_hs_out <= '1;
         vga_vs_out <= '1;
      end
      else begin
         vga_hs_out <= vga_hs;
         vga_vs_out <= vga_vs;
      end
   end

   // Start a new frame when VSYNC goes low
   logic vga_vs_prev, restart_frame;

   always_ff @(posedge clk)
   begin: start_frame_update
      if (reset)
         vga_vs_prev <= '1;
      else begin
         vga_vs_prev <= vga_vs;
      end
   end
   assign restart_frame = vga_vs_prev && !vga_vs;
   
   // FSM for reading the frame buffer
   typedef enum logic [1:0] {
      RESTART_FRAME, // One cycle state to initialize state for a new frame display
      WAIT_FOR_SOF,  // Pre-read to the start of frame from Avalon ST interface
      READ_FB,       // Read a byte from Avalon ST interface whenever new pixel required
      OUT_OF_SYNC    // Avalon ST fell behind, use default pixel for rest of the frame
   } FBReaderState;
   
   FBReaderState current_state, next_state;

   logic [ST_DATA_WIDTH-1:0] next_data;   // Pre-cache a pixel value from Avalon ST (FB)
   logic                     next_data_valid;

   always_comb
   begin
      next_state = current_state;
      case (current_state)
         RESTART_FRAME:
            if (restart_frame || mm_csr_waitrequest)
               next_state = RESTART_FRAME;
            else
               next_state = WAIT_FOR_SOF;
         WAIT_FOR_SOF:
            if (restart_frame)
               next_state = RESTART_FRAME;
            else if (framebuffer_rden)
               next_state = OUT_OF_SYNC;
            else if (next_data_valid)
               next_state = READ_FB;
         READ_FB:
            if (restart_frame)
               next_state = RESTART_FRAME;
            else if (framebuffer_rden && !next_data_valid)
               next_state = OUT_OF_SYNC;
         OUT_OF_SYNC:
            if (restart_frame)
               next_state = RESTART_FRAME;
      endcase
   end

   always_comb
   begin: restart_frame_command
      if (current_state == RESTART_FRAME) begin
         mm_csr_write     = '1;
         mm_csr_address   = MM_MEM_ADDR_WIDTH'(MM_CSR_START_ADDRESS);
         mm_csr_writedata = 1'b1; 
      end
      else begin
         mm_csr_write     = '0;
         mm_csr_address   = '0;
         mm_csr_writedata = '0;
      end
   end

   always_comb
   begin: frame_buffer_read_enable
      st_ready = '0; // Disable read by default

      if (current_state == WAIT_FOR_SOF) begin
         // Enable read until start of frame found
         st_ready = !next_data_valid;
      end
      else if (current_state == READ_FB) begin
         // Continue read if we will use the currently cached pixel
         st_ready = framebuffer_rden && next_data_valid;
      end
   end

   always_ff @(posedge clk)
   begin: rgb_update
      // Default to black output
      vga_r <= '0;
      vga_g <= '0;
      vga_b <= '0;

      if (reset || current_state == RESTART_FRAME) begin
         next_data       <= '0;
         next_data_valid <= '0;
      end
      else if (current_state == WAIT_FOR_SOF) begin
         if (st_valid && st_startofpacket) begin
            // Start of frame found, save data
            next_data       <= st_data;
            next_data_valid <= '1;
         end
      end
      else if (current_state == READ_FB) begin
         if (framebuffer_rden && next_data_valid) begin
            // Need a new pixel and we have it cached
            vga_r <= cdepth_fb_to_display(next_data[          0+:FB_CDEPTH]);
            vga_g <= cdepth_fb_to_display(next_data[  FB_CDEPTH+:FB_CDEPTH]);
            vga_b <= cdepth_fb_to_display(next_data[2*FB_CDEPTH+:FB_CDEPTH]);

            // Cache the next pixel, if any
            if (st_valid && !st_endofpacket)
               next_data <= st_data;
            else
               next_data_valid <= '0;
         end
      end
   end
   
   always_ff @(posedge clk)
   begin
      if (reset)
         current_state <= OUT_OF_SYNC; // Wait for the sync signal to trigger start of frame
      else
         current_state <= next_state;
   end

endmodule: vga_display
