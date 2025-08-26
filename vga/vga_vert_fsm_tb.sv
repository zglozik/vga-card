// synthesis translate_off

`timescale 1ns/1ns

module vga_vert_fsm_tb;
   localparam T = 10;

   logic clk;
   logic reset;
   logic vga_hs, vga_vs;
   logic addr_x_valid, addr_y_valid;
   logic [9:0] addr_x, addr_y;

   vga_horiz_fsm vga_horiz_fsm0(.clk, .reset, .vga_hs, .addr_x_valid, .addr_x);
   vga_vert_fsm vga_vert_fsm0(.clk, .reset, .vga_hs, .vga_vs, .addr_y_valid, .addr_y);

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   initial
   begin: test_write
      $info("testing vga_vert_fsm"); 

      #(T/2) reset = 1;
      
      #(T) reset = 0;
      
      // Check reset
      assert (vga_vs == '1) else $error("Incorrect VGA VSYNC reset");
      assert (addr_y_valid == '0) else $error("Incorrect addr_y_valid reset");

      // Check three frames
      for (int frame = 0; frame < 1; ++frame) begin
         $info("testing frame %d", frame + 1); 

         // Vsync pulse
         for (int i = 0; i < vga_vert_fsm0.VS_PULSE; ++i) begin
            #(T);
            assert (vga_vs == '0) else $error("VGA VSYNC should be low");
            assert (addr_y_valid == '0) else $error("address should be invalid");
         end

         // Back porch
         for (int i = 0; i < vga_vert_fsm0.BACK_PORCH; ++i) begin
            #(T);
            assert (vga_vs == '1) else $error("VGA VSYNC should be high");
            assert (addr_y_valid == '0) else $error("address should be invalid");
         end

         // Lines
         for (int i = 0; i < 480; i = i + 1) begin
            #(T * (vga_horiz_fsm0.HS_PULSE + 2));
            assert (vga_vs == '1) else $error("VGA VSYNC should be high");
            assert (addr_y_valid == '1) else $error("address should be valid");
            assert (addr_y == i) else $error("address incorrect");

            // Skip rest of the line
            #(T * (vga_vert_fsm0.LINE - (vga_horiz_fsm0.HS_PULSE + 2)));
         end

         // Front porch
         for (int i = 0; i < vga_vert_fsm0.FRONT_PORCH ; ++i) begin
            #(T);
            assert (vga_vs == '1) else $error("VGA VSYNC should be high");
            assert (addr_y_valid == '0) else $error("address should be invalid");
         end
      end

      #(T);
      $stop;   
   end
  

endmodule: vga_vert_fsm_tb

// synthesis translate_on
