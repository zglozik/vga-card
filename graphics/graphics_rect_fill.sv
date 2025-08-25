
module graphics_rect_fill
	import vga_pkg::*, graphics_pkg::*;
(
	input	logic clk,
	input logic reset,

	// Avalon MM Slave interface for providing input
   input  logic                         mm_csr_write,
   input  logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address,
   input  logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata,
   output logic                         mm_csr_waitrequest,
	
	// Operation control signals
	input	 logic clken,
	input  logic start,
	output logic done,
	
   // Avalon ST source interface for streaming pixels to be changed in frame buffer
   input  logic                      st_ready,
   output logic [ST_DATA_WIDTH-1:0]  st_data,
   output logic                      st_valid
);

   coordinate_t point1, point2, start_point, end_point;
   color_t      fill_color;
   pixel_t      pixel_out;

   assign mm_csr_waitrequest = 1'b0;

   // Capture rectangle points and color
   always_ff @(posedge clk)
   begin
      if (reset) begin
         point1     <= '0;
         point2     <= '0;
         fill_color <= '0;
      end
      else if (mm_csr_write) begin
         if (mm_csr_address == RECT_FILL_POINT1)
            point1 <= mm_csr_writedata;
         else if (mm_csr_address == RECT_FILL_POINT2) 
            point2 <= mm_csr_writedata;
         else if (mm_csr_address == RECT_FILL_COLOR)
            fill_color <= mm_csr_writedata;
      end
   end

   typedef enum logic [2:0] {
      IDLE,
      START,
      DRAWING,
      DONE
   } state_t;
   
   state_t current_state, next_state;

   always_comb
   begin: state_transitions
      next_state = current_state;
      case (current_state)
         IDLE:
            if (start)
               next_state = START;
         START:
            next_state = DRAWING;
         DRAWING:
            if (st_ready && pixel_out.x == end_point.x && pixel_out.y == end_point.y)
               next_state <= DONE;
         DONE:
            next_state = IDLE;
      endcase
   end

   always_ff @(posedge clk)
   begin
      if (reset) begin
         start_point <= '0;
         end_point   <= '0;
         pixel_out   <= '0;
      end
      else if (clken) begin
         case (current_state)
            START:
               begin
                  // Ensure start_point.x <= end_point.x
                  if (point1.x < point2.x) begin
                     start_point.x <= point1.x;
                     end_point.x   <= point2.x;
                     pixel_out.x   <= point1.x;
                  end
                  else begin
                     start_point.x <= point2.x;
                     end_point.x   <= point1.x;
                     pixel_out.x   <= point2.x;
                  end

                  // Ensure start_point.y <= end_point.y
                  if (point1.y < point2.y) begin
                     start_point.y <= point1.y;
                     end_point.y   <= point2.y;
                     pixel_out.y <= point1.y;
                  end
                  else begin
                     start_point.y <= point2.y;
                     end_point.y   <= point1.y;
                     pixel_out.y   <= point2.y;
                  end

                  // Set up fill color output
                  pixel_out.color <= fill_color.color;
               end
            DRAWING:
               begin
                  if (st_ready) begin
                     // Move to the next pixel
                     if (pixel_out.x == end_point.x) begin
                        pixel_out.x <= start_point.x;
                        pixel_out.y <= pixel_out.y + 1'b1;
                     end
                     else begin
                        pixel_out.x <= pixel_out.x + 1'b1;
                     end
                  end
               end
         endcase
      end
   end

   assign st_data = pixel_out;
   assign st_valid = clken && current_state == DRAWING && pixel_out.y <= end_point.y;

   // Done output update
   assign done = current_state == DONE;
   
   always_ff @(posedge clk)
   begin: state_update
      if (reset)
         current_state <= IDLE;
      else if (clken)
         current_state <= next_state;
   end
   
endmodule: graphics_rect_fill
