
// synthesis translate_off

`timescale 1ns/1ns

module vga_display_tb;
   import vga_pkg::*;

   localparam T = 10;
   localparam ST_DATA_WIDTH = 16;

   localparam READS_PER_FRAME = 640 * 480;

   logic clk;
   logic reset;
   
   // Avalon ST source interface, one ready cycle per pixel
   logic                     st_ready;
   logic [ST_DATA_WIDTH-1:0] st_data;
   logic                     st_startofpacket;
   logic                     st_endofpacket;
   logic                     st_valid;

   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;

   // Output RGB values, HSYNC/VSYNC signals
	logic vga_hs_out;
	logic vga_vs_out;
	logic [DISPLAY_CDEPTH-1:0] vga_r;
	logic [DISPLAY_CDEPTH-1:0] vga_g;
   logic [DISPLAY_CDEPTH-1:0] vga_b;


   vga_display vga_display0(
      .clk,
      .reset,
      .st_ready,
      .st_data,
      .st_startofpacket,
      .st_endofpacket,
      .st_valid,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .vga_hs_out,
      .vga_vs_out,
      .vga_r,
      .vga_g,
      .vga_b
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   logic [19:0] counter;
   logic [7:0]  frames;

   always_ff @(posedge clk)
   begin: rgb_counter_update
      if (reset) begin
         counter <= '0;
			frames  <= '0;
		end
      else if (st_ready) begin
			if (counter == READS_PER_FRAME) begin
				counter <= '0;
				frames  <= frames + 1'b1;
			end
			else begin
				counter <= counter + 1'b1;
			end
      end
   end
   
   assign st_data = counter[ST_DATA_WIDTH-1:0];
   assign st_startofpacket = counter == '0;
   assign st_endofpacket = counter == READS_PER_FRAME;
   assign st_valid = '1;

   initial
   begin: test_cases
      reset <= '1;
      mm_csr_waitrequest <= '1;

      #(T);
      reset <= '0;
      
      wait (mm_csr_write);
      @(posedge clk);

      assert (mm_csr_address == '0) else $error("incorrect restart command address");
      assert (mm_csr_writedata == 1'b1) else $error("incorrect restart command operation");
      mm_csr_waitrequest <= '0;

      #(T);
      assert (mm_csr_write) else $error("restart command should still be asserted for this cycle");

      #(T);
      assert (!mm_csr_write) else $error("restart command should no longer be asserted");

      // One frame is 525 lines, one line is 800 cycles.
      // Display frame twice.
      #((525*800 - 3)*T);
      assert (frames == 1) else $error("frame is not read correctly");
      assert (counter == '0) else $error("incorrect number of pixels requested in first frame");

      // Consume frame again
      wait (mm_csr_write);
      @(posedge clk);
      assert (mm_csr_address == '0) else $error("incorrect restart command address");
      assert (mm_csr_writedata == 1'b1) else $error("incorrect restart command operation");

      wait (!mm_csr_write);
      @(posedge clk);

      #((525*800 - 2)*T);
      assert (frames == 2) else $error("frame is not read correctly");
      assert (counter == '0) else $error("incorrect number of pixels requested in second frame");
      
      #(10*T);
      
      $stop;
   end      
      
endmodule: vga_display_tb

// synthesis translate_on
