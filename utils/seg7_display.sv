
// 7 segment display module
module seg7_display(
   input  logic en,           // display enable
   input  logic [3:0] number, // decimal number to display, 0-9
   output logic [7:0] display // Ports for digit
);
   always_comb
   begin
      if (en)
         case (number)
            4'd0:    display = 8'b11000000;
            4'd1:    display = 8'b11111001;
            4'd2:    display = 8'b10100100;
            4'd3:    display = 8'b10110000;
            4'd4:    display = 8'b10011001;
            4'd5:    display = 8'b10010010;
            4'd6:    display = 8'b10000010;
            4'd7:    display = 8'b11111000;
            4'd8:    display = 8'b10000000;
            4'd9:    display = 8'b10010000;
            default: display = '0;
         endcase
      else
         display = '1;
   end
endmodule: seg7_display
