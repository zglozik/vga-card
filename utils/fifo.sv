

module fifo
#(
   parameter int unsigned SIZE,                          // number of max items in FIFO
   parameter int unsigned DATA_WIDTH,
   parameter int unsigned SIZE_WIDTH = $clog2(SIZE + 1)
)
(
   input  logic clk,
   input  logic reset,
   
   input  logic rden,
   output logic [DATA_WIDTH-1:0] rddata,
	output logic rddata_valid,
   output logic rddone,

   input  logic wren,
   input  logic [DATA_WIDTH-1:0] wrdata,
   output logic wrdone,
   
   output logic empty,
   output logic full,
   output logic [SIZE_WIDTH-1:0] num_used,
   output logic [SIZE_WIDTH-1:0] num_free
);

   logic [DATA_WIDTH-1:0] memory[0:SIZE-1];

   logic [SIZE_WIDTH-1:0] rdptr, wrptr;
   logic [SIZE_WIDTH-1:0] num_free_reg, num_free_tmp;
   logic rddone_tmp, wrdone_tmp;

   always_ff @(posedge clk)
   begin: read_update
      if (reset)
         rdptr <= '0;
      else if (rddone_tmp)
         rdptr <= rdptr == SIZE - 1 ? SIZE_WIDTH'(0) : rdptr + 1'b1;
   end

   always_ff @(posedge clk)
   begin: write_update
      if (reset)
         wrptr <= '0;
      else if (wrdone_tmp) begin
         memory[wrptr] <= wrdata;
         wrptr <= wrptr == SIZE - 1 ? SIZE_WIDTH'(0) : wrptr + 1'b1;
      end
   end

   always_ff @(posedge clk)
   begin: num_free_update
      if (reset)
         num_free_reg <= SIZE_WIDTH'(SIZE);
      else
         num_free_reg <= num_free_tmp;
   end

   always_comb
   begin: rdwr_state_update
      rddone_tmp = '0;
      wrdone_tmp = '0;
      
      /*
      if (rden && wren && num_free_reg == SIZE) begin
         // pass through without internal memory when empty
         rddata = wrdata;
         rddone_tmp = '1;
         wrdone_tmp = '1;
      end
      else begin
         if (rden && num_free_reg != SIZE) begin
            rddata = memory[rdptr];
            rddone_tmp = '1;
         end
         if (wren && (num_free_reg != '0 || rddone_tmp)) begin
            wrdone_tmp = '1;
         end
      end
      num_free_tmp  = num_free_reg + (SIZE_WIDTH'(rddone_tmp) - SIZE_WIDTH'(wrdone_tmp));
      */

      if (rden && num_free_reg != SIZE) begin
         rddone_tmp = '1;
      end
      if (wren && num_free_reg != '0) begin
         wrdone_tmp = '1;
      end
      num_free_tmp  = num_free_reg + (SIZE_WIDTH'(rddone_tmp) - SIZE_WIDTH'(wrdone_tmp));
   end

   assign rddata = memory[rdptr];
	assign rddata_valid = num_free_reg != SIZE;
   assign rddone = rddone_tmp;
   assign wrdone = wrdone_tmp;

   assign empty = num_free_tmp == SIZE;
   assign full  = num_free_tmp == 0;

   assign num_free = num_free_tmp;
   assign num_used = SIZE_WIDTH'(SIZE) - num_free_tmp;
endmodule: fifo
