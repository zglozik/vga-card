
module graphics_rect_move
	import vga_pkg::*, graphics_pkg::*;
#(
	MM_START_ADDRESS  = 0,  // Frame buffer start address in Avalon MM slave
	MAX_PENDING_READS = 50	// Maximum number of pending memory reads
)
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
	
	// SDRAM Avalon MM Master signals for reading memory region
   output logic                           mm_read,
   output logic [MM_MEM_ADDR_WIDTH-1:0]   mm_address,
   output logic [MM_MEM_DATA_WIDTH/8-1:0] mm_byteenable,
   input  logic                           mm_waitrequest,
   input  logic [MM_MEM_DATA_WIDTH-1:0]   mm_readdata,
   input  logic                           mm_readdatavalid,

   // Avalon ST source interface for streaming pixels to be changed in frame buffer
   input  logic                      st_ready,
   output logic [ST_DATA_WIDTH-1:0]  st_data,
   output logic                      st_valid
);
	localparam FIFO_SIZE         = MAX_PENDING_READS;
	localparam FIFO_DATA_WIDTH   = ST_DATA_WIDTH;
	localparam FIFO_SIZE_WIDTH   = $clog2(FIFO_SIZE + 1);
	localparam MM_BYTES_PER_WORD = MM_MEM_DATA_WIDTH / 8;

	// Raw input, src_point1/src_point2 can be any opposite corners of the source rectangle
   coordinate_t src_point1, src_point2, dst_point;

	// Start and end of X and Y coordinates to read, start may be left/up or right/down of end
	logic signed [COORD_DATA_WIDTH-1:0] src_start_x, src_start_y, src_end_x, src_end_y, src_x, src_y;
	
	// Where to start writing to the destination, could be on either side of the input dst_point
	logic signed [COORD_DATA_WIDTH-1:0] dst_start_x, dst_end_x, dst_x, dst_y;
	
	// Direction of memory read for X, Y coordinates, -1 or +1.
	logic signed [COORD_DATA_WIDTH-1:0] dx, dy;

   pixel_t pixel_out;

   assign mm_csr_waitrequest = 1'b0;

   // Capture rectangle points and color
   always_ff @(posedge clk)
   begin
      if (reset) begin
         src_point1 <= '0;
         src_point2 <= '0;
         dst_point  <= '0;
      end
      else if (mm_csr_write) begin
			case (mm_csr_address)
				RECT_MOVE_SRC_POINT1:
					src_point1 <= mm_csr_writedata;
				RECT_MOVE_SRC_POINT2:
					src_point2 <= mm_csr_writedata;
				RECT_MOVE_DST_POINT:
					dst_point <= mm_csr_writedata;
				default:
					; // no-op
			endcase
      end
   end

	// Output FIFO: stores destination coordinates and source pixel values read from memory source region
   logic fifo_rden;
   logic [FIFO_DATA_WIDTH-1:0] fifo_rddata;
   logic fifo_rddata_valid;
   logic fifo_wren;
   logic [FIFO_DATA_WIDTH-1:0] fifo_wrdata;
   logic fifo_wrdone;
   
   logic fifo_empty;
   logic [FIFO_SIZE_WIDTH-1:0] fifo_num_free, fifo_num_free_reg;

	fifo #(
		.SIZE(FIFO_SIZE),
		.DATA_WIDTH(FIFO_DATA_WIDTH),
		.SIZE_WIDTH(FIFO_SIZE_WIDTH)
	) fifo_0(
		.clk,
		.reset,
		.rden(fifo_rden),
		.rddata(fifo_rddata),
		.rddata_valid(fifo_rddata_valid),
		.wren(fifo_wren),
		.wrdata(fifo_wrdata),
		.wrdone(fifo_wrdone),
		.empty(fifo_empty),
		.num_free(fifo_num_free)
	);

   always_ff @(posedge clk)
   begin: fifo_num_free_update
      if (reset)
         fifo_num_free_reg <= '0;
      else
         fifo_num_free_reg <= fifo_num_free;
   end

	// Main FSM
   typedef enum logic [2:0] {
      IDLE,
      INIT_SRC_COORD1,
      INIT_SRC_COORD2,
		INIT_DST_COORD,
      READING,				// Read from memory when there is space in FIFO
		FINISH_READS,		// Wait for all reads to be finished
		DRAINING_FIFO,		// Wait until FIFO is drained by sink when no more read required
      DONE
   } state_t;
   
   state_t current_state, next_state;

	logic [FIFO_SIZE_WIDTH-1:0] num_pending_reads, num_pending_reads_with_done;
	assign num_pending_reads_with_done = num_pending_reads - mm_readdatavalid;

	logic [MM_MEM_ADDR_WIDTH-1:0] next_read_address;
	assign next_read_address = MM_MEM_ADDR_WIDTH'(MM_START_ADDRESS + (src_y * WIDTH + src_x) * MM_BYTES_PER_WORD);

	// Signal to indicate if we will issue a new memory read in current cycle in READING state only,
	// For better pipelining of reads/writes, if we are not reading yet, start reading only if FIFO is empty
	logic new_memory_read;
	assign new_memory_read = (!mm_read || !mm_waitrequest) && (mm_read || fifo_empty) && fifo_num_free_reg > num_pending_reads;

   always_comb
   begin: state_transitions
      next_state = current_state;
      case (current_state)
         IDLE:
            if (start)
               next_state = INIT_SRC_COORD1;
         INIT_SRC_COORD1:
            next_state = INIT_SRC_COORD2;
         INIT_SRC_COORD2:
            next_state = INIT_DST_COORD;
         INIT_DST_COORD:
            next_state = READING;
         READING:
				// Wait until we have just issued the last memory read required
				if (src_x == src_end_x && src_y == src_end_y && new_memory_read)
					next_state = FINISH_READS;
			FINISH_READS:
				if (num_pending_reads_with_done == '0)
					next_state = DRAINING_FIFO;
         DRAINING_FIFO:
				if (fifo_empty && clken)
					next_state = DONE;
         DONE:
				if (clken)
					next_state = IDLE;
			default:
				; // no-op
      endcase
   end

   always_ff @(posedge clk)
   begin: memory_read
      if (reset) begin
			mm_read           <= '0;
			mm_address        <= '0;
			num_pending_reads <= '0;
		end
      else begin
         case (current_state)
            READING:
					begin
						num_pending_reads <= num_pending_reads_with_done;
						if (new_memory_read) begin
							// We can issue a new read
							mm_read    		   <= '1;
							mm_address 			<= next_read_address;
							num_pending_reads <= num_pending_reads_with_done + 1'b1;
						end
						else if (!mm_waitrequest) begin
							// Can't issue new read, we need to switch off existing read, if any
							mm_read    <= '0;
							mm_address <= '0;
						end
					end
            FINISH_READS:
					begin
						num_pending_reads <= num_pending_reads_with_done;
						if (!mm_waitrequest) begin
							// Switch off last read from READING state, if any
							mm_read    <= '0;
							mm_address <= '0;
						end
					end
				default:
					; // no-op
         endcase
      end
   end

   assign mm_byteenable = '1;

	// FIFO write, we have guaranteed free slot when a memory read is done
	assign pixel_out.x       = dst_x;
	assign pixel_out.y       = dst_y;
	assign pixel_out.color   = COLOR_DATA_WIDTH'(mm_readdata);
	assign pixel_out.padding = '0;

	assign fifo_wren         = mm_readdatavalid;
	assign fifo_wrdata       = pixel_out;
	
   always_ff @(posedge clk)
   begin: update_src_coordinates
      if (reset) begin
			src_start_x <= '0;
			src_start_y <= '0;
			src_end_x   <= '0;
			src_end_y   <= '0;
			src_x		   <= '0;
			src_y			<= '0;
			dx			   <= '0;
			dy			   <= '0;
      end
      else begin
         case (current_state)
            INIT_SRC_COORD1:
               begin
                  // First ensure that start <= end
						{src_start_x, src_end_x} <= src_point1.x < src_point2.x ?
															  {src_point1.x, src_point2.x}
															: {src_point2.x, src_point1.x};

						{src_start_y, src_end_y} <= src_point1.y < src_point2.y ?
															  {src_point1.y, src_point2.y}
															: {src_point2.y, src_point1.y};
               end
            INIT_SRC_COORD2:
               begin
                  // Set up start/end points depending on which direction we need to go
						if (dst_point.x <= src_start_x) begin
							src_x       <= src_start_x;
							dx          <= COORD_DATA_WIDTH'(1);
						end
						else begin
							// Going left, swap start/end coordinates
                     src_start_x <= src_end_x;
                     src_end_x   <= src_start_x;
							src_x       <= src_end_x;
							dx          <= -(COORD_DATA_WIDTH'(1));
						end

						if (dst_point.y <= src_start_y) begin
							src_y       <= src_start_y;
							dy          <= COORD_DATA_WIDTH'(1);
						end
						else begin
							// Going up, also swap start/end coordinates
                     src_start_y <= src_end_y;
                     src_end_y   <= src_start_y;
							src_y       <= src_end_y;
							dy 			<= -(COORD_DATA_WIDTH'(1));
						end
               end
            READING:
               begin
						if (new_memory_read) begin
							// Move to next pixel
							if (src_x == src_end_x) begin
								src_x <= src_start_x;
								src_y <= src_y + dy;
							end
							else begin
								src_x <= src_x + dx;
							end
						end
               end
				default:
					; // no-op
         endcase
      end
   end

   always_ff @(posedge clk)
   begin: update_dst_coordinates
      if (reset) begin
			dst_start_x <= '0;
			dst_end_x   <= '0;
			dst_x			<= '0;
			dst_y			<= '0;
      end
      else begin
         case (current_state)
            INIT_DST_COORD:
               begin
						logic signed [COORD_DATA_WIDTH-1:0] dst_start_x_tmp, dst_start_y_tmp, dst_end_x_tmp;
						
						if (dx > 0) begin
							dst_start_x_tmp = dst_point.x;
							dst_end_x_tmp   = dst_point.x + (src_end_x - src_start_x);
						end
						else begin
							dst_start_x_tmp = dst_point.x + (src_start_x - src_end_x);
							dst_end_x_tmp   = dst_point.x;
						end
						if (dy > 0) begin
							dst_start_y_tmp = dst_point.y;
						end
						else begin
							dst_start_y_tmp = dst_point.y + (src_start_y - src_end_y);
						end

						dst_start_x <= dst_start_x_tmp;
						dst_end_x   <= dst_end_x_tmp;
						dst_x	      <= dst_start_x_tmp;
						dst_y 		<= dst_start_y_tmp;
               end
            READING,
				FINISH_READS:
					if (fifo_wrdone) begin
						// Move to next pixel for each write to the FIFO
						if (dst_x == dst_end_x) begin
							dst_x <= dst_start_x;
							dst_y <= dst_y + dy;
						end
						else begin
							dst_x <= dst_x + dx;
						end
					end
				default:
					; // no-op
         endcase
      end
   end
	
   always_ff @(posedge clk)
   begin: state_update
      if (reset)
         current_state <= IDLE;
      else
         current_state <= next_state;
   end

   // Done output update
   assign done = current_state == DONE;
   
	// Output from FIFO to Avalon ST source interface
   assign fifo_rden = clken && st_ready;
   assign st_data   = fifo_rddata;
   assign st_valid  = fifo_rddata_valid;
   
endmodule: graphics_rect_move
