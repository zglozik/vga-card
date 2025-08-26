
// synthesis translate_off

`timescale 1ns/1ns

module bin2bcd_tb;

   localparam T = 10;
   localparam BINARY_DATA_WIDTH = 16;
   localparam BCD_DIGITS        = 5;

   logic clk;
   logic reset;

   logic start;
   logic done;

   logic [BINARY_DATA_WIDTH-1:0] binary;
   logic [BCD_DIGITS-1:0][3:0]   bcd;

   bin2bcd #(
      .BINARY_DATA_WIDTH(BINARY_DATA_WIDTH),
      .BCD_DIGITS(BCD_DIGITS)
   ) bin2bcd_0(
      .clk,
      .reset,
      .start,
      .done,
      .binary,
      .bcd
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   task automatic convert(
      input logic [BINARY_DATA_WIDTH-1:0] binary_input,
      input logic [BCD_DIGITS-1:0][3:0]   bcd_expected
   );
   
      @(posedge clk);
      binary <= binary_input;
      start  <= '1;
      
      @(posedge clk);
      start <= '0;

      @(posedge clk iff done);
      assert (bcd == bcd_expected) else $error("incorrect conversion");
   endtask

   initial
   begin: test_cases
      reset  <= '1;
      start  <= '0;
      binary <= '0;

      @(posedge clk);
      reset <= '0;
      
      convert(16'h00FF, '{0, 0, 2, 5, 5});

      convert(16'hFFFF, '{6, 5, 5, 3, 5});

      convert(16'h0000, '{0, 0, 0, 0, 0});

      convert(16'hBEEF, '{4, 8, 8, 7, 9});

      #(3*T);

      $stop;
   end
  
endmodule: bin2bcd_tb

// synthesis translate_on
