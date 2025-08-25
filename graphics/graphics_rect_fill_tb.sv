
// synthesis translate_off

`timescale 1ns/1ns

module graphics_rect_fill_tb;
   import vga_pkg::*, graphics_pkg::*;

   localparam T = 10;

	logic clk;
	logic clken;
	logic reset;

	// Avalon MM interface for providing input
   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;
	
	// Operation control signals
	logic start;
	logic done;
	
   // Avalon ST source interface for streaming pixels to be changed in frame buffer
   logic                      st_ready;
   pixel_t                    st_data;
   logic                      st_valid;

   graphics_rect_fill graphics_rect_fill0(
      .clk,
      .clken,
      .reset,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .start,
      .done,
      .st_ready,
      .st_data,
      .st_valid
   );
   
   initial
   begin: clock
      clk = '1;
      clken = '1;
      forever #(T/2) clk = ~clk;
   end

   function automatic integer min(input integer a, input integer b);
      min = a < b ? a : b;
   endfunction: min;

   function automatic integer max(input integer a, input integer b);
      max = a < b ? b : a;
   endfunction: max;

   task automatic fill_rectangle(
      input logic [COORD_DATA_WIDTH-1:0] x0,
      input logic [COORD_DATA_WIDTH-1:0] y0,
      input logic [COORD_DATA_WIDTH-1:0] x1,
      input logic [COORD_DATA_WIDTH-1:0] y1,
      input logic [COLOR_DATA_WIDTH-1:0] color
   );
      coordinate_t point1, point2;
      color_t color_data;

      point1.x         = x0;
      point1.y         = y0;
      point2.x         = x1;
      point2.y         = y1;
      color_data.color   = color;
      color_data.padding = '0;

      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_FILL_POINT1;
      mm_csr_writedata <= point1;
      
      #(T);
      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_FILL_POINT2;
      mm_csr_writedata <= point2;

      #(T);
      mm_csr_write     <= '1;
      mm_csr_address   <= RECT_FILL_COLOR;
      mm_csr_writedata <= color_data;

      #(T);
      mm_csr_write     <= '0;
      start            <= '1;
      
      #(T);
      start            <= '0;
      
      // Check output
      #(T);
      for (int y = min(y0, y1); y <= max(y0, y1); y = y + 1) begin
         for (int x = min(x0, x1); x <= max(x0, x1); x = x + 1) begin
            #(T);
            assert (st_valid) else $error("there should be a pixel output on Avalon interface");
            assert (st_data.x == x) else $error("X coordinate does not match: %d", x);
            assert (st_data.y == y) else $error("Y coordinate does not match: %d", y);
            assert (st_data.color == color) else $error("color does not match");
            assert (!done) else $error("done should not be asserted yet");
         end
      end

      #(T);
      assert (done) else $error("done should be asserted now");
   endtask: fill_rectangle

   initial
   begin: test_cases
      pixel_t expected;

      reset            <= '1;
      mm_csr_write     <= '0;
      mm_csr_address   <= '0;
      mm_csr_writedata <= '0;
      start            <= '0;
      st_ready         <= '0;
      expected         <= '0;

      #(T);
      reset <= '0;
      st_ready <= '1;

      #(T);
      $info("filling rectangle 1");

      fill_rectangle(2, 5, 16, 20, '1);
      
      #(T);

      #(T);
      $info("filling rectangle 2");

      fill_rectangle(16, 20, 2, 5, 16'b0000101010101010);
      
      #(T);

      #(T);
      $info("filling rectangle 3");

      fill_rectangle(10, 10, 10, 10, '1);
      
      #(T);

      $stop;
   end
endmodule: graphics_rect_fill_tb

// synthesis translate_on
