
// synthesis translate_off

`timescale 1ns/1ns

module vga_sprite_stream_tb;
   import vga_pkg::*;

   localparam T = 10;
   localparam SPRITE_WIDTH  = 48;
   localparam SPRITE_HEIGHT = 48;

   // Sprite memory address and size in bytes
   localparam SPRITE_MEM_BASE_ADDRESS = 1024;
   localparam SPRITE_MEM_SIZE = SPRITE_WIDTH * SPRITE_HEIGHT / 8;

   localparam string MEM_SPRITE_FILE = "memory_sim_sprite.mem";
   localparam ST_EMPTY_WIDTH = $clog2(MM_MEM_DATA_WIDTH / 8 + 1);

   // Top-left corner of test sprite location
   localparam SPRITE_X1 = 10;
   localparam SPRITE_Y1 =  2;
   localparam COLOR       = 12'b100111110110;
   localparam BLACK_PIXEL = 12'h000;

   logic clk;
   logic reset;

   // Avalon MM Slave interface for memory access
   logic                           mm_mem_read;
   logic [MM_MEM_ADDR_WIDTH-1:0]   mm_mem_address;
   logic [MM_MEM_DATA_WIDTH/8-1:0] mm_mem_byteenable;
   logic [MM_MEM_DATA_WIDTH-1:0]   mm_mem_readdata;
   logic                           mm_mem_waitrequest;
   logic                           mm_mem_readdatavalid;

   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;

   // Avalon source interface
   logic                         st_ready;
   logic [MM_MEM_DATA_WIDTH-1:0] st_data;
   logic                         st_startofpacket;
   logic                         st_endofpacket;
   logic [ST_EMPTY_WIDTH-1:0]    st_empty;
   logic                         st_valid;

   memory_sim #(
      .MEM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MEM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .MEM_SIZE(SPRITE_MEM_SIZE),
      .MEM_READ_LATENCY(6),
      .MAX_PENDING_READS(4),
      .MEM_BASE_ADDRESS(SPRITE_MEM_BASE_ADDRESS),
      .MEM_INIT_FILE(MEM_SPRITE_FILE)
   ) memory_sim0(
      .clk,
      .reset,
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_readdata(mm_mem_readdata),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdatavalid(mm_mem_readdatavalid)
   );

   vga_sprite_stream #(
      .MM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .SPRITE_WIDTH(SPRITE_WIDTH),
      .SPRITE_HEIGHT(SPRITE_WIDTH),
      .SPRITE_SIZE(SPRITE_MEM_SIZE)
   ) vga_sprite_stream0(
      .clk,
      .reset,
      .mm_mem_read,
      .mm_mem_address,
      .mm_mem_byteenable,
      .mm_mem_readdata,
      .mm_mem_waitrequest,
      .mm_mem_readdatavalid,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .st_ready,
      .st_data,
      .st_startofpacket,
      .st_endofpacket,
      .st_empty,
      .st_valid
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   task automatic configure_csr();
   
      @(posedge clk) begin
         coordinate_t top_left;
         top_left = '{x: SPRITE_X1, y: SPRITE_Y1};

         mm_csr_write     <= '1;
         mm_csr_address   <= VGA_SPRITE_STREAM_BASE_ADDRESS_REG;
         mm_csr_writedata <= SPRITE_MEM_BASE_ADDRESS;
      end

      @(posedge clk iff !mm_csr_waitrequest) begin
         coordinate_t top_left;
         top_left = '{x: SPRITE_X1, y: SPRITE_Y1};

         mm_csr_write     <= '1;
         mm_csr_address   <= VGA_SPRITE_STREAM_XY_REG;
         mm_csr_writedata <= top_left;
      end

      @(posedge clk iff !mm_csr_waitrequest) begin
         color_t color;
         color = '{color: COLOR, default: '0};

         mm_csr_write     <= '1;
         mm_csr_address   <= VGA_SPRITE_STREAM_COLOR_REG;
         mm_csr_writedata <= color;
      end

      @(posedge clk iff !mm_csr_waitrequest) begin
         mm_csr_write     <= '0;
         mm_csr_address   <= '0;
         mm_csr_writedata <= '0;
      end
   endtask: configure_csr

   task automatic config_sprite_enable_csr(input logic sprite_enabled);

      @(posedge clk) begin
         mm_csr_write     <= '1;
         mm_csr_address   <= VGA_SPRITE_STREAM_ENABLE_REG;
         mm_csr_writedata <= sprite_enabled;
      end

      @(posedge clk iff !mm_csr_waitrequest) begin
         mm_csr_write     <= '0;
         mm_csr_address   <= '0;
         mm_csr_writedata <= '0;
      end
   endtask: config_sprite_enable_csr

   task automatic restart_frame();
   
      @(posedge clk) begin
         mm_csr_write     <= '1;
         mm_csr_address   <= VGA_STREAM_RESTART_REG;
         mm_csr_writedata <= 1'b1;
      end

      @(posedge clk iff !mm_csr_waitrequest) begin
         mm_csr_write     <= '0;
         mm_csr_address   <= '0;
         mm_csr_writedata <= '0;
      end
   endtask: restart_frame

   task automatic check_pixel(
      input logic sprite_enabled,
      input int i,
      input int j,
      input logic [MM_MEM_DATA_WIDTH-1:0] pixel_data
   );

      if (sprite_enabled && SPRITE_X1 <= i && i < SPRITE_X1 + SPRITE_WIDTH && SPRITE_Y1 <= j && j < SPRITE_Y1 + SPRITE_HEIGHT) begin
         // Inside the sprite we have a checked pattern, 8 white pixels, 8 black pixels, etc.
         int column_byte_index = (i - SPRITE_X1) / 8;
         int row_index = j - SPRITE_Y1;
         if (row_index % 2 == 0) begin
            // Row starts with white
            if (column_byte_index % 2 == 0)
               assert (pixel_data == COLOR) else $error("inside sprite, pixel %d, %d should be white", i, j);
            else
               assert (pixel_data == BLACK_PIXEL) else $error("inside sprite, pixel %d, %d should be black", i, j);
         end
         else begin
            // Row starts with black
            if (column_byte_index % 2 == 0)
               assert (pixel_data == BLACK_PIXEL) else $error("inside sprite, pixel %d, %d should be black", i, j);
            else
               assert (pixel_data == COLOR) else $error("inside sprite, pixel %d, %d should be white", i, j);
         end
      end
      else begin
         // Pixel should be black outside of the sprite, or if sprite is not enabled
         assert (pixel_data == BLACK_PIXEL) else $error("outside sprite or sprite disabled, pixel %d, %d should be black", i, j);
      end
   endtask: check_pixel

   task automatic check_frame(input logic sprite_enabled);

      // Wait a few cycles before reading
      #(6*T);
      $info("Starting reading data frame");
      st_ready <= '1;

      // We should be able to read pixels in continuous cycles
      for (int j = 0; j < HEIGHT; j = j + 1) begin
         for (int i = 0; i < WIDTH; i = i + 1) begin
            #(T);
            assert (st_valid) else $error("data should be valid, pixel %d, %d", i, j);
            if (st_valid) begin
               assert ((i != 0 || j != 0) ^ st_startofpacket) else $error("start of packet should be high only for first word, pixel: %d, %d", i, j);
               assert (!st_endofpacket) else $error("end of packet should be low for packet content");
               assert (st_empty == 0) else $error("no symbols should be empty in this heartbeat");

               check_pixel(sprite_enabled, i, j, st_data);
            end
         end
      end

      #(T);
      wait (st_valid)
         @(posedge clk);

      // Read empty end of packet word
      assert (st_endofpacket) else $error("end of packet should be high for the trailer");
      assert (st_empty == MM_MEM_DATA_WIDTH / 8) else $error("all symbols should be empty in this heartbeat");
      assert (!st_startofpacket) else $error("start of packet should be low for the trailer");
      
      // No more data should be available
      #(T);
      st_ready <= '0;
      assert (!st_valid) else $error("data should not be available beyond the frame");

      endtask: check_frame

   initial
   begin: test_cases
      reset         <= '1;
      st_ready      <= '0;
      
      #(T) reset <= '0;

      configure_csr();
      config_sprite_enable_csr(1'b1);

      restart_frame();
      check_frame(1'b1);
      
      // Disable sprite, check frame again
      config_sprite_enable_csr(1'b0);

      restart_frame();
      check_frame(1'b0);

      // Re-enable sprite, start a frame again, but interrupt in the middle of the sprite
      config_sprite_enable_csr(1'b1);
      restart_frame();

      // Wait a few cycles before reading
      #(5*T);
      $info("Starting reading data frame");
      st_ready <= '1;

      // We should be able to read pixels in continuous cycles
      for (int i = 0; i < (SPRITE_Y1 + 2) * WIDTH + SPRITE_X1 + 10; i = i + 1) begin
         int x, y;
         x = i % WIDTH;
         y = i / WIDTH;
         #(T);
         assert (st_valid) else $error("data should be valid, pixel %d, %d", x, y);
         if (st_valid) begin
            check_pixel(1'b1, x, y, st_data);
         end
      end

      restart_frame();
      
      // There should be an end of packet when the sprite is fully read
      for (int i = 0; i < SPRITE_WIDTH * SPRITE_HEIGHT + 10 && (!st_valid || !st_endofpacket); i = i + 1) begin
         #T;
      end
         
      assert (st_valid && st_endofpacket) else $error("end of packet was not delivered quick enough after restart frame");
      st_ready <= '0;

      $display("checking if frame is still correct after the interrupt");
      check_frame(1'b1);

      #(5*T);
      $stop;
   end
   
endmodule: vga_sprite_stream_tb

// synthesis translate_on
