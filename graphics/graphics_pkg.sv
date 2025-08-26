
package graphics_pkg;
   import vga_pkg::*;

   // Avalon ST source/sink struct
   typedef struct packed {
      logic [8 - (2 * COORD_DATA_WIDTH + COLOR_DATA_WIDTH) % 8 - 1:0] padding;

      logic [COORD_DATA_WIDTH-1:0] x;
      logic [COORD_DATA_WIDTH-1:0] y;
      logic [COLOR_DATA_WIDTH-1:0] color;
   } pixel_t;

   localparam int unsigned ST_DATA_WIDTH  = $bits(pixel_t);

   // Register addresses for graphics_line:
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] LINE_ADDR_START = 0;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] LINE_ADDR_END   = 1;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] LINE_ADDR_COLOR = 2;  // type: vga_pkg::color_t

   // Register addresses for graphics_rect_fill:
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_FILL_POINT1 = 0;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_FILL_POINT2 = 1;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_FILL_COLOR  = 2;  // type: vga_pkg::color_t

   // Register addresses for graphics_rect_move:
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_MOVE_SRC_POINT1 = 0;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_MOVE_SRC_POINT2 = 1;  // type: vga_pkg::coordinate_t
   localparam logic [MM_CSR_ADDR_WIDTH-1:0] RECT_MOVE_DST_POINT  = 2;  // type: vga_pkg::coordinate_t, top-left corner of target postion

endpackage: graphics_pkg
