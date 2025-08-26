
module vga_vert_fsm
   import vga_pkg::*;
(
   input  logic clk,             // 25Mhz for 640x480 at 60Hz refresh rate
   input  logic reset,
   input  logic vga_hs,          // VGA HSYNC signal to synchronize with
   output logic vga_vs,          // VGA VSYNC signal
   output logic addr_y_valid,    // pixel in addr_y needs to be displayed
   output logic [ADDR_Y_WIDTH-1:0] addr_y     // pixel to display
);

   localparam int unsigned LINE = 800;
   localparam int unsigned VS_PULSE = 2 * LINE;
   localparam int unsigned BACK_PORCH = 33 * LINE;
   localparam int unsigned LINES = 480 * LINE;
   localparam int unsigned FRONT_PORCH = 10 * LINE;
   localparam int unsigned FRAME = VS_PULSE + BACK_PORCH + LINES + FRONT_PORCH;

   typedef enum logic [1:0] {
      STATE_VS_PULSE,
      STATE_BACK_PORCH,
      STATE_LINES,
      STATE_FRONT_PORCH
   } state_t;

   state_t current_state, next_state;
   
   localparam int unsigned COUNTER_WIDTH = $clog2(FRAME);

   logic [COUNTER_WIDTH-1:0] counter;
   
   always_ff @(posedge clk)
   begin: counter_update
      if (reset) begin
         counter <= '0;
      end
      else begin
         counter <= counter + COUNTER_WIDTH'(1);
         if (counter == FRAME - 1)
            counter <= '0;
      end
   end

   always_comb
   begin: state_table
      case (current_state)
         STATE_VS_PULSE:
            begin
               if (counter == VS_PULSE - 1)
                  next_state = STATE_BACK_PORCH;
               else
                  next_state = STATE_VS_PULSE;
             end
         STATE_BACK_PORCH:
            begin
               if (counter == VS_PULSE + BACK_PORCH - 1)
                  next_state = STATE_LINES;
               else
                  next_state = STATE_BACK_PORCH;
            end
         STATE_LINES:
            begin
               if (counter == VS_PULSE + BACK_PORCH + LINES - 1)
                  next_state = STATE_FRONT_PORCH;
               else
                  next_state = STATE_LINES;
            end
         STATE_FRONT_PORCH:
            begin
               if (counter == FRAME - 1)
                  next_state = STATE_VS_PULSE;
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
         current_state <= STATE_VS_PULSE;
      end
      else begin
         current_state <= next_state;
      end
   end

   always_ff @(posedge clk)
   begin: address_output
      logic vga_hs_last;   // remember last hsync state to check for neg edge

      if (reset) begin
         addr_y_valid <= '0;
         addr_y <= -(ADDR_Y_WIDTH'(1));
      end
      else if (current_state == STATE_LINES) begin
         // Move to next line on hsync pos edge
         if (~vga_hs_last & vga_hs) begin
            addr_y_valid <= '1;
            addr_y <= addr_y + ADDR_Y_WIDTH'(1);
         end
      end
      else begin
         addr_y_valid <= '0;
         addr_y <= -(ADDR_Y_WIDTH'(1));
      end
      
      vga_hs_last <= vga_hs;
   end
   
   always_ff @(posedge clk)
   begin: vga_vsync_output
      if (reset)
         vga_vs <= '1;
      else
         vga_vs <= current_state != STATE_VS_PULSE;
   end
   
endmodule: vga_vert_fsm
