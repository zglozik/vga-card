
// synthesis translate_off

`timescale 1ns/1ns

module width_narrowing_adapter_tb;

   localparam T = 10;
   localparam ST_SINK_WIDTH   = 16;
   localparam ST_SOURCE_WIDTH = 4;

   localparam START_COUNTER = 16'hCBA1;
   localparam END_COUNTER   = 16'hCBA1 + 8'h08;
      
   logic clk;
   logic reset;

   logic                       st_sink_ready;
   logic [ST_SINK_WIDTH-1:0]   st_sink_data;
   logic                       st_sink_startofpacket;
   logic                       st_sink_endofpacket;
   logic                       st_sink_valid;

   // Avalon ST source interface
   logic                       st_source_ready;
   logic [ST_SOURCE_WIDTH-1:0] st_source_data;
   logic                       st_source_startofpacket;
   logic                       st_source_endofpacket;
   logic                       st_source_valid;

   width_narrowing_adapter #(
      .ST_SINK_WIDTH(ST_SINK_WIDTH),
      .ST_SOURCE_WIDTH(ST_SOURCE_WIDTH)
   ) width_narrowing_adapter0(
      .clk,
      .reset,
      .st_sink_ready,
      .st_sink_data,
      .st_sink_startofpacket,
      .st_sink_endofpacket,
      .st_sink_valid,
      .st_source_ready,
      .st_source_data,
      .st_source_startofpacket,
      .st_source_endofpacket,
      .st_source_valid
   );
      
   
   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   logic [15:0] counter;

   always_ff @(posedge clk)
   begin: sink_update
      if (reset) begin
         counter       <= START_COUNTER;
         st_sink_valid <= '0;
      end
      else begin
         logic [15:0] counter_tmp;
         logic st_sink_valid_tmp;
         counter_tmp = counter;

         if (st_sink_valid && st_sink_ready && counter <= END_COUNTER)
            counter_tmp = counter_tmp + 1'b1;
         counter <= counter_tmp;

         // Switch off valid flag randomly 
         st_sink_valid_tmp = unsigned'($random()) % 10 < 5 ? 1'b0 : counter_tmp <= END_COUNTER;

         st_sink_valid         <= st_sink_valid_tmp;
         st_sink_data          <= counter_tmp;
         st_sink_startofpacket <= counter_tmp == START_COUNTER;
         st_sink_endofpacket   <= counter_tmp == END_COUNTER;
      end
   end

   initial
   begin: test_cases
      reset           <= '1;
      st_source_ready <= '0;

      @(posedge clk);
      reset <= '0;
      
      @(posedge clk);
      st_source_ready <= '1;
      
      for (int i = 0; i < 8; i = i + 1) begin
         for (int j = 0; j < ST_SINK_WIDTH / ST_SOURCE_WIDTH; j = j + 1) begin
            logic [ST_SOURCE_WIDTH-1:0] expected_value;

            @(posedge clk iff st_source_valid);

            expected_value = ((START_COUNTER + i) >> (j * ST_SOURCE_WIDTH)) & {ST_SOURCE_WIDTH{1'b1}};
            assert (st_source_valid) else $error("source should be valid");
            assert (st_source_data == expected_value) else $error("incorrect data received, expected: %x, received: %x", expected_value, st_source_data);
            assert ((i != 0 || j != 0) ^ st_source_startofpacket) else $error("startofpacket should not be asserted");
            assert (!st_source_endofpacket) else $error("endofpacket should not be asserted");
            
            if (unsigned'($random()) % 10 < 3) begin
               // Switch off source ready for a cycle
               st_source_ready <= '0;
               @(posedge clk);
               st_source_ready <= '1;
            end
         end
      end
      
      @(posedge clk iff st_source_valid);
      assert (!st_source_startofpacket) else $error("startofpacket should not be asserted");
      assert (st_source_endofpacket) else $error("endofpacket should be asserted");

      // No more data should follow
      repeat (10) begin
         @(posedge clk);
         assert (!st_source_valid) else $error("source should NOT be valid any more");
      end

      $stop;
   end

endmodule: width_narrowing_adapter_tb

// synthesis translate_on
