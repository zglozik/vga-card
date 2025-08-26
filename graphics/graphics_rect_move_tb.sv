
// synthesis translate_off

`timescale 1ns/1ns

module graphics_rect_move_tb;
   import vga_pkg::*, graphics_pkg::*;

   localparam T = 10;
   localparam MEM_INIT_OFFSET = 16'h0000;

   logic clk;
   logic reset;

   // Operation control signals
   logic clken;
   logic start;
   logic done;

   // Avalon MM Slave interface for memory access
   logic                           mm_mem_read;
   logic [MM_MEM_ADDR_WIDTH-1:0]   mm_mem_address;
   logic [MM_MEM_DATA_WIDTH/8-1:0] mm_mem_byteenable;
   logic [MM_MEM_DATA_WIDTH-1:0]   mm_mem_readdata;
   logic                           mm_mem_waitrequest;
   logic                           mm_mem_readdatavalid;

   // Avalon MM CSR register access
   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;

   // Avalon source interface
   logic                     st_ready;
   pixel_t                   st_data;
   logic                     st_valid;

   localparam FRAME_BUFFER_SIZE = WIDTH * HEIGHT * MM_MEM_DATA_WIDTH / 8;
   
   memory_sim #(
      .MEM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MEM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .MEM_SIZE(FRAME_BUFFER_SIZE),
      .MEM_READ_LATENCY(6),
      .MAX_PENDING_READS(4),
      .MEM_INIT_OFFSET(MEM_INIT_OFFSET)
   ) memory_sim_0(
      .clk,
      .reset,
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_readdata(mm_mem_readdata),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdatavalid(mm_mem_readdatavalid)
   );

   graphics_rect_move #(
      .MM_START_ADDRESS(0),
      .MAX_PENDING_READS(7)
   ) graphics_rect_move_0(
      .clk,
      .reset,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .clken,
      .start,
      .done,
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdata(mm_mem_readdata),
      .mm_readdatavalid(mm_mem_readdatavalid),
      .st_ready,
      .st_data,
      .st_valid
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   task automatic start_rect_move(
      input logic [COORD_DATA_WIDTH-1:0] src_x1, src_y1, src_x2, src_y2,
      input logic [COORD_DATA_WIDTH-1:0] dst_x, dst_y
   );
      coordinate_t src1 = '{x: src_x1, y: src_y1};
      coordinate_t src2 = '{x: src_x2, y: src_y2};
      coordinate_t dst  = '{x: dst_x, y: dst_y};
      int dx, dy;

      $info("Starting rect move: src_x1 = %d, src_y1 = %d, src_x2 = %d, src_y2 = %d, dst_x = %d, dst_y = %d",
            src_x1, src_y1, src_x2, src_y2, dst_x, dst_y);

      @(posedge clk);
      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_MOVE_SRC_POINT1;
      mm_csr_writedata <= src1;
      
      @(posedge clk iff !mm_csr_waitrequest);
      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_MOVE_SRC_POINT2;
      mm_csr_writedata <= src2;

      @(posedge clk iff !mm_csr_waitrequest);
      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_MOVE_DST_POINT;
      mm_csr_writedata <= dst;

      @(posedge clk iff !mm_csr_waitrequest);
      start <= '1;
      
      @(posedge clk);
      start <= '0;
      
   endtask: start_rect_move

   task automatic check_rect_move(
      input logic signed [COORD_DATA_WIDTH-1:0] dst_x1, dst_y1, dst_x2, dst_y2,
      input logic signed [COORD_DATA_WIDTH-1:0] dx, dy,
      input logic signed [COORD_DATA_WIDTH-1:0] src_offset_x, src_offset_y
   );
      logic done_received;

      $info("Checking rect move: dst_x1 = %d, dst_y1 = %d, dst_x2 = %d, dst_y2 = %d, dx = %d, dy = %d, src_offset_x = %d, src_offset_y = %d",
            dst_x1, dst_y1, dst_x2, dst_y2, dx, dy, src_offset_x, src_offset_y);

      // Move end point one past the rectangle edge
      dst_x2 = dst_x2 + dx;
      dst_y2 = dst_y2 + dy;

      @(posedge clk);
      st_ready      <= '1;
      done_received = '0;
      
      for (int y = dst_y1; y != dst_y2; y = y + dy) begin
         for (int x = dst_x1; x != dst_x2; x = x + dx) begin
            logic [COLOR_DATA_WIDTH-1:0] expected_color = COLOR_DATA_WIDTH'((x + src_offset_x) + (y + src_offset_y) * WIDTH);
            
            @(posedge clk iff st_valid);
            done_received = done_received || done;

            assert (st_data.x == x && st_data.y == y)
               else $error("incorrect output coordinates, expected x = %d, y = %d, received x = %d, y = %d",
                           x, y, st_data.x, st_data.y);
            assert (st_data.color == expected_color)
               else $error("incorrect color output for x = %d, y = %d, expected color = %d, received = %d",
                           x, y, expected_color, st_data.color);
                           
            // Switch off st_ready a few times
            if (({$random()} % 10) < 2) begin
               st_ready <= '0;

               @(posedge clk);
               done_received = done_received || done;
               st_ready <= '1;
            end
         end
      end
      
      // We should not have any more outputs, check for a few cycles (as we have no end of packet indication)
      repeat (10) begin
         @(posedge clk);
         done_received = done_received || done;
         assert (!st_valid) else $error("Unexpected output received");
      end
      st_ready <= '0;
      
      assert (done_received) else $error("done signal was not asserted");
   endtask: check_rect_move

   initial
   begin: test_cases
      reset <= '1;
      clken <= '1;
      start <= '0;
      st_ready <= '0;

      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata <= '0;

      @(posedge clk);
      reset <= '0;

      // Copy by moving right and down
      start_rect_move(.src_x1(10), .src_y1(2), .src_x2(20), .src_y2(4), .dst_x(5), .dst_y(1));
      check_rect_move(.dst_x1(5), .dst_y1(1), .dst_x2(15), .dst_y2(3), .dx(1), .dy(1), .src_offset_x(5), .src_offset_y(1));

      // Same move, but initial coordinates are given in different order
      start_rect_move(.src_x1(20), .src_y1(4), .src_x2(10), .src_y2(2), .dst_x(5), .dst_y(1));
      check_rect_move(.dst_x1(5), .dst_y1(1), .dst_x2(15), .dst_y2(3), .dx(1), .dy(1), .src_offset_x(5), .src_offset_y(1));

      // Copy by moving left and up
      start_rect_move(.src_x1(5), .src_y1(1), .src_x2(15), .src_y2(3), .dst_x(10), .dst_y(2));
      check_rect_move(.dst_x1(20), .dst_y1(4), .dst_x2(10), .dst_y2(2), .dx(-1), .dy(-1), .src_offset_x(-5), .src_offset_y(-1));

      // Copy by moving right and up
      start_rect_move(.src_x1(10), .src_y1(1), .src_x2(20), .src_y2(3), .dst_x(5), .dst_y(3));
      check_rect_move(.dst_x1(5), .dst_y1(5), .dst_x2(15), .dst_y2(3), .dx(1), .dy(-1), .src_offset_x(5), .src_offset_y(-2));

      // Copy one pixel only
      start_rect_move(.src_x1(10), .src_y1(3), .src_x2(10), .src_y2(3), .dst_x(15), .dst_y(1));
      check_rect_move(.dst_x1(15), .dst_y1(1), .dst_x2(15), .dst_y2(1), .dx(-1), .dy(1), .src_offset_x(-5), .src_offset_y(2));

      // Copy into itself
      start_rect_move(.src_x1(10), .src_y1(2), .src_x2(20), .src_y2(4), .dst_x(10), .dst_y(2));
      check_rect_move(.dst_x1(10), .dst_y1(2), .dst_x2(20), .dst_y2(4), .dx(1), .dy(1), .src_offset_x(0), .src_offset_y(0));
      
      #(5*T);
      $stop;
   end
   
endmodule: graphics_rect_move_tb

// synthesis translate_on
