
module vga_frame_buffer_prefetch
   import vga_pkg::*;
#(
   MM_ADDR_WIDTH     = MM_MEM_ADDR_WIDTH,
   MM_DATA_WIDTH     = MM_MEM_DATA_WIDTH,
   MM_START_ADDRESS  = 0,              // Frame buffer start address in Avalon MM slave
   MM_FRAME_SIZE     = WIDTH * HEIGHT * FB_PIXEL_WIDTH / 8, // Frame size in bytes
   MAX_PENDING_READS = 4,
   FIFO_SIZE_WIDTH   = 10
)
(
   input  logic clk,
   input  logic reset,
   
   // Start/restart prefetch from beginning of frame when asserted
   input  logic start,
   
   // To change memory base address from default
   input  logic                     address_wr,
   input  logic [MM_ADDR_WIDTH-1:0] address,
   
   // SDRAM Avalon MM Master signals
   output logic                       mm_read,
   output logic [MM_ADDR_WIDTH-1:0]   mm_address,
   output logic [MM_DATA_WIDTH/8-1:0] mm_byteenable,
   input  logic [MM_DATA_WIDTH-1:0]   mm_readdata,
   input  logic                       mm_waitrequest,
   input  logic                       mm_readdatavalid,

   // Prefetch into the FIFO below
   output logic                                     fifo_wren,
   output logic [$bits(prefetcher_fifo_item_t)-1:0] fifo_wrdata,
   input  logic [FIFO_SIZE_WIDTH-1:0]               fifo_num_free
);
   localparam MM_BYTES_PER_WORD = MM_DATA_WIDTH / 8;

   typedef enum logic [2:0] {
      WAIT,
      START,
      READING,
      FINISH_READS,
      CLOSE_PACKET
   } State;

   logic start_reg;
   logic [MM_ADDR_WIDTH-1:0] address_reg, end_address_reg;

   logic packet_started;   // Asserted when at least one word was added to the FIFO for the current frame
   logic [FIFO_SIZE_WIDTH-1:0] fifo_num_free_reg;  // Pipeline fifo_num_free to break combinational loop

   logic [MM_ADDR_WIDTH-1:0]                 mm_next_address;
   logic [$clog2(MAX_PENDING_READS + 1)-1:0] mm_pending_reads, mm_pending_reads_with_done;
   
   State current_state, next_state;
   
   assign mm_byteenable = '1;

   always_ff @(posedge clk)
   begin: start_update
      if (reset || current_state == START)
         start_reg <= '0;
      else if (start)
         start_reg <= '1;
   end

   always_ff @(posedge clk)
   begin: address_update
      if (reset)
         address_reg <= MM_START_ADDRESS;
      else if (address_wr)
         address_reg <= address;
   end

   always_ff @(posedge clk)
   begin: fifo_num_free_update
      if (reset)
         fifo_num_free_reg <= '0;
      else
         fifo_num_free_reg <= fifo_num_free;
   end
   
   always_comb
   begin: mm_state_mgmt
      next_state = current_state;
      case (current_state)
         WAIT:
            if (start_reg)
               next_state = START;
         START:
            next_state = READING;
         READING:
            if (start_reg || mm_next_address == end_address_reg)
               next_state = FINISH_READS;
         FINISH_READS:
            if (mm_pending_reads == '0)
               next_state = packet_started ? CLOSE_PACKET : WAIT;
         CLOSE_PACKET:
            if (fifo_num_free_reg != '0)
               next_state = WAIT;
      endcase
   end

   always_ff @(posedge clk)
   begin: packet_started_update
      if (reset)
         packet_started <= '0;
      else if ((current_state == READING || current_state == FINISH_READS)
               && mm_readdatavalid && !packet_started)
         packet_started <= '1;
      else if (current_state == CLOSE_PACKET && fifo_num_free_reg != '0)
         packet_started <= '0;
   end

   assign mm_pending_reads_with_done = mm_pending_reads - mm_readdatavalid;

   always_ff @(posedge clk)
   begin: ram_read_update
      if (reset) begin
         mm_read          <= '0;
         mm_address       <= '0;
         mm_next_address  <= '0;
         mm_pending_reads <= '0;
         end_address_reg  <= '0;
      end
      else if (current_state == START) begin
         mm_read              <= '0;
         mm_address           <= '0;
         mm_next_address      <= address_reg;
         mm_pending_reads     <= '0;
         end_address_reg      <= address_reg + MM_ADDR_WIDTH'(MM_FRAME_SIZE);
      end
      else begin
         mm_pending_reads <= mm_pending_reads_with_done;

         if (!mm_read || !mm_waitrequest) begin
            if (current_state == READING
               && (mm_pending_reads_with_done < MAX_PENDING_READS)
               && (mm_pending_reads < fifo_num_free_reg)    // compare previous mem read state with previous FIFO state
               && mm_next_address != end_address_reg) begin
               // We can start a new read
               mm_read          <= '1;
               mm_address       <= mm_next_address;
               mm_next_address  <= mm_next_address + MM_ADDR_WIDTH'(MM_BYTES_PER_WORD);
               mm_pending_reads <= mm_pending_reads_with_done + 1'b1;
            end
            else begin
               // No new read
               mm_read    <= '0;
               mm_address <= '0;
            end
         end
      end
   end

   always_comb
   begin: fifo_update
      prefetcher_fifo_item_t fifo_wrdata_record;

      fifo_wren   = '0;
      fifo_wrdata_record = '{default: '0};
      
      if (current_state == READING || current_state == FINISH_READS) begin
         fifo_wren          = mm_readdatavalid;
         fifo_wrdata_record = '{data: mm_readdata, startofpacket: !packet_started, endofpacket: 1'b0};
      end
      else if (current_state == CLOSE_PACKET) begin
         // Add empty trailer to close packet
         fifo_wren          = fifo_num_free_reg != '0;
         fifo_wrdata_record = '{data: '0, startofpacket: 1'b0, endofpacket: 1'b1};
      end
      fifo_wrdata = fifo_wrdata_record;
   end

   always_ff @(posedge clk)
   begin: state_transition
      if (reset)
         current_state <= WAIT;
      else
         current_state <= next_state;
   end

endmodule: vga_frame_buffer_prefetch
