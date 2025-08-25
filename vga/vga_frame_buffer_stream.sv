

module vga_frame_buffer_stream
   import vga_pkg::*;
#(
   MM_ADDR_WIDTH        = MM_MEM_ADDR_WIDTH,
   MM_DATA_WIDTH        = MM_MEM_DATA_WIDTH,
   MM_START_ADDRESS     = 'h400_0000,
   MM_FRAME_SIZE        = WIDTH * HEIGHT * FB_PIXEL_WIDTH / 8, // Frame size in bytes
   FIFO_SIZE            = 5 * WIDTH,                           // Fifo size in words, cache a couple of lines
   FIFO_SIZE_WIDTH      = $clog2(FIFO_SIZE + 1),
	ST_EMPTY_WIDTH			= $clog2(MM_DATA_WIDTH/8 + 1)
)
(
   input  logic clk,
   input  logic reset,
   
   // SDRAM Avalon MM Master signals
   output logic                       mm_mem_read,
   output logic [MM_ADDR_WIDTH-1:0]   mm_mem_address,
   output logic [MM_DATA_WIDTH/8-1:0] mm_mem_byteenable,
   input  logic [MM_DATA_WIDTH-1:0]   mm_mem_readdata,
   input  logic                       mm_mem_waitrequest,
   input  logic                       mm_mem_readdatavalid,

   // Avalon MM Slave signals for CSR interface:
   // Word offset @VGA_STREAM_RESTART_REG:
   //    - bit 0: start a new frame when asserted

   input  logic                         mm_csr_write,
   input  logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address,
   input  logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata,
   output logic                         mm_csr_waitrequest,
   
   // Avalon ST source interface
   input  logic                      st_ready,
   output logic [MM_DATA_WIDTH-1:0]  st_data,
   output logic                      st_startofpacket,
   output logic                      st_endofpacket,
	output logic [ST_EMPTY_WIDTH-1:0] st_empty,
   output logic                      st_valid
);
   localparam MM_MAX_PENDING_READS = 50;   // Must match the Avalon IP configuration

   localparam MM_FIFO_DATA_WIDTH = $bits(prefetcher_fifo_item_t);

   logic                          fifo_rden;
   logic [MM_FIFO_DATA_WIDTH-1:0] fifo_rddata;
   logic                          fifo_rddata_valid;

   logic                          fifo_wren;
   logic [MM_FIFO_DATA_WIDTH-1:0] fifo_wrdata;
   logic [FIFO_SIZE_WIDTH-1:0]    fifo_num_free;

   logic restart_frame;    // Asserted for one cycle when prefetch needs to restart from MM_START_ADDRESS

   // Process restart frame request via Avalon MM Slave interface
   assign mm_csr_waitrequest = '0;

   always_ff @(posedge clk)
   begin: restart_frame_update
      if (reset) begin
         restart_frame   <= '0;
      end
      else begin
         restart_frame <= '0; // clear by default
         if (mm_csr_write && mm_csr_address == VGA_STREAM_RESTART_REG && mm_csr_writedata[0]) begin
            restart_frame <= '1;
         end
      end
   end

   // Set up memory prefetch buffer and prefetch module
   fifo #(
      .SIZE(FIFO_SIZE),
      .DATA_WIDTH(MM_FIFO_DATA_WIDTH),
      .SIZE_WIDTH(FIFO_SIZE_WIDTH)
   ) fifo_0(
      .clk,
      .reset,
      .rden(fifo_rden),
      .rddata(fifo_rddata),
      .rddata_valid(fifo_rddata_valid),
      .wren(fifo_wren),
      .wrdata(fifo_wrdata),
      .num_free(fifo_num_free)
   );

   vga_frame_buffer_prefetch #(
      .MM_DATA_WIDTH(MM_DATA_WIDTH),
      .MM_START_ADDRESS(MM_START_ADDRESS),
      .MM_FRAME_SIZE(MM_FRAME_SIZE),
      .MAX_PENDING_READS(MM_MAX_PENDING_READS),
      .FIFO_SIZE_WIDTH(FIFO_SIZE_WIDTH)
   ) vga_frame_buffer_prefetch_0(
      .clk,
      .reset,
      .start(restart_frame),
      .address_wr(1'b0),
      .address('0),    // unused
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_readdata(mm_mem_readdata),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdatavalid(mm_mem_readdatavalid),
      .fifo_wren,
      .fifo_wrdata,
      .fifo_num_free(fifo_num_free)
   );

   // Map FIFO signals to Avalon ST interface
   prefetcher_fifo_item_t fifo_rddata_record;
   assign fifo_rddata_record = fifo_rddata;

   assign fifo_rden        = st_ready;
   assign st_data          = fifo_rddata_record.data;
   assign st_startofpacket = fifo_rddata_record.startofpacket;
   assign st_endofpacket   = fifo_rddata_record.endofpacket;
	assign st_empty			= fifo_rddata_record.endofpacket ? ST_EMPTY_WIDTH'(MM_DATA_WIDTH / 8) : '0;
   assign st_valid         = fifo_rddata_valid;

endmodule: vga_frame_buffer_stream
