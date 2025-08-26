
package vga_pkg;

   localparam int unsigned MM_MEM_ADDR_WIDTH = 32;
   localparam int unsigned MM_MEM_DATA_WIDTH = 16;

   localparam int unsigned WIDTH          = 640;
   localparam int unsigned HEIGHT         = 480;
   localparam int unsigned FB_CDEPTH      = 4;
   localparam int unsigned FB_PIXEL_WIDTH = MM_MEM_DATA_WIDTH;  // 12 bits of color per pixel (4 unused), needs to match mem data width to be able to change one pixel without read
   localparam int unsigned DISPLAY_CDEPTH = 4;

   localparam int unsigned ADDR_X_WIDTH = $clog2(WIDTH);
   localparam int unsigned ADDR_Y_WIDTH = $clog2(HEIGHT);

   // Data type used by frame buffer FIFO cache
   typedef struct packed {
      logic [MM_MEM_DATA_WIDTH-1:0] data;
      logic                         startofpacket;
      logic                         endofpacket;
   } prefetcher_fifo_item_t;
 
    // Avalon MM address and data width for CSR registers
   localparam int unsigned MM_CSR_ADDR_WIDTH = 4;
   localparam int unsigned MM_CSR_DATA_WIDTH = 32;

   // Data type(s) for CSR via AValon MM
   localparam int unsigned COORD_DATA_WIDTH = 16;
   localparam int unsigned COLOR_DATA_WIDTH = 12;

   typedef struct packed {
      logic [COORD_DATA_WIDTH-1:0] x;
      logic [COORD_DATA_WIDTH-1:0] y;
   } coordinate_t;
   
   typedef struct packed {
      logic [MM_CSR_DATA_WIDTH - COLOR_DATA_WIDTH - 1:0] padding;

      logic [COLOR_DATA_WIDTH-1:0] color;
   } color_t;

   // Register for notifying vga_buffer_stream/vga_sprite_stream that a new frame needs to start
   localparam logic [1:0] VGA_STREAM_RESTART_REG = 0;              // type: logic, restart when lowest bit asserted

   // AValon MM CSR registers for vga_sprite_stream
   localparam logic [2:0] VGA_SPRITE_STREAM_ENABLE_REG       = 1;  // type: logic, sprite displayed only when lowest bit asserted
   localparam logic [2:0] VGA_SPRITE_STREAM_BASE_ADDRESS_REG = 2;  // type: logic [MM_CSR_DATA_WIDTH-1:0]
   localparam logic [2:0] VGA_SPRITE_STREAM_XY_REG           = 3;  // type: coordinate_t, top-left pixel of sprite
   localparam logic [2:0] VGA_SPRITE_STREAM_COLOR_REG        = 4;  // type: color_t
   
endpackage: vga_pkg
