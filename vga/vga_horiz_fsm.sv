
// Timings from:
//    http://www.javiervalcarce.eu/html/vga-signal-format-timming-specs-en.html
//    http://tinyvga.com/vga-timing/640x480@60Hz
//
// horizontal line, from vga_hs low to vga_hs low: 800 ticks
// vga_hs pulse, from vga_hs low to vga_hs high:    96 ticks
// horizontal back porch:                           48 ticks
// horizontal pixels:                              640 ticks
// horizontal front porch:                          16 ticks
// 
// vertical lines, from vga_vs low to vga_vs low:  420000 ticks
// vga_vs pulse, from vga_vs low to vga_vs high:     1600 ticks
// vertical back porch:                             26400 ticks
// vertical lines:                                 384000 ticks
// vertical front porch:                             8000 ticks

module vga_horiz_fsm
   import vga_pkg::*;
(
   input  logic clk,             // 25Mhz for 640x480 at 60Hz refresh rate
   input  logic reset,
	output logic vga_hs,          // VGA HSYNC signal
   output logic addr_x_valid,    // pixel in addr_x needs to be displayed
   output logic [ADDR_X_WIDTH-1:0] addr_x     // pixel to display
);

   localparam int unsigned HS_PULSE = 96;
   localparam int unsigned BACK_PORCH = 48;
   localparam int unsigned PIXELS = 640;
   localparam int unsigned FRONT_PORCH = 16;
   localparam int unsigned LINE = HS_PULSE + BACK_PORCH + PIXELS + FRONT_PORCH;
   
   typedef enum logic [1:0] {
      STATE_HS_PULSE,
      STATE_BACK_PORCH,
      STATE_PIXELS,
      STATE_FRONT_PORCH
   } state_t;

   state_t current_state, next_state;

   localparam int unsigned COUNTER_WIDTH = $clog2(LINE);

   logic [COUNTER_WIDTH-1:0] counter;
   
   always_ff @(posedge clk)
   begin: counter_update
      if (reset) begin
         counter <= '0;
      end
      else begin
         counter <= counter + COUNTER_WIDTH'(1);
         if (counter == LINE - 1)
            counter <= '0;
      end
   end

   always_comb
   begin: state_table
      case (current_state)
         STATE_HS_PULSE:
            begin
               if (counter == HS_PULSE - 1)
                  next_state = STATE_BACK_PORCH;
               else
                  next_state = STATE_HS_PULSE;
             end
         STATE_BACK_PORCH:
            begin
               if (counter == HS_PULSE + BACK_PORCH - 1)
                  next_state = STATE_PIXELS;
               else
                  next_state = STATE_BACK_PORCH;
            end
         STATE_PIXELS:
            begin
               if (counter == HS_PULSE + BACK_PORCH + PIXELS - 1)
                  next_state = STATE_FRONT_PORCH;
               else
                  next_state = STATE_PIXELS;
            end
         STATE_FRONT_PORCH:
            begin
               if (counter == LINE - 1)
                  next_state = STATE_HS_PULSE;
               else
                  next_state = STATE_FRONT_PORCH;
            end
         default:
            next_state = state_t'(2'bx);
      endcase
   end
   
   always_ff @(posedge clk)
   begin: state_transition
      if (reset) begin
         current_state <= STATE_HS_PULSE;
      end
      else begin
         current_state <= next_state;
      end
   end

   always_ff @(posedge clk)
   begin: address_output
      if (reset) begin
         addr_x_valid <= '0;
         addr_x <= -(ADDR_X_WIDTH'(1));
      end
      else if (current_state == STATE_PIXELS) begin
         addr_x_valid <= '1;
         addr_x <= addr_x + ADDR_X_WIDTH'(1);
      end
      else begin
         addr_x_valid <= '0;
         addr_x <= -(ADDR_X_WIDTH'(1));
      end
   end

   always_ff @(posedge clk)
   begin: vga_hsync_output
      if (reset)
         vga_hs <= '1;
      else
         vga_hs <= current_state != STATE_HS_PULSE;
   end
   
endmodule: vga_horiz_fsm
