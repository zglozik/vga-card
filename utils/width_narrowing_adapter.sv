
module width_narrowing_adapter
#(
   ST_SINK_WIDTH         = 16,
	ST_SOURCE_WIDTH       = 8
)
(
   input  logic clk,
   input  logic reset,
   
   // Avalon ST sink interface
   output logic                      st_sink_ready,
   input  logic [ST_SINK_WIDTH-1:0]  st_sink_data,
   input  logic 							 st_sink_startofpacket,
   input  logic 							 st_sink_endofpacket,
	input  logic 							 st_sink_valid,

   // Avalon ST source interface
   input  logic                       st_source_ready,
   output logic [ST_SOURCE_WIDTH-1:0] st_source_data,
   output logic 							  st_source_startofpacket,
   output logic 							  st_source_endofpacket,
   output logic 							  st_source_valid
);
	// Number of symbols to produce for each input on the sink
	localparam SYMBOLS = ST_SINK_WIDTH / ST_SOURCE_WIDTH;
	localparam SYMBOLS_WIDTH = $clog2(SYMBOLS + 1);

   logic [ST_SINK_WIDTH-1:0] source_buffer;
   logic 						  source_buffer_sop;
	logic							  source_buffer_eop;

	// Number of symbols still available in source_buffer, 0 means no data available
   logic [SYMBOLS_WIDTH-1:0] symbols_ready;  
   
   initial begin
      assert(ST_SINK_WIDTH % ST_SOURCE_WIDTH == 0 && ST_SINK_WIDTH > ST_SOURCE_WIDTH)
         else $fatal("ST_SINK_WIDTH must be a multiple of ST_SOURCE_WIDTH");
   end
   
	wire symbols_available = symbols_ready != '0;
	wire symbol_consumed   = symbols_available && st_source_ready;
	wire need_symbols      = (st_source_ready && symbols_ready == 1'b1) || !symbols_available;

 	always_ff @(posedge clk)
	begin: source_buffer_update
		if (reset) begin
			source_buffer     <= '0;
			source_buffer_sop <= 1'b0;
			source_buffer_eop <= 1'b0;
			symbols_ready     <= '0;
		end
		else begin
			if (st_sink_valid && need_symbols) begin
				source_buffer     <= st_sink_data;
				source_buffer_sop <= st_sink_startofpacket;
				source_buffer_eop <= st_sink_endofpacket;
				symbols_ready     <= st_sink_endofpacket ? 1'b1 : SYMBOLS;
			end
			else if (symbol_consumed) begin
				source_buffer <= source_buffer >> ST_SOURCE_WIDTH;
				symbols_ready <= symbols_ready - 1'b1;
			end
		end
	end
	
	assign st_sink_ready = need_symbols;

	// Output generation
	assign st_source_data          = source_buffer[ST_SOURCE_WIDTH-1:0];
	assign st_source_startofpacket = source_buffer_sop && symbols_ready == SYMBOLS;
	assign st_source_endofpacket   = source_buffer_eop && symbols_ready == 1'b1;
	assign st_source_valid			 = symbols_available;

endmodule: width_narrowing_adapter
