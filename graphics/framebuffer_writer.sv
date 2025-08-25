
module framebuffer_writer
   import vga_pkg::*, graphics_pkg::*;
#(
   MM_ADDR_WIDTH = MM_MEM_ADDR_WIDTH,
   MM_DATA_WIDTH = MM_MEM_DATA_WIDTH,
   MM_START_ADDRESS = 0
)
(
	input	logic clk,
	input logic reset,

   // Avalon ST sink interface for input pixels
   output logic                      st_ready,
   input  logic [ST_DATA_WIDTH-1:0]  st_data,
   input  logic [7:0]                st_channel,
   input  logic                      st_valid,
   
	// Avalon MM Master interface for writing to frame buffer
   output logic                     mm_write,
   output logic [MM_ADDR_WIDTH-1:0] mm_address,
   output logic [MM_DATA_WIDTH-1:0] mm_writedata,
   input  logic                     mm_waitrequest
);
   localparam BYTES_PER_PIXEL = MM_DATA_WIDTH / 8;

   pixel_t st_data_pixel;
   logic [MM_ADDR_WIDTH-1:0] pixel_address;
   logic writing;
   
   // Typed pixel input
   assign st_data_pixel = st_data;

   // Address of incoming pixel in frame buffer memory
   assign pixel_address = MM_ADDR_WIDTH'(MM_START_ADDRESS
                                         + st_data_pixel.y * WIDTH * BYTES_PER_PIXEL
                                         + st_data_pixel.x * BYTES_PER_PIXEL);
   
   assign st_ready = !writing || !mm_waitrequest;
   assign mm_write = writing;

   always_ff @(posedge clk)
   begin: framebuffer_write
      if (reset) begin
         writing      <= '0;
         mm_address   <= '0;
         mm_writedata <= '0;
      end
      else if ((!writing || !mm_waitrequest) && st_valid) begin
         // Either not writing right now, or a write is finished,
         // there is a pixel available so start a new write
         writing      <= '1;
         mm_address   <= pixel_address;
         mm_writedata <= MM_DATA_WIDTH'(st_data_pixel.color);
      end
      else if (!mm_waitrequest) begin
         // Finish writing, if any
         writing <= '0;
      end
   end

endmodule: framebuffer_writer
