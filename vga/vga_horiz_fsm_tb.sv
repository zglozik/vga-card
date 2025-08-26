// synthesis translate_off

`timescale 1ns/1ns

module vga_horiz_fsm_tb;
   localparam T = 10;

   logic clk;
   logic reset;
   logic vga_hs;
   logic addr_x_valid;
   logic [9:0] addr_x;

   vga_horiz_fsm vga_horiz_fsm0(.clk, .reset, .vga_hs, .addr_x_valid, .addr_x);

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   initial
   begin: test_write
      $info("testing vga_horiz_fsm"); 

      #(T/2) reset = 1;
      
      #(T) reset = 0;
      
      // Check reset
      assert (vga_hs == '1) else $error("Incorrect VGA HSYNC reset");
      assert (addr_x_valid == '0) else $error("Incorrect addr_x_valid reset");

      // Check three lines
      for (int line = 0; line < 3; ++line) begin
         $info("testing line %d", line + 1); 

         // Hsync pulse
         for (int i = 0; i < vga_horiz_fsm0.HS_PULSE ; ++i) begin
            #(T);
            assert (vga_hs == '0) else $error("VGA HSYNC should be low");
            assert (addr_x_valid == '0) else $error("address should be invalid");
         end

         // Back porch
         for (int i = 0; i < vga_horiz_fsm0.BACK_PORCH ; ++i) begin
            #(T);
            assert (vga_hs == '1) else $error("VGA HSYNC should be high");
            assert (addr_x_valid == '0) else $error("address should be invalid");
         end

         // Pixels
         for (int i = 0; i < 640; i = i + 1) begin
            #(T);
            assert (vga_hs == '1) else $error("VGA HSYNC should be high");
            assert (addr_x_valid == '1) else $error("address should be valid");
            assert (addr_x == i) else $error("address incorrect");
         end

         // Front porch
         for (int i = 0; i < vga_horiz_fsm0.FRONT_PORCH ; ++i) begin
            #(T);
            assert (vga_hs == '1) else $error("VGA HSYNC should be high");
            assert (addr_x_valid == '0) else $error("address should be invalid");
         end
      end

      #(T);
      $stop;   
   end
  

endmodule: vga_horiz_fsm_tb

// synthesis translate_on
