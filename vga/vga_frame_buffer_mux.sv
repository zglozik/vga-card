

module vga_frame_buffer_mux
   import vga_pkg::*;
#(
	// Each framebuffer sink input needs to have an associated CSR address for frame restart requests
	MM_CSR_ADDRESS_SOURCE0 = 0,
	MM_CSR_ADDRESS_SOURCE1 = 0,
	MM_CSR_ADDRESS_SOURCE2 = 0,
	MM_CSR_ADDRESS_SOURCE3 = 0,

	MM_DATA_WIDTH  = MM_MEM_DATA_WIDTH,				// Avalon ST Source data width
	ST_EMPTY_WIDTH	= $clog2(MM_DATA_WIDTH/8 + 1)
)
(
   input  logic clk,
   input  logic reset,
   
   // Avalon MM Slave signals for CSR interface:
   // Word offset VGA_STREAM_RESTART_REG:
   //    - bit 0: start a new frame when asserted
   input  logic                         mm_slave_csr_write,
   input  logic [MM_CSR_ADDR_WIDTH-1:0] mm_slave_csr_address,
   input  logic [MM_CSR_DATA_WIDTH-1:0] mm_slave_csr_writedata,
   output logic                         mm_slave_csr_waitrequest,

   // Avalon MM Master signals for CSR interface to source frame buffer.
	// This module will fan out incoming write transations to all frame buffer source addresses.
   output logic                         mm_master_csr_write,
   output logic [MM_MEM_ADDR_WIDTH-1:0] mm_master_csr_address,
   output logic [MM_CSR_DATA_WIDTH-1:0] mm_master_csr_writedata,
   input  logic                         mm_master_csr_waitrequest,
   
   // Avalon ST source interface for the output
   input  logic                      st_source_ready,
   output logic [MM_DATA_WIDTH-1:0]  st_source_data,
   output logic                      st_source_startofpacket,
   output logic                      st_source_endofpacket,
	output logic [ST_EMPTY_WIDTH-1:0] st_source_empty,
   output logic                      st_source_valid,

   // Avalon ST sink interfaces, one for each frame buffer input source
	
	// sink0
   output logic                      st_sink0_ready,
   input  logic [MM_DATA_WIDTH-1:0]  st_sink0_data,
   input  logic                      st_sink0_startofpacket,
   input  logic                      st_sink0_endofpacket,
	input  logic [ST_EMPTY_WIDTH-1:0] st_sink0_empty,
   input  logic                      st_sink0_valid,

	// sink1
   output logic                      st_sink1_ready,
   input  logic [MM_DATA_WIDTH-1:0]  st_sink1_data,
   input  logic                      st_sink1_startofpacket,
   input  logic                      st_sink1_endofpacket,
	input  logic [ST_EMPTY_WIDTH-1:0] st_sink1_empty,
   input  logic                      st_sink1_valid,

	// sink0
   output logic                      st_sink2_ready,
   input  logic [MM_DATA_WIDTH-1:0]  st_sink2_data,
   input  logic                      st_sink2_startofpacket,
   input  logic                      st_sink2_endofpacket,
	input  logic [ST_EMPTY_WIDTH-1:0] st_sink2_empty,
   input  logic                      st_sink2_valid,

	// sink0
   output logic                      st_sink3_ready,
   input  logic [MM_DATA_WIDTH-1:0]  st_sink3_data,
   input  logic                      st_sink3_startofpacket,
   input  logic                      st_sink3_endofpacket,
	input  logic [ST_EMPTY_WIDTH-1:0] st_sink3_empty,
   input  logic                      st_sink3_valid
);
	localparam NUM_SOURCES = 4;
	localparam int unsigned MM_CSR_ADDRESSES[NUM_SOURCES] = '{
		MM_CSR_ADDRESS_SOURCE0,
		MM_CSR_ADDRESS_SOURCE1,
		MM_CSR_ADDRESS_SOURCE2,
		MM_CSR_ADDRESS_SOURCE3
	};

	// Map individual sink ports to array elements
	logic 						  st_sink_ready[NUM_SOURCES];
   logic [MM_DATA_WIDTH-1:0] st_sink_data[NUM_SOURCES];
	logic 						  st_sink_endofpacket[NUM_SOURCES];
   logic 						  st_sink_valid[NUM_SOURCES];

	assign {st_sink0_ready, st_sink1_ready, st_sink2_ready, st_sink3_ready} = {st_sink_ready[0], st_sink_ready[1], st_sink_ready[2], st_sink_ready[3]};
   assign st_sink_data        = '{st_sink0_data,          st_sink1_data,          st_sink2_data,          st_sink3_data};
   assign st_sink_endofpacket = '{st_sink0_endofpacket,   st_sink1_endofpacket,   st_sink2_endofpacket,   st_sink3_endofpacket};
   assign st_sink_valid 		= '{st_sink0_valid,         st_sink1_valid,         st_sink2_valid,         st_sink3_valid};

	// Function to select the highest numbered layer with non-zero pixel value
	function automatic logic [MM_DATA_WIDTH-1:0] select_layer(
		input logic [MM_DATA_WIDTH-1:0]  data[NUM_SOURCES]
	);
		// Default to layer 0, otherwise the highest index non-zero input will be selected
		select_layer = data[0];
		for (int i = 1; i < NUM_SOURCES; i = i + 1) begin
			if (data[i] != '0) begin
				select_layer = data[i];
			end
		end
	endfunction: select_layer
	
	// Implement CSR write fan-out
	typedef enum logic [1:0] {
		IDLE,				// Waiting for write request on MM Slave interface
		WRITING,			// Write to frame buffer sources is in progress
		FINISH_WRITE	// One-cycle delay for initiator to deassert write when all sources have been written to
	} mm_csr_state_t;

	mm_csr_state_t mm_csr_current_state, mm_csr_next_state;
	
	// Register to keep track of which frame buffer we are currently writing to
	logic [$clog2(NUM_SOURCES)-1:0] mm_csr_index;	
	
	always_comb
	begin: mm_csr_state_update
		mm_csr_next_state = mm_csr_current_state;
		case (mm_csr_current_state)
			IDLE:
				// Process only frame restart write requests
				if (mm_slave_csr_write) begin
					mm_csr_next_state = mm_slave_csr_address == VGA_STREAM_RESTART_REG && mm_slave_csr_writedata[0]
											  ? WRITING : FINISH_WRITE;
			   end
			WRITING:
				// Finish write when all frame buffer sources have been written to
				if (!mm_master_csr_waitrequest && mm_csr_index == NUM_SOURCES - 1)
					mm_csr_next_state = FINISH_WRITE;
			FINISH_WRITE:
				mm_csr_next_state  = IDLE;
			default:
				; // no-op
		endcase
	end

	always_ff @(posedge clk)
	begin: mm_csr_index_update
		if (reset || mm_csr_current_state == IDLE)
			mm_csr_index <= '0;
		else if (mm_csr_current_state == WRITING) begin
			// Move to the next frame buffer source when current write has finished
			if (!mm_master_csr_waitrequest)
				mm_csr_index <= mm_csr_index + 1'b1;
		end
	end

	always_comb
	begin: mm_csr_write_select
		mm_master_csr_write     = mm_csr_current_state == WRITING;
		mm_master_csr_address   = MM_MEM_ADDR_WIDTH'(MM_CSR_ADDRESSES[mm_csr_index]);
		mm_master_csr_writedata = mm_slave_csr_writedata;
	end

	// Write initiator needs to hold its signals throughout the writing phase only
	assign mm_slave_csr_waitrequest = mm_csr_current_state == IDLE || mm_csr_current_state == WRITING;

	always_ff @(posedge clk)
   begin: mm_csr_state_transition
      if (reset)
         mm_csr_current_state <= IDLE;
      else
         mm_csr_current_state <= mm_csr_next_state;
   end
	
	// Merge all frame buffer input sources into one Avalon ST output, non-zero input from highest numbered input source takes priority

	// FSM for producing one heartbeat on Avalon ST source for each pixel of the display
   typedef enum logic [2:0] {
      WAIT,           		// Wait for frame start signal
      START,          		// One cycle state to initialize state for a new frame display
      DISPLAY,        		// Produce frame, one pixel output each cycle when source is ready
		RESTART_WAIT,     	// Frame restart request was received over the CSR interface, wait until all sources have been written to
      DRAIN_SOURCES,   		// Read till end of packet from all sources in preparation for new frame
      CLOSE_PACKET,    		// Output end of packet marker on Avalon ST interface
		CLOSE_WAIT				// Wait until end of packet has been consumed from source
   } frame_buffer_state_t;
   
   frame_buffer_state_t fb_current_state, fb_next_state;

	wire restarting = mm_csr_current_state == WRITING;
	logic start_reg;

   always_ff @(posedge clk)
   begin: start_update
      if (reset)
         start_reg <= 1'b0;
      else begin
			if (fb_current_state == START) begin
				start_reg <= 1'b0;
			end
			else if (restarting) begin
				// Remember that we need to start when current frame is finished
				start_reg <= 1'b1;
			end
      end
   end

	// Set to true when the output packet has started and it will need an end of packet
	logic packet_started;

	// Keep track of which sink has reached end of packet when displaying frame
	logic sink_done[NUM_SOURCES];

	// Check if we have a valid data input (not end of packet) on all sinks at the same time
	wire all_sinks_valid_data = st_sink_valid.and() && !st_sink_endofpacket.or();

	// source_rddone will be asserted if the data in source, if any, will be read in current cycle,
	// i.e. source is ready to accept a new output in this cycle.
	logic st_source_valid_tmp;
	assign st_source_valid = st_source_valid_tmp;
	wire source_rddone = !st_source_valid_tmp || st_source_ready;

	// Register array to keep last record read from each frame buffer source during display
	logic [MM_DATA_WIDTH-1:0] st_sink_buffer[NUM_SOURCES];
	logic st_sink_buffer_valid;

	// sink_rddone is asserted when sink buffer is either empty, or its content will be transferred
	// to the source buffer in current cycle, so it is ready to take a new pixel data
	wire sink_rddone = !st_sink_buffer_valid || source_rddone;

	// When we reach end of packet at least in one of the sinks, we discard all other input and finish the frame,
	// but only if all previously buffered data has been consumed
	logic endofpacket_reached;
	always_comb
	begin: endofpacket_check
		endofpacket_reached = 1'b0;
		for (int i = 0; i < NUM_SOURCES; i = i + 1) begin
			if (st_sink_valid[i] && st_sink_endofpacket[i])
				endofpacket_reached = 1'b1;
		end
		// Also check that no more pending data in output buffers
		endofpacket_reached = endofpacket_reached && !st_sink_buffer_valid && source_rddone;
	end
	
	always_comb
	begin: fb_state_update
		fb_next_state = fb_current_state;
		case (fb_current_state)
			WAIT:
				if (start_reg)
					fb_next_state = START;
			START:
				if (!restarting)
					fb_next_state = DISPLAY;
			DISPLAY:
				if (restarting)
					fb_next_state = RESTART_WAIT;
				else if (endofpacket_reached)
					fb_next_state = DRAIN_SOURCES;
			RESTART_WAIT:
				if (!restarting)
					fb_next_state = DRAIN_SOURCES;
			DRAIN_SOURCES:
				if (sink_done.and())
					fb_next_state = packet_started ? CLOSE_PACKET : WAIT;
			CLOSE_PACKET:
				fb_next_state = CLOSE_WAIT;
			CLOSE_WAIT:
				if (st_source_ready)
					fb_next_state = WAIT;
			default:
				; // no-op
		endcase
	end

	logic st_sink_ready_tmp;

	always_comb
	begin: sink_ready_update
		st_sink_ready_tmp = 1'b0;
		st_sink_ready = '{default: 1'b0};
		case (fb_current_state)
			DISPLAY:
				begin
					// Read sinks in sync, only when all of them are ready, not end of packet and we can store it in st_sink_buffer
					st_sink_ready_tmp = all_sinks_valid_data && sink_rddone;
					st_sink_ready = '{default: st_sink_ready_tmp};
				end
			DRAIN_SOURCES:
				for (int i = 0; i < NUM_SOURCES; i = i + 1) begin
					// Read until end of packet is received on all sinks
					st_sink_ready[i] = !sink_done[i];
				end
			default:
				; // no-op
		endcase
	end

	always_ff @(posedge clk)
	begin: sink_read
		if (reset) begin
			sink_done				<= '{default: '0};
			st_sink_buffer       <= '{default: '0};
			st_sink_buffer_valid <= 1'b0;
		end
		else begin
			case (fb_current_state)
				START:
					begin
						sink_done				<= '{default: '0};
						st_sink_buffer       <= '{default: '0};
						st_sink_buffer_valid <= 1'b0;
					end
				DISPLAY:
					begin
						if (st_sink_ready_tmp) begin
							// All sinks have valid data and we have space in st_sink_buffer, store it
							st_sink_buffer       <= st_sink_data;
							st_sink_buffer_valid <= 1'b1;
						end
						else if (source_rddone) begin
							// No new input, but data can move out of st_sink_buffer to st_source (if any), invalidate
							st_sink_buffer_valid <= 1'b0;
						end
					end
				DRAIN_SOURCES:
					for (int i = 0; i < NUM_SOURCES; i = i + 1) begin
						if (st_sink_valid[i] && st_sink_endofpacket[i] && st_sink_ready[i])
							sink_done[i] <= 1'b1;
					end
				default:
					; // no-op
			endcase
		end
	end

	always_ff @(posedge clk)
	begin: source_write
		if (reset) begin
			packet_started          <= '0;
			st_source_data          <= '0;
			st_source_startofpacket <= '0;
			st_source_endofpacket   <= '0;
			st_source_empty         <= '0;
			st_source_valid_tmp     <= '0;
		end
		else begin
			case (fb_current_state)
				START:
					begin
						packet_started          <= '0;
						st_source_data          <= '0;
						st_source_startofpacket <= '0;
						st_source_endofpacket   <= '0;
						st_source_empty         <= '0;
						st_source_valid_tmp     <= '0;
					end
				DISPLAY:
					begin
						if (fb_next_state != DISPLAY) begin
							st_source_valid_tmp     <= 1'b0;
						end
						else if (st_sink_buffer_valid && source_rddone) begin
							// We can transfer st_sink_buffer to the source output, select the top layer with non-zero value
							st_source_data          <= select_layer(st_sink_buffer);
							st_source_startofpacket <= !st_source_valid_tmp && !packet_started;	// First output data 
							st_source_valid_tmp     <= 1'b1;
						end
						else if (st_source_ready) begin
							// Source data has been taken and no new item in sink buffer, invalidate output
							st_source_valid_tmp     <= 1'b0;
						end

						// Mark a packet started only if start of packet was consumed
						if (!packet_started && st_source_valid_tmp && st_source_ready)
							packet_started <= 1'b1;
					end
				CLOSE_PACKET:
					begin
						st_source_endofpacket <= 1'b1;
						st_source_empty       <= ST_EMPTY_WIDTH'(MM_DATA_WIDTH / 8);
						st_source_valid_tmp   <= 1'b1;
					end
				CLOSE_WAIT:
					if (st_source_ready) begin
						st_source_endofpacket <= 1'b0;
						st_source_empty       <= '0;
						st_source_valid_tmp   <= 1'b0;
						packet_started 		 <= 1'b0;
					end
				default:
					st_source_valid_tmp <= '0;	// Not really required, just in case
			endcase
		end
	end
	
	always_ff @(posedge clk)
   begin: fb_state_transition
      if (reset)
         fb_current_state <= WAIT;
      else
         fb_current_state <= fb_next_state;
   end

endmodule: vga_frame_buffer_mux
