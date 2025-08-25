
// synthesis translate_off

`timescale 1ns/1ns

module vga_frame_buffer_mux_tb;
   import vga_pkg::*;

   localparam T = 10;

	localparam NUM_SOURCES = 4;
	localparam ST_EMPTY_WIDTH = $clog2(MM_MEM_DATA_WIDTH/8 + 1);

	localparam FRAME_BUFFER_SIZE = 32;	// Length of the shortest frame buffer input in words, excluding end of packet

   logic clk;
   logic reset;

	// Frame buffer mux CSR slave interface
   logic                         mm_slave_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_slave_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_slave_csr_writedata;
   logic                         mm_slave_csr_waitrequest;

   // CSR interface for frame buffer sources
   logic                         mm_master_csr_write;
   logic [MM_MEM_ADDR_WIDTH-1:0] mm_master_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_master_csr_writedata;
   logic                         mm_master_csr_waitrequest;

   // Avalon ST source interface for the mux output
   logic                          st_source_ready;
   logic [MM_MEM_DATA_WIDTH-1:0]  st_source_data;
   logic                          st_source_startofpacket;
   logic                          st_source_endofpacket;
	logic [ST_EMPTY_WIDTH-1:0]     st_source_empty;
   logic                          st_source_valid;

   // Avalon ST sink interfaces for the frame buffer sources
   logic                          st_sink_ready[NUM_SOURCES];
   logic [MM_MEM_DATA_WIDTH-1:0]  st_sink_data[NUM_SOURCES];
   logic                          st_sink_startofpacket[NUM_SOURCES];
   logic                          st_sink_endofpacket[NUM_SOURCES];
	logic [ST_EMPTY_WIDTH-1:0]     st_sink_empty[NUM_SOURCES];
   logic                          st_sink_valid[NUM_SOURCES];

	// Module to provide streaming data with customizable size and a non-zero data value 
	// for the given span
	module frame_buffer_source_sim
	#(
		SIZE 				= FRAME_BUFFER_SIZE,	// Number of words to produce, plus one for end of packet
		DATA_START_IDX = 0,						// First index of output from which to produce DATA instead of zero
		DATA_END_IDX   = 0,						// Last index of output to produce DATA instead of zero
		DATA_VALUE		= 0						// Data to produce between [DATA_START_IDX, DATA_END_IDX]
	)
	(
		input logic clk,
		input logic reset,
		
		input logic                          st_sink_ready,
		output logic [MM_MEM_DATA_WIDTH-1:0] st_sink_data,
		output logic                         st_sink_startofpacket,
		output logic                         st_sink_endofpacket,
		output logic [ST_EMPTY_WIDTH-1:0]    st_sink_empty,
		output logic                         st_sink_valid
	);
		logic [$clog2(SIZE + 1)-1:0] index;

		logic st_sink_valid_tmp;
		assign st_sink_valid = st_sink_valid_tmp;

		always_ff @(posedge clk)
		begin: update_sink_valid

			if (reset) begin
				st_sink_valid_tmp <= 1'b1;
			end
			else begin
				st_sink_valid_tmp <= 1 < ({$random()} % 10);
			end
		end
		
		always_ff @(posedge clk)
		begin
			if (reset)
				index <= '0;
			else if (st_sink_valid_tmp && st_sink_ready) begin
				index <= index == SIZE ? '0 : index + 1'b1;
			end
		end
		
		assign st_sink_data = DATA_START_IDX <= index && index <= DATA_END_IDX ? MM_MEM_DATA_WIDTH'(DATA_VALUE) : '0;
		assign st_sink_startofpacket = index == '0;
		assign st_sink_endofpacket = index == SIZE;
		assign st_sink_empty = st_sink_endofpacket ? ST_EMPTY_WIDTH'(MM_MEM_DATA_WIDTH) / 8 : '0;

	endmodule: frame_buffer_source_sim
	
	for (genvar i = 0; i < NUM_SOURCES; i = i + 1) begin: inputs
		frame_buffer_source_sim #(
			.SIZE(FRAME_BUFFER_SIZE + 2 * i),					// to test behaviour with different frame buffer lengths
			.DATA_START_IDX(10 + 2 * i),
			.DATA_END_IDX(10 + 2 * NUM_SOURCES - 1),
			.DATA_VALUE(i + 1)
		) frame_buffer_source_sim0(
			.clk,
			.reset,
			.st_sink_ready(st_sink_ready[i]),
			.st_sink_data(st_sink_data[i]),
			.st_sink_startofpacket(st_sink_startofpacket[i]),
			.st_sink_endofpacket(st_sink_endofpacket[i]),
			.st_sink_empty(st_sink_empty[i]),
			.st_sink_valid(st_sink_valid[i])
		);
	end

	vga_frame_buffer_mux #(
		.MM_CSR_ADDRESS_SOURCE0(0),
		.MM_CSR_ADDRESS_SOURCE1(1),
		.MM_CSR_ADDRESS_SOURCE2(2),
		.MM_CSR_ADDRESS_SOURCE3(3)
	) vga_frame_buffer_mux0(
		.clk,
		.reset,

		// Avalon MM CSR Slave
		.mm_slave_csr_write,
		.mm_slave_csr_address,
		.mm_slave_csr_writedata,
		.mm_slave_csr_waitrequest,

		// Avalon MM CSR Master
		.mm_master_csr_write,
		.mm_master_csr_address,
		.mm_master_csr_writedata,
		.mm_master_csr_waitrequest,

		// Avalon ST source
		.st_source_ready,
		.st_source_data,
		.st_source_startofpacket,
		.st_source_endofpacket,
		.st_source_empty,
		.st_source_valid,

		// Avalon ST sink0
		.st_sink0_ready(st_sink_ready[0]),
		.st_sink0_data(st_sink_data[0]),
		.st_sink0_startofpacket(st_sink_startofpacket[0]),
		.st_sink0_endofpacket(st_sink_endofpacket[0]),
		.st_sink0_empty(st_sink_empty[0]),
		.st_sink0_valid(st_sink_valid[0]),

		// Avalon ST sink1
		.st_sink1_ready(st_sink_ready[1]),
		.st_sink1_data(st_sink_data[1]),
		.st_sink1_startofpacket(st_sink_startofpacket[1]),
		.st_sink1_endofpacket(st_sink_endofpacket[1]),
		.st_sink1_empty(st_sink_empty[1]),
		.st_sink1_valid(st_sink_valid[1]),

		// Avalon ST sink2
		.st_sink2_ready(st_sink_ready[2]),
		.st_sink2_data(st_sink_data[2]),
		.st_sink2_startofpacket(st_sink_startofpacket[2]),
		.st_sink2_endofpacket(st_sink_endofpacket[2]),
		.st_sink2_empty(st_sink_empty[2]),
		.st_sink2_valid(st_sink_valid[2]),

		// Avalon ST sink3
		.st_sink3_ready(st_sink_ready[3]),
		.st_sink3_data(st_sink_data[3]),
		.st_sink3_startofpacket(st_sink_startofpacket[3]),
		.st_sink3_endofpacket(st_sink_endofpacket[3]),
		.st_sink3_empty(st_sink_empty[3]),
		.st_sink3_valid(st_sink_valid[3])
	);

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end
	
	task automatic frame_restart();

		$info("Sending frame restart request");

		@(posedge clk);
		mm_slave_csr_write     <= '1;
		mm_slave_csr_address   <= VGA_STREAM_RESTART_REG;
		mm_slave_csr_writedata <= 1'b1;

		@(posedge clk);

		// Check writes to the first NUM_SOURCES - 1 addresses
		for (int i = 0; i < NUM_SOURCES; ++i) begin
			@(posedge clk);

			assert (mm_master_csr_write) else $error("frame buffer mux should be writing to CSR registers");
			assert (mm_master_csr_address == i) else $error("incorrect CSR write address");
			assert (mm_master_csr_writedata == 1) else $error("incorrect CSR write data");
			assert (mm_slave_csr_waitrequest) else $error("slave should be paused while write is in progress");

			// Force last write transaction to wait for a few cycles
			if (i == NUM_SOURCES - 2)
				mm_master_csr_waitrequest <= '1;
		end
		
		for (int i = 0; i < 3; ++i) begin
			@(posedge clk);

			assert (mm_master_csr_write) else $error("frame buffer mux should be writing to CSR registers");
			assert (mm_master_csr_address == NUM_SOURCES - 1) else $error("incorrect CSR write address");
			assert (mm_master_csr_writedata == 1) else $error("incorrect CSR write data");
			assert (mm_slave_csr_waitrequest) else $error("slave should be paused while write is in progress");
		end
		mm_master_csr_waitrequest <= '0;
		@(posedge clk);
		assert (mm_master_csr_write) else $error("frame buffer mux should still be writing to CSR registers");

		@(posedge clk);
		assert (!mm_master_csr_write) else $error("write should have finished to frame buffer sources");
		assert (!mm_slave_csr_waitrequest) else $error("full write transaction should have finished");
		mm_slave_csr_write <= '0;

	endtask: frame_restart

	task automatic check_frame;
		int data_index;

		$info("Checking frame");

		@(posedge clk);
		st_source_ready <= '1;

		data_index = 0;
		for (int i = 0; i < FRAME_BUFFER_SIZE + 1; i = i + 1) begin
			@(posedge clk iff st_source_valid)
			begin
				int expected_data;

				assert((data_index != 0) ^ st_source_startofpacket) else $error("startofpacket incorrect");
				assert((data_index != FRAME_BUFFER_SIZE) ^ st_source_endofpacket) else $error("startofpacket incorrect");
				
				if (10 <= data_index && data_index < 10 + 2 * NUM_SOURCES)
					expected_data = (data_index - 10) / 2 + 1;
				else
					expected_data  = 0;

				assert(st_source_data == expected_data)
					else $error("incorrect data received, index: %d, expected: %d, received: %d",
									data_index, expected_data, st_source_data);
				data_index = data_index + 1;
			end
			
			// Switch off source readiness a couple of times randomly
			if (7 < ({$random()} % 10)) begin
				st_source_ready <= '0;
				#(2*T);
				@(posedge clk) st_source_ready <= '1;
			end
		end
	endtask: check_frame

	initial
   begin: test_cases
		st_source_ready <= '0;

		mm_slave_csr_write        <= '0;
		mm_slave_csr_address      <= '0;
		mm_slave_csr_writedata    <= '0;
		mm_master_csr_waitrequest <= '0;
		reset 						  <= '1;

		#(T) reset <= '0;
		
		frame_restart();

		check_frame();

      #(5*T);

		frame_restart();

		// Stop after a few cycles
		#(FRAME_BUFFER_SIZE*T / 2);
		
		$info("Stopping frame during display");
		frame_restart();

		// Wait till end of frame and check frame again
		st_source_ready <= 1'b1;
		@(posedge clk iff st_source_valid && st_source_endofpacket) begin
			st_source_ready <= 1'b0;
		end
		
		// Check new frame again
		check_frame();

		#(5*T);
      $stop;
   end
	
endmodule: vga_frame_buffer_mux_tb

// synthesis translate_on
