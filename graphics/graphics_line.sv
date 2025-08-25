
module graphics_line
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

   coordinate_t line_addr_start, line_addr_end;
   color_t      line_color;
   pixel_t      pixel_out;

   assign mm_csr_waitrequest = 1'b0;

   // Capture line endpoints and color
   always_ff @(posedge clk)
   begin
      if (reset) begin
         line_addr_start    <= '0;
         line_addr_end      <= '0;
         line_color         <= '0;
      end
      else if (mm_csr_write) begin
         if (mm_csr_address == LINE_ADDR_START)
            line_addr_start <= mm_csr_writedata;
         else if (mm_csr_address == LINE_ADDR_END) 
            line_addr_end <= mm_csr_writedata;
         else if (mm_csr_address == LINE_ADDR_COLOR)
            line_color <= mm_csr_writedata;
      end
   end

   logic signed [COORD_DATA_WIDTH-1:0] x, x1, dx, xi;
   logic signed [COORD_DATA_WIDTH-1:0] y, y1, dy, yi;
   logic signed [COORD_DATA_WIDTH-1:0] D;
   logic low_slope;

   typedef enum logic [2:0] {
      IDLE,
		HORIZ_INIT_1,	// Pipelined initialize stages for horizontal drawing state
		HORIZ_INIT_2,
      DRAWING_HORIZ, // Move along X while drawing line
		VERT_INIT_1,	// Pipelined initialize stages for vertical drawing state
		VERT_INIT_2,
      DRAWING_VERT,  // Move along Y while drawing line
      DONE
   } state_t;
   
   state_t current_state, next_state;

   always_comb
   begin: state_transitions
      next_state = current_state;
      case (current_state)
         IDLE:
            if (start)
               next_state = low_slope ? HORIZ_INIT_1 : VERT_INIT_1;
			HORIZ_INIT_1:
				next_state = HORIZ_INIT_2;
			VERT_INIT_1:
				next_state = VERT_INIT_2;
			HORIZ_INIT_2:
				next_state = DRAWING_HORIZ;
			VERT_INIT_2:
				next_state = DRAWING_VERT;
         DRAWING_HORIZ:
            if (st_ready && x == x1)
               next_state = DONE;
         DRAWING_VERT:
            if (st_ready && y == y1)
               next_state = DONE;
         DONE:
            next_state = IDLE;
      endcase
   end
   
   // Avalon ST output update, line drawing, see algorithm here:
   // https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
   function automatic logic signed [COORD_DATA_WIDTH-1:0] abs(
      input logic signed [COORD_DATA_WIDTH-1:0] x);
      abs = x < 0 ? -x : x;
   endfunction: abs

   assign low_slope = abs(line_addr_end.y - line_addr_start.y) < abs(line_addr_end.x - line_addr_start.x);

   always_ff @(posedge clk)
   begin
      if (reset) begin
         x         <= '0;
         x1        <= '0;
         dx        <= '0;
         xi        <= '0;
         y         <= '0;
         y1        <= '0;
         dy        <= '0;
         yi        <= '0;
         D         <= '0;
      end
      else if (clken) begin
         case (current_state)
            HORIZ_INIT_1:
               begin
                  coordinate_t line_addr_start_tmp;
                  coordinate_t line_addr_end_tmp;
                  logic signed [COORD_DATA_WIDTH-1:0] dx_tmp, dy_tmp;
                  
						line_addr_start_tmp = line_addr_start.x < line_addr_end.x ? line_addr_start : line_addr_end;
						line_addr_end_tmp   = line_addr_start.x < line_addr_end.x ? line_addr_end : line_addr_start;

						dx_tmp = line_addr_end_tmp.x - line_addr_start_tmp.x;
						if (line_addr_start_tmp.y < line_addr_end_tmp.y) begin
							dy_tmp = line_addr_end_tmp.y - line_addr_start_tmp.y;
							yi <= COORD_DATA_WIDTH'(1);
						end
						else begin
							dy_tmp = line_addr_start_tmp.y - line_addr_end_tmp.y;
							yi <= -(COORD_DATA_WIDTH'(1));
						end

                  x  <= line_addr_start_tmp.x;
                  y  <= line_addr_start_tmp.y;
                  x1 <= line_addr_end_tmp.x;
                  y1 <= line_addr_end_tmp.y;
                  dx <= dx_tmp;
                  dy <= dy_tmp;
					end
            VERT_INIT_1:
               begin
                  coordinate_t line_addr_start_tmp;
                  coordinate_t line_addr_end_tmp;
                  logic signed [COORD_DATA_WIDTH-1:0] dx_tmp, dy_tmp;
                  
						line_addr_start_tmp = line_addr_start.y < line_addr_end.y ? line_addr_start : line_addr_end;
						line_addr_end_tmp   = line_addr_start.y < line_addr_end.y ? line_addr_end : line_addr_start;

						dy_tmp = line_addr_end_tmp.y - line_addr_start_tmp.y;
						if (line_addr_start_tmp.x < line_addr_end_tmp.x) begin
							dx_tmp = line_addr_end_tmp.x - line_addr_start_tmp.x;
							xi <= COORD_DATA_WIDTH'(1);
						end
						else begin
							dx_tmp = line_addr_start_tmp.x - line_addr_end_tmp.x;
							xi <= -(COORD_DATA_WIDTH'(1));
						end

                  x  <= line_addr_start_tmp.x;
                  y  <= line_addr_start_tmp.y;
                  x1 <= line_addr_end_tmp.x;
                  y1 <= line_addr_end_tmp.y;
                  dx <= dx_tmp;
                  dy <= dy_tmp;
					end
            HORIZ_INIT_2:
               begin
						D <= COORD_DATA_WIDTH'(2 * dy - dx);
					end
            VERT_INIT_2:
               begin
						D <= COORD_DATA_WIDTH'(2 * dx - dy);
					end
            DRAWING_HORIZ:
               begin
                  if (st_ready && x < x1) begin
                     // Move to the next pixel
                     x <= x + 1'b1;
                     if (D > 0) begin
                        y <= y + yi;
                        D <= D + COORD_DATA_WIDTH'(2 * (dy - dx));
                     end
                     else begin
                        D <= D + COORD_DATA_WIDTH'(2 * dy);
                     end
                  end
               end
            DRAWING_VERT:
               begin
                  if (st_ready && y < y1) begin
                     // Move to the next pixel
                     y <= y + 1'b1;
                     if (D > 0) begin
                        x <= x + xi;
                        D <= D + COORD_DATA_WIDTH'(2 * (dx - dy));
                     end
                     else begin
                        D <= D + COORD_DATA_WIDTH'(2 * dx);
                     end
                  end
               end
         endcase
      end
   end

   assign pixel_out.x = x;
   assign pixel_out.y = y;
   assign pixel_out.color = line_color.color;
   assign pixel_out.padding = '0;
   assign st_data = pixel_out;
   assign st_valid = clken && ((current_state == DRAWING_HORIZ && x <= x1) || (current_state == DRAWING_VERT && y <= y1));

   // Done output update
   assign done = current_state == DONE;
   
   always_ff @(posedge clk)
   begin: state_update
      if (reset)
         current_state <= IDLE;
      else if (clken)
         current_state <= next_state;
   end
   
endmodule: graphics_line
