

module fifo_top (
   input  logic clk,
   input  logic reset,
   
   input  logic rden,
   output logic [7:0] rddata,
   output logic rddone,

   input  logic wren,
   input  logic [7:0] wrdata,
   output logic wrdone,
   
   output logic empty,
   output logic full,
   output logic [4:0] num_used,
   output logic [4:0] num_free
);

   fifo #(
      .SIZE(16),
      .DATA_WIDTH(8)
   ) fifo_0(
      .clk,
      .reset,
      .rden,
      .rddata,
      .rddone,
      .wren,
      .wrdata,
      .wrdone,
      .empty,
      .full,
      .num_used,
      .num_free
   );

endmodule: fifo_top
