
// synthesis translate_off

`timescale 1ns/1ns

module memory_sim_tb;

   localparam T = 10;
   localparam BASE_ADDRESS = 16;

   logic clk;
   logic reset;

   logic        mm_read;
   logic [31:0] mm_address;
   logic [15:0] mm_readdata;
   logic        mm_waitrequest;
   logic        mm_readdatavalid;

   logic        mm_read2;
   logic [31:0] mm_address2;
   logic [15:0] mm_readdata2;
   logic        mm_waitrequest2;
   logic        mm_readdatavalid2;

   memory_sim #(
      .MEM_SIZE(48),
      .MAX_PENDING_READS(4),
      .MEM_READ_LATENCY(6),
      .MEM_BASE_ADDRESS(BASE_ADDRESS),
      .MEM_INIT_OFFSET(0)
   ) memory_sim1(
      .clk,
      .reset,
      .mm_read,
      .mm_address,
      .mm_byteenable('1),
      .mm_readdata,
      .mm_waitrequest,
      .mm_readdatavalid
   );

   memory_sim #(
      .MEM_SIZE(64),
      .MAX_PENDING_READS(4),
      .MEM_READ_LATENCY(6),
      .MEM_BASE_ADDRESS(BASE_ADDRESS),
      .MEM_INIT_FILE("memory_sim_data.mem")
   ) memory_sim2(
      .clk,
      .reset,
      .mm_read(mm_read2),
      .mm_address(mm_address2),
      .mm_byteenable('1),
      .mm_readdata(mm_readdata2),
      .mm_waitrequest(mm_waitrequest2),
      .mm_readdatavalid(mm_readdatavalid2)
   );
   
   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   int current_address = BASE_ADDRESS + 10;

   initial
   begin: test_cases
      mm_read     = '0;
      mm_address  = '0;
      mm_read2    = '0;
      mm_address2 = '0;
      reset       = '1;

      @(posedge clk) reset = '0;

      $display("reading from memory_sim1...");

      // We should be able to issue a few read requests without wait states
      repeat (memory_sim1.MAX_PENDING_READS) begin
         @(posedge clk) begin
            mm_read         <= '1;
            mm_address      <= current_address;
            current_address <= current_address + 2;
         end
         #1;
         assert (!mm_waitrequest) else $error("waitrequest should be deasserted");
      end

      // Next read should assert wait state
      @(posedge clk) begin
         mm_read <= '1;
         mm_address <= current_address;
         current_address <= current_address + 2;
      end
      #1;
      assert (mm_waitrequest) else $error("waitrequest should be asserted, too many reads");

      wait (!mm_waitrequest);
      @(posedge clk) begin
         mm_read    <= '0;
         mm_address <= '0;
      end

      $display("reading from memory_sim2...");
      current_address = BASE_ADDRESS;
      
      for (int i = 0; i < 32; i = i + 1) begin
         @(posedge clk) begin
            mm_read2        <= '1;
            mm_address2     <= current_address;
            current_address <= current_address + 2;
         end

         #T;
         wait (!mm_waitrequest2);
      end
      
      repeat(20) @(posedge clk);
      $stop;
   end

   // Check that correct data was read
   int current_data = 'd5;

   initial
   begin: check_readdata1

      repeat (memory_sim1.MAX_PENDING_READS + 1) begin
         wait (mm_readdatavalid);
         @(posedge clk) begin
            assert (mm_readdata == current_data) else $error("incorrect data read");
            current_data <= current_data + 1;
         end
      end
   end

   initial
   begin: check_readdata2
      // Input in memory file alternates between '1 and '0
      logic [15:0] data = '1;

      repeat (32) begin
         wait (mm_readdatavalid2);
         @(posedge clk) begin
            assert (mm_readdata2 == data) else $error("incorrect data read");
            data <= ~data;
         end
      end
   end
   
endmodule: memory_sim_tb

// synthesis translate_on
