
module graphics_instruction(
   input  logic    clk,
   input  logic    reset,

   input  logic    nios_clk,
   input  logic    nios_clken,
   input  logic    nios_reset,
   
   input  logic [31:0]  dataa,   // Line drawing operation code
   input  logic         start,
   output logic         done,

   // Control signals for graphics primitives
   output logic         line_clken,
   output logic         line_start,
   input  logic         line_done,

   output logic         rect_fill_clken,
   output logic         rect_fill_start,
   input  logic         rect_fill_done,

   output logic         rect_move_clken,
   output logic         rect_move_start,
   input  logic         rect_move_done

);
   // Op codes for graphics primitives
   localparam logic [31:0] LINE      = 1;
   localparam logic [31:0] RECT_FILL = 2;
   localparam logic [31:0] RECT_MOVE = 3;

   wire [31:0] current_op = dataa;
   logic default_done;

   assign line_clken      = nios_clken;
   assign rect_fill_clken = nios_clken;
   assign rect_move_clken = nios_clken;

   always_ff @(posedge clk)
   begin
      if (reset)
         default_done <= '0;
      else if (nios_clken)
         default_done <= start;
   end

   always_comb
   begin: op_mux
      line_start      = '0;
      rect_fill_start = '0;
      rect_move_start = '0;
      case (current_op)
         LINE:
            begin
               line_start = start;
               done = line_done;
            end
         RECT_FILL:
            begin
               rect_fill_start = start;
               done = rect_fill_done;
            end
         RECT_MOVE:
            begin
               rect_move_start = start;
               done = rect_move_done;
            end
         default:
            begin
               // Delay done signal by one cycle after start was asserted
               done = default_done;
            end
      endcase
   end

endmodule: graphics_instruction
