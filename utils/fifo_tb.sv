

// synthesis translate_off

`timescale 1ns/1ns

module fifo_tb;

   localparam T = 10;

   typedef struct {
      logic rden;
      logic [7:0] rddata;
		logic rddata_valid;
      logic rddone;

      logic wren;
      logic [7:0] wrdata;
      logic wrdone;
      
      logic [1:0] num_used, num_free;
      logic empty;
      logic full;
   } test_data_t;
   
   test_data_t test_data[14] = '{
      //  rden, rddata, rddata_valid, rddone, wren, wrdata, wrdone, num_used, num_free, empty, full
      '{    '0,     'x,           '0,     '0,   '1,      1,     '0,         0,       3,    '1,   '0 },  // write 1
      '{    '0,     'x,           '0,     '0,   '1,      2,     '1,         1,       2,    '0,   '0 },  // write 2
      '{    '0,      1,           '1,     '0,   '1,      3,     '1,         2,       1,    '0,   '0 },  // write 3
      '{    '0,      1,           '1,     '0,   '1,      4,     '1,         3,       0,    '0,   '1 },  // write 4
      '{    '1,      1,           '1,     '0,   '1,      4,     '0,         3,       0,    '0,   '1 },  // read/write, write failed
      
      '{    '1,      1,           '1,     '1,   '1,      4,     '0,         2,       1,    '0,   '0 },  // read
      '{    '1,      2,           '1,     '1,   '0,      0,     '1,         2,       1,    '0,   '0 },  // read
      '{    '1,      3,           '1,     '1,   '0,      0,     '0,         1,       2,    '0,   '0 },  // read
      '{    '1,      4,           '1,     '1,   '0,      0,     '0,         0,       3,    '1,   '0 },  // read
      '{    '1,     'x,           '0,     '0,   '0,      0,     '0,         0,       3,    '1,   '0 },  // read failed
      '{    '0,     'x,           '0,     '0,   '0,      0,     '0,         0,       3,    '1,   '0 },  // idle
      '{    '1,     'x,           '0,     '0,   '1,      5,     '0,         0,       3,    '1,   '0 },  // read/write pass through while empty
      '{    '0,     'x,           '0,     '0,   '0,      0,     '1,         1,       2,    '0,   '0 },
      '{    '0,      5,           '1,     '0,   '0,      0,     '0,         1,       2,    '0,   '0 }
   };
   
   logic clk;
   logic reset;
   
   logic rden;
   logic [7:0] rddata;
   logic rddata_valid;
   logic rddone;

   logic wren;
   logic [7:0] wrdata;
   logic wrdone;
   
   logic [1:0] num_used, num_free;
   logic empty;
   logic full;

   fifo #(
      .DATA_WIDTH(8),
      .SIZE(3)
   ) fifo_0(
      .clk,
      .reset,
      .rden,
      .rddata,
		.rddata_valid,
      .rddone,
      .wren,
      .wrdata,
      .wrdone,      
      .empty,
      .full,
      .num_used,
      .num_free
   );

   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end

   initial begin
      rden   <= '0;
      wren   <= '0;
      wrdata <= '0;
      reset  <= '1;
     
      @(posedge clk);
		reset <= '0;

      for (int i = 0; i < $size(test_data); ++i) begin
         @(posedge clk) begin
            rden   <= test_data[i].rden;
            wren   <= test_data[i].wren;
            wrdata <= test_data[i].wrdata;

				assert(rddata ==? test_data[i].rddata) else $error("rddata failed in iteration %d", i);
				assert(rddone == test_data[i].rddone) else $error("rddone failed in iteration %d", i);
				assert(rddata_valid == test_data[i].rddata_valid) else $error("rddata_valid failed in iteration %d", i);
				assert(wrdone == test_data[i].wrdone) else $error("wrdone failed in iteration %d", i);
				assert(num_used == test_data[i].num_used) else $error("num_used failed in iteration %d", i);
				assert(num_free == test_data[i].num_free) else $error("num_free failed in iteration %d", i);
				assert(empty == test_data[i].empty) else $error("empty failed in iteration %d", i);
				assert(full == test_data[i].full) else $error("full failed in iteration %d", i);
         end
      end

      @(posedge clk);

      $stop;
   end

endmodule: fifo_tb

// synthesis translate_on
