
module bin2bcd
#(
   parameter int unsigned BINARY_DATA_WIDTH = 16,
   parameter int unsigned BCD_DIGITS        = 5,
   parameter int unsigned BCD_DIGIT_WIDTH   = 4
)
(
   input  logic clk,
   input  logic reset,

   input  logic start,
   output logic done,
   
   input  logic [BINARY_DATA_WIDTH-1:0]               binary,
   output logic [BCD_DIGITS-1:0][BCD_DIGIT_WIDTH-1:0] bcd
);
   typedef enum logic [1:0] {
      IDLE,
      INIT,
      RUNNING,
      DONE
   } state_t;

   state_t current_state, next_state;

   logic [BINARY_DATA_WIDTH-1:0]               binary_reg;
   logic [BCD_DIGITS-1:0][BCD_DIGIT_WIDTH-1:0] bcd_reg;
   logic [BCD_DIGITS*BCD_DIGIT_WIDTH-1:0]      bcd_next;
   logic [$clog2(BINARY_DATA_WIDTH + 1)-1:0]   counter;

   always_comb
   begin: state_update
      next_state = current_state;
      case (current_state)
         IDLE:
            if (start)
               next_state = INIT;
         INIT:
            next_state = RUNNING;
         RUNNING:
            if (counter == 0)
               next_state = DONE;
         DONE:
            next_state = IDLE;
         default:
            ; // no-op
      endcase
   end

   generate
      // Add 3 to all BCD digits that are 5 or greater in preparation for shift
      genvar i;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin: bcd_next_calc
         assign bcd_next[i*BCD_DIGIT_WIDTH+:BCD_DIGIT_WIDTH] = bcd_reg[i] >= 5 ? bcd_reg[i] + 2'd3 : bcd_reg[i];
      end
   endgenerate

   always_ff @(posedge clk)
   begin: conversion
      if (reset) begin
         binary_reg <= '0;
         bcd_reg    <= '0;
         counter    <= '0;
      end
      else begin
         case (current_state)
            IDLE:
               if (start)
                  binary_reg <= binary;
            INIT:
               begin
                  bcd_reg <= '0;
                  counter <= $bits(counter)'(BINARY_DATA_WIDTH - 1'b1);
               end
            RUNNING:
               begin
                  bcd_reg    <= {bcd_next[$high(bcd_next)-1:0], binary_reg[BINARY_DATA_WIDTH-1]};
                  binary_reg <= binary_reg << 1;
                  counter    <= counter - 1'b1;
               end
            default:
               ; // no-op
         endcase
      end
   end
   
   assign bcd  = bcd_reg;
   assign done = current_state == DONE;

   always_ff @(posedge clk)
   begin: state_transition
      if (reset)
         current_state <= IDLE;
      else
         current_state <= next_state;
   end      
   
endmodule: bin2bcd
