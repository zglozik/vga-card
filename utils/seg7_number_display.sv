
module seg7_number_display
#(
   parameter BINARY_DATA_WIDTH   = 16,
   parameter BCD_DIGITS          = 5,
   parameter CSR_ADDR_WIDTH      = 4,
   parameter CSR_DATA_WIDTH      = 32
)
(
   input logic clk,
   input logic reset,
   
   // Avalon MM Slave signals for CSR interface:
   // Word offset 0:
   //    - bit 0: enable/disable number display, disabled by default
   // Word offset 1:
   //    - Binary number to display as decimal
   input  logic                      mm_csr_write,
   input  logic [CSR_ADDR_WIDTH-1:0] mm_csr_address,
   input  logic [CSR_DATA_WIDTH-1:0] mm_csr_writedata,
   output logic                      mm_csr_waitrequest,
   
   // Output ports for driving 7 segment display
   output logic [BCD_DIGITS*8-1:0] digits
);
   localparam BCD_DIGIT_WIDTH = 4;

   logic enabled; // Display enabled/disabled flag
   logic running; // Asserted when a conversion is in progress
   logic start, done;

   // Next number to display when current conversion is finished
   logic [BINARY_DATA_WIDTH-1:0]                binary;
   logic [BCD_DIGITS-1:0][BCD_DIGIT_WIDTH-1:0]  bcd;
   logic [BCD_DIGITS-1:0]                       digits_enabled;   // To disable leading zero digits
   // Asserted when there is a new number is binary to display
   logic update_required;

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
   
   generate
      genvar i;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin: digit_display
         // A digit is enabled only if at least one more significant digit is non-zero
         if (i == 0) begin
            assign digits_enabled[0] = enabled;
         end
         else begin
            assign digits_enabled[i] = enabled && |bcd[BCD_DIGITS-1:i];
         end

         seg7_display seg7_display_0(
            .en(digits_enabled[i]),
            .number(bcd[i]),
            .display(digits[i*8+:8])
         );
      end
   endgenerate

   // Process CSR requests
   assign mm_csr_waitrequest = '0;

   always_ff @(posedge clk)
   begin: state_update
      if (reset) begin
         enabled         <= '0;
         binary          <= '0;
         update_required <= '0;
         start           <= '0;
         running         <= '0;
      end
      else begin
         // Default to no start, it will be asserted for one cycle only
         start <= 1'b0;

         // Process CSR requests
         if (mm_csr_write) begin
            case (mm_csr_address)
               0:
                  enabled <= mm_csr_writedata[0];
               1:
                  begin
                     binary <= BINARY_DATA_WIDTH'(mm_csr_writedata);
                     update_required <= 1'b1;
                  end
               default:
                  ; // no-op
            endcase
         end

         // Update running state
         if (!running && update_required) begin
            start           <= 1'b1;
            running         <= 1'b1;
            update_required <= '0;
         end
         else if (running && done) begin
            running <= 1'b0;
         end
      end
   end

endmodule: seg7_number_display
