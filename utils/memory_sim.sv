
// synthesis translate_off

`timescale 1ns/1ns

module memory_sim
#(
   MEM_ADDR_WIDTH    = 32,
   MEM_DATA_WIDTH    = 16,
   MEM_SIZE          = 128,   // Memory size in bytes
   MEM_READ_LATENCY  = 6,     // Minimum latency for the first read of a burst
   MAX_PENDING_READS = 4,
   MEM_BASE_ADDRESS  = 0,
   MEM_INIT_OFFSET   = 0,
   string MEM_INIT_FILE = ""
)
(
   input  logic clk,
   input  logic reset,

   // SDRAM Avalon MM Master signals
   input  logic                        mm_read,
   input  logic [MEM_ADDR_WIDTH-1:0]   mm_address,
   input  logic [MEM_DATA_WIDTH/8-1:0] mm_byteenable,
   output logic [MEM_DATA_WIDTH-1:0]   mm_readdata,
   output logic                        mm_waitrequest,
   output logic                        mm_readdatavalid
);
   localparam MEM_BYTES_PER_WORD = MEM_DATA_WIDTH / 8;
   localparam MEM_SIZE_BY_WORD = MEM_SIZE / MEM_BYTES_PER_WORD;
   localparam MEM_ADDR_SHIFT = MEM_BYTES_PER_WORD == 1 ? 0 : $clog2(MEM_BYTES_PER_WORD);

   logic [MEM_DATA_WIDTH-1:0] memory[0:MEM_SIZE_BY_WORD-1];

   logic fifo_rden;
   logic [MEM_DATA_WIDTH-1:0] fifo_rddata;
   logic fifo_rddone;

   logic fifo_wren;
   logic [MEM_DATA_WIDTH-1:0] fifo_wrdata;
   logic fifo_wrdone;
   logic fifo_empty;
   
   initial
   begin
      if (MEM_INIT_FILE.len() == 0) begin
         $display("Initializing sim memory using counter");
         for (int i = 0; i < MEM_SIZE_BY_WORD; i = i + 1)
            memory[i] = MEM_INIT_OFFSET + MEM_DATA_WIDTH'(i);
      end
      else begin
         $display("Initializing sim memory using file: %s", MEM_INIT_FILE);
         $readmemh(MEM_INIT_FILE, memory);
      end
   end

   fifo #(
      .SIZE(MAX_PENDING_READS),
      .DATA_WIDTH(MEM_DATA_WIDTH)
   ) fifo0(
      .clk,
      .reset,
      .rden(fifo_rden),
      .rddata(fifo_rddata),
      .rddone(fifo_rddone),
      .wren(fifo_wren),
      .wrdata(fifo_wrdata),
      .wrdone(fifo_wrdone),
      .empty(fifo_empty)
   );

   // Process read request
   wire [MEM_ADDR_WIDTH-1:0] mm_word_address = (mm_address - MEM_ADDR_WIDTH'(MEM_BASE_ADDRESS)) >> MEM_ADDR_SHIFT;
   assign mm_waitrequest = !fifo_wrdone;
   assign fifo_wren = mm_read;
   assign fifo_wrdata = memory[mm_word_address];
   
   // Drain Fifo and produce output, with a delay
   logic [$clog2(MEM_READ_LATENCY+1)-1:0] read_delay, read_delay_next;

   always_comb
   begin: next_read_delay
      if (fifo_empty) 
         read_delay_next = MEM_READ_LATENCY;
      else
         read_delay_next = read_delay != '0 ? read_delay - 1'b1 : read_delay;
   end

   always_ff @(posedge clk)
   begin: read_delay_update
      if (reset)
         read_delay <= MEM_READ_LATENCY;
      else 
         read_delay <= read_delay_next;
   end
   
   always_ff @(posedge clk)
   begin
      fifo_rden <= read_delay_next == '0;    // read with a delay
   end

   assign mm_readdatavalid = fifo_rddone;
   assign mm_readdata = fifo_rddata;

endmodule: memory_sim

// synthesis translate_on
