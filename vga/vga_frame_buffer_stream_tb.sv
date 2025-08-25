
// synthesis translate_off

`timescale 1ns/1ns

module vga_frame_buffer_stream_tb;
   import vga_pkg::*;

   localparam T = 10;
   localparam FRAME_SIZE = 48;
	localparam MEM_INIT_OFFSET = 16'hFA00;
	localparam ST_EMPTY_WIDTH = $clog2(MM_MEM_DATA_WIDTH / 8 + 1);

   logic clk;
   logic reset;

// Avalon MM Slave interface for memory access
   logic                           mm_mem_read;
   logic [MM_MEM_ADDR_WIDTH-1:0]   mm_mem_address;
   logic [MM_MEM_DATA_WIDTH/8-1:0] mm_mem_byteenable;
   logic [MM_MEM_DATA_WIDTH-1:0]   mm_mem_readdata;
   logic                           mm_mem_waitrequest;
   logic                           mm_mem_readdatavalid;

   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;

   // Avalon source interface
   logic                         st_ready;
   logic [MM_MEM_DATA_WIDTH-1:0] st_data;
   logic                         st_startofpacket;
   logic                         st_endofpacket;
   logic [ST_EMPTY_WIDTH-1:0]    st_empty;
   logic                         st_valid;

   memory_sim #(
      .MEM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MEM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .MEM_SIZE(FRAME_SIZE),
      .MEM_READ_LATENCY(6),
      .MAX_PENDING_READS(4),
      .MEM_INIT_OFFSET(MEM_INIT_OFFSET)
   ) memory_sim0(
      .clk,
      .reset,
      .mm_read(mm_mem_read),
      .mm_address(mm_mem_address),
      .mm_byteenable(mm_mem_byteenable),
      .mm_readdata(mm_mem_readdata),
      .mm_waitrequest(mm_mem_waitrequest),
      .mm_readdatavalid(mm_mem_readdatavalid)
   );

   vga_frame_buffer_stream #(
      .MM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .MM_START_ADDRESS(0),
      .MM_FRAME_SIZE(FRAME_SIZE),
      .FIFO_SIZE(16)
   ) vga_frame_buffer_stream0(
      .clk,
      .reset,
      .mm_mem_read,
      .mm_mem_address,
      .mm_mem_byteenable,
      .mm_mem_readdata,
      .mm_mem_waitrequest,
      .mm_mem_readdatavalid,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .st_ready,
      .st_data,
      .st_startofpacket,
      .st_endofpacket,
		.st_empty,
      .st_valid
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   initial
   begin: test_cases
      reset <= '1;
      st_ready <= '0;

      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata <= '0;
      
      #(T);
      reset <= '0;
      // Start frame
      mm_csr_write <= '1;
      mm_csr_address <= VGA_STREAM_RESTART_REG;
      mm_csr_writedata[0] <= 1'b1;

      #(T);
      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata[0] <= 1'b0;
      st_ready <= '1;

      repeat(3) begin
         #(T);
         assert (!st_valid) else $error("No data should be available initially");
      end
      st_ready <= '0;

      #(10*T);
      $info("Starting reading data frame first time");
      st_ready <= '1;
      
      // We should be able to read each byte in continuous cycles
      for (int i = 0; i < FRAME_SIZE/2; i = i + 1)
      begin
         #(T);
         assert (st_valid) else $error("data should be valid");
         assert (st_data == MEM_INIT_OFFSET + i) else $error("incorrect data returned");
         assert ((i != 0) ^ st_startofpacket) else $error("start of packet should be high only for first word");
         assert (!st_endofpacket) else $error("end of packet should be low for packet content");
			assert (st_empty == 0) else $error("no symbols should be empty in this heartbeat");
      end

      #(T);
      wait (st_valid)
         @(posedge clk);

      // Read empty end of packet word
      assert (st_endofpacket) else $error("end of packet should be high for the trailer");
		assert (st_empty == MM_MEM_DATA_WIDTH / 8) else $error("all symbols should be empty in this heartbeat");
      assert (!st_startofpacket) else $error("start of packet should be low for the trailer");
      
      // No more data should be available
      #(T);
      st_ready <= '0;
      assert (!st_valid) else $error("data should not be available beyond the frame");

      // Start again after a few cycles
      #(5*T);
      mm_csr_write <= '1;
      mm_csr_address <= VGA_STREAM_RESTART_REG;
      mm_csr_writedata[0] <= 1'b1;

      #(T);
      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata[0] <= 1'b0;

      #(12*T);
      $info("Starting reading frame second time");
      st_ready <= '1;

      // We should be able to read each byte in continuous cycles
      for (int i = 0; i < FRAME_SIZE/2; i = i + 1)
      begin
         #(T);
         assert (st_valid) else $error("data should be valid");
         assert (st_data == MEM_INIT_OFFSET + i) else $error("incorrect data returned");
         assert ((i != 0) ^ st_startofpacket) else $error("start of packet should be high only for first word");
         assert (!st_endofpacket) else $error("end of packet should be low for packet content");
			assert (st_empty == 0) else $error("no symbols should be empty in this heartbeat");
		end

      #(T);
      wait (st_valid)
         @(posedge clk);

      // Read empty end of packet word
      assert (st_endofpacket) else $error("end of packet should be high for the trailer");
		assert (st_empty == MM_MEM_DATA_WIDTH / 8) else $error("all symbols should be empty in this heartbeat");
      assert (!st_startofpacket) else $error("start of packet should be low for the trailer");

      // Stop reading
      st_ready <= '0;

      // Start again after a few cycles
      #(5*T);
      mm_csr_write <= '1;
      mm_csr_address <= VGA_STREAM_RESTART_REG;
      mm_csr_writedata[0] <= 1'b1;

      #(T);
      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata[0] <= 1'b0;

      #(12*T);
      $info("Starting reading frame third time, restart during read");
      st_ready <= '1;

      // Read only two words
      for (int i = 0; i < 2; i = i + 1)
      begin
         #(T);
         assert ((i != 0) ^ st_startofpacket) else $error("start of packet should be high only for first word");
         assert (st_valid) else $error("data should be valid");
         assert (st_data == MEM_INIT_OFFSET + i) else $error("incorrect data returned");
      end

      // Stop reading and request restart
      st_ready <= '0;
      mm_csr_write <= '1;
      mm_csr_address <= VGA_STREAM_RESTART_REG;
      mm_csr_writedata[0] <= 1'b1;

      #(T);
      mm_csr_write <= '0;
      mm_csr_address <= '0;
      mm_csr_writedata[0] <= 1'b0;

      // Read again until end of frame and start of frame received
      #(T);
      st_ready <= '1;
      
      wait (st_valid && st_endofpacket)
         @(posedge clk);

      wait (st_valid && st_startofpacket)
         @(posedge clk);
      st_ready <= '0;

      #(5*T);
      $stop;
   end
   
endmodule: vga_frame_buffer_stream_tb

// synthesis translate_on
