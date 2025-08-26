
import vga_pkg::*;

module vga_sprite_stream
#(
   MM_ADDR_WIDTH        = MM_MEM_ADDR_WIDTH,
   MM_DATA_WIDTH        = MM_MEM_DATA_WIDTH,
   MM_START_ADDRESS     = 'h400_0000,
   SPRITE_WIDTH         = 48,
   SPRITE_HEIGHT        = 48,
   SPRITE_SIZE          = SPRITE_WIDTH * SPRITE_HEIGHT / 8, // Sprite size in bytes, one bit per pixel
   FIFO_SIZE            = SPRITE_WIDTH / MM_DATA_WIDTH,     // Fifo size in words, one line
   FIFO_SIZE_WIDTH      = $clog2(FIFO_SIZE + 1),
   ST_EMPTY_WIDTH       = $clog2(MM_DATA_WIDTH/8 + 1)
)
(
   input  logic clk,
   input  logic reset,

   // Avalon MM Master signals for reading sprite memory
   output logic                       mm_mem_read,
   output logic [MM_ADDR_WIDTH-1:0]   mm_mem_address,
   output logic [MM_DATA_WIDTH/8-1:0] mm_mem_byteenable,
   input  logic [MM_DATA_WIDTH-1:0]   mm_mem_readdata,
   input  logic                       mm_mem_waitrequest,
   input  logic                       mm_mem_readdatavalid,

   // Avalon MM Slave signals for CSR interface
   input  logic                         mm_csr_write,
   input  logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address,
   input  logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata,
   output logic                         mm_csr_waitrequest,
   
   // Avalon ST source interface, one beat for each pixel of the frame.
   input  logic                      st_ready,
   output logic [MM_DATA_WIDTH-1:0]  st_data,
   output logic                      st_startofpacket,
   output logic                      st_endofpacket,
   output logic [ST_EMPTY_WIDTH-1:0] st_empty,
   output logic                      st_valid
);
   localparam MM_MAX_PENDING_READS = 7;   // Must match the Avalon IP configuration

   localparam MM_FIFO_DATA_WIDTH = $bits(prefetcher_fifo_item_t);

   // This module will:
   // - read sprite pixels from memory into a FIFO, one word (multiple pixels) per fifo item
   // - keep track of which (x, y) pixel we need to produce on Avalon source interface
   // - Depending on whether (x, y) is in the sprite:
   //    - Output black if it is outside
   //    - Output black or white if it is inside, depending on the next bit read from sprite fifo

   // Process CSR requests, changes will take effect for the next frame, store pending and current settings
   typedef struct {
      logic enabled;
      logic [MM_ADDR_WIDTH-1:0]    base_address;

      // Top-left corner of sprite
      logic [COORD_DATA_WIDTH-1:0] sprite_x1;
      logic [COORD_DATA_WIDTH-1:0] sprite_y1;

      // Bottom-right corner of sprite
      logic [COORD_DATA_WIDTH-1:0] sprite_x2;
      logic [COORD_DATA_WIDTH-1:0] sprite_y2;

      logic [COLOR_DATA_WIDTH-1:0] color;
   } csr_data_t;

   csr_data_t csr_pending, csr_current;
   
   assign mm_csr_waitrequest = '0;

   always_ff @(posedge clk)
   begin: csr_pending_update
      if (reset) begin
         csr_pending <= '{
            enabled     : '0,
            base_address: MM_START_ADDRESS,
            sprite_x1   : '0,
            sprite_y1   : '0,
            sprite_x2   : COORD_DATA_WIDTH'(SPRITE_WIDTH) - 1'b1,
            sprite_y2   : COORD_DATA_WIDTH'(SPRITE_HEIGHT) - 1'b1,
            color       : '1,
            default     : '0
         };
      end
      else if (mm_csr_write) begin
         case (mm_csr_address)
            VGA_SPRITE_STREAM_ENABLE_REG:
               begin
                  csr_pending.enabled <= mm_csr_writedata[0];
               end
            VGA_SPRITE_STREAM_BASE_ADDRESS_REG:
               begin
                  csr_pending.base_address <= mm_csr_writedata;
               end
            VGA_SPRITE_STREAM_XY_REG:
               begin
                  coordinate_t top_left;
                  top_left = mm_csr_writedata;
                  // Make sure sprite is within frame
                  top_left.x = COORD_DATA_WIDTH'(WIDTH  <= top_left.x + SPRITE_WIDTH  ? WIDTH - SPRITE_WIDTH   : top_left.x);
                  top_left.y = COORD_DATA_WIDTH'(HEIGHT <= top_left.y + SPRITE_HEIGHT ? HEIGHT - SPRITE_HEIGHT : top_left.y);

                  csr_pending.sprite_x1 <= top_left.x;
                  csr_pending.sprite_y1 <= top_left.y;
                  csr_pending.sprite_x2 <= top_left.x + COORD_DATA_WIDTH'(SPRITE_WIDTH) - 1'b1;
                  csr_pending.sprite_y2 <= top_left.y + COORD_DATA_WIDTH'(SPRITE_HEIGHT) - 1'b1;
               end
            VGA_SPRITE_STREAM_COLOR_REG:
               begin
                  color_t color;
                  color = mm_csr_writedata;
                  csr_pending.color <= color.color;
               end
            default: ; // no-op
         endcase
      end
   end

   wire restart_frame = mm_csr_write && mm_csr_address == VGA_STREAM_RESTART_REG && mm_csr_writedata[0];

   // Set up memory prefetch buffer for sprite and prefetch module
   logic                          fifo_rden;
   logic [MM_FIFO_DATA_WIDTH-1:0] fifo_rddata;
   logic                          fifo_rddata_valid;

   logic                          fifo_wren;
   logic [MM_FIFO_DATA_WIDTH-1:0] fifo_wrdata;
   logic [FIFO_SIZE_WIDTH-1:0]    fifo_num_free;

   fifo #(
      .SIZE(FIFO_SIZE),
      .DATA_WIDTH(MM_FIFO_DATA_WIDTH),
      .SIZE_WIDTH(FIFO_SIZE_WIDTH)
   ) fifo_0(
      .clk,
      .reset,
      .rden(fifo_rden),
      .rddata(fifo_rddata),
      .rddata_valid(fifo_rddata_valid),
      .wren(fifo_wren),
      .wrdata(fifo_wrdata),
      .num_free(fifo_num_free)
   );

   logic sprite_prefetch_start;

   vga_frame_buffer_prefetch #(
      .MM_DATA_WIDTH(MM_DATA_WIDTH),
      .MM_START_ADDRESS(MM_START_ADDRESS),
      .MM_FRAME_SIZE(SPRITE_SIZE),
      .MAX_PENDING_READS(MM_MAX_PENDING_READS),
      .FIFO_SIZE_WIDTH(FIFO_SIZE_WIDTH)
   ) vga_frame_buffer_prefetch_0(
      .clk,
      .reset,
      .start(sprite_prefetch_start),
      .address_wr(1'b1),
      .address(csr_pending.base_address),
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_readdata(mm_mem_readdata),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdatavalid(mm_mem_readdatavalid),
      .fifo_wren,
      .fifo_wrdata,
      .fifo_num_free(fifo_num_free)
   );

   prefetcher_fifo_item_t fifo_rddata_record;
   assign fifo_rddata_record = fifo_rddata;

   // Narrow FIFO output from MM_DATA_WIDTH to 1 bit (sprite pixel)
   logic st_fifo_source_ready;
   logic st_fifo_source_data;
   logic st_fifo_source_startofpacket;
   logic st_fifo_source_endofpacket;
   logic st_fifo_source_valid;

   width_narrowing_adapter #(
      .ST_SINK_WIDTH(MM_DATA_WIDTH),
      .ST_SOURCE_WIDTH(1)
   ) width_narrowing_adapter_0(
      .clk,
      .reset,
      .st_sink_ready(fifo_rden),
      .st_sink_data(fifo_rddata_record.data),
      .st_sink_startofpacket(fifo_rddata_record.startofpacket),
      .st_sink_endofpacket(fifo_rddata_record.endofpacket),
      .st_sink_valid(fifo_rddata_valid),
      .st_source_ready(st_fifo_source_ready),
      .st_source_data(st_fifo_source_data),
      .st_source_startofpacket(st_fifo_source_startofpacket),
      .st_source_endofpacket(st_fifo_source_endofpacket),
      .st_source_valid(st_fifo_source_valid)
   );

   // FSM for producing one heartbeat on Avalon ST source for each pixel of the display
   typedef enum logic [2:0] {
      WAIT,           // Wait for frame start signal
      START,          // One cycle state to initialize state for a new frame display
      DISPLAY_SPRITE, // Produce frame, either default background or sprite pixel
      DRAIN_FIFO,     // Read till end of packet from fifo in preparation for new frame
      DISPLAY_EMPTY,  // Produce black background for full frame when sprite is not enabled
      CLOSE_PACKET    // Output end of packet marker on Avalon ST interface
   } FBReaderState;
   
   FBReaderState current_state, next_state;

   logic start_reg;

   always_ff @(posedge clk)
   begin: start_update
      if (reset) begin
         start_reg             <= '0;
         sprite_prefetch_start <= '0;
         csr_current           <= '{default: '0};
      end
      else begin
         if (restart_frame) begin
            start_reg   <= 1'b1;
         end
         if (current_state == START) begin
            start_reg             <= '0;
            csr_current           <= csr_pending;
            sprite_prefetch_start <= csr_pending.enabled;
         end
         else begin
            // Prefetch start signal is enabled for one cycle only
            sprite_prefetch_start <= '0;
         end
      end
   end

   // Keep track of current coordinate to output on Avalon ST interface
   logic [COORD_DATA_WIDTH-1:0] x;
   logic [COORD_DATA_WIDTH-1:0] y;
   
   // Check if current coordinate is inside of the sprite
   wire inside_sprite = csr_current.sprite_x1 <= x && x <= csr_current.sprite_x2
                        && csr_current.sprite_y1 <= y && y <= csr_current.sprite_y2;

   logic st_valid_tmp;
   wire pixel_done = st_valid_tmp && st_ready;

   // Update current pixel coordinates
   always_ff @(posedge clk)
   begin: xy_update
      if (reset || current_state == START) begin
         x <= '0;
         y <= '0;
      end
      else if ((current_state == DISPLAY_SPRITE || current_state == DISPLAY_EMPTY) && pixel_done) begin
         if (x == WIDTH - 1) begin
            x <= '0;
            y <= y + 1'b1;
         end
         else begin
            x <= x + 1'b1;
         end
      end
   end
   
   // Keep track of FIFO start/end of packet state
   logic fifo_packet_done;

   always_ff @(posedge clk)
   begin: fifo_packet_done_update
      if (reset || current_state == START) begin
         fifo_packet_done <= 1'b0;
      end
      else if (st_fifo_source_valid && st_fifo_source_ready && st_fifo_source_endofpacket) begin
         fifo_packet_done <= 1'b1;
      end
   end

   always_comb
   begin: state_update
      next_state = current_state;
      case (current_state)
         WAIT:
            if (start_reg)
               next_state = START;
         START:
            next_state = csr_pending.enabled ? DISPLAY_SPRITE : DISPLAY_EMPTY;
         DISPLAY_SPRITE:
            if (start_reg || (x == WIDTH - 1 && y == HEIGHT - 1 && pixel_done))
               next_state = DRAIN_FIFO;
         DRAIN_FIFO:
            if (fifo_packet_done)
               next_state = CLOSE_PACKET;
         DISPLAY_EMPTY:
            if (start_reg || (x == WIDTH - 1 && y == HEIGHT - 1 && pixel_done))
               next_state = CLOSE_PACKET;
         CLOSE_PACKET:
            if (st_ready)
               next_state = WAIT;
      endcase
   end

   always_comb
   begin: output_update
      st_fifo_source_ready = '0;
      st_valid_tmp         = '0;
      st_data              = '0;
      st_startofpacket     = '0;
      st_endofpacket       = '0;
      st_empty             = '0;
      case (current_state)
         DISPLAY_SPRITE:
            begin
               if (inside_sprite) begin
                  // Try to read next sprite pixel from FIFO, if required
                  st_fifo_source_ready = st_ready;

                  if (st_fifo_source_valid && !st_fifo_source_endofpacket) begin
                     st_valid_tmp = '1;
                     st_data      = st_fifo_source_data ? MM_DATA_WIDTH'(csr_current.color) : '0;
                  end
               end
               else begin
                  // Output black outside of the sprite
                  st_valid_tmp = '1;
               end
               st_startofpacket = x == '0 && y == '0;
            end
         DRAIN_FIFO:
            begin
               st_fifo_source_ready = !fifo_packet_done;
            end
         DISPLAY_EMPTY:
            begin
               // Always output black when sprite is disabled
               st_valid_tmp     = '1;
               st_startofpacket = x == '0 && y == '0;
            end
         CLOSE_PACKET:
            begin
               st_valid_tmp   = '1;
               st_endofpacket = '1;
               st_empty       = ST_EMPTY_WIDTH'(MM_DATA_WIDTH / 8);
            end
         default: ; // no-op
      endcase
   end
   assign st_valid = st_valid_tmp;

   always_ff @(posedge clk)
   begin: state_transition
      if (reset)
         current_state <= WAIT;
      else
         current_state <= next_state;
   end
endmodule: vga_sprite_stream
