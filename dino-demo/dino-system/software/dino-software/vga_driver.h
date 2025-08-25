
#ifndef VGA_DRIVER_H_
#define VGA_DRIVER_H_

#include <alt_types.h>

#define VGA_WIDTH  640
#define VGA_HEIGHT 480

#define NUM_SPRITES	3

// Define registers and types used by the hardware

typedef union {
	struct {
		alt_u16 y;
		alt_u16 x;
	} point;
	alt_u32 data;
} coordinate_t;

typedef alt_u32 color_t;

#define RGB(red, green, blue)	((color_t) (((red) & 0xF) | (((green) & 0xF) << 4) | (((blue) & 0xF) << 8)))

#define RGB_BLACK	RGB(0x0, 0x0, 0x0)
#define RGB_GREY	RGB(0xA, 0xA, 0xA)
#define RGB_GREEN	RGB(0x0, 0xF, 0x0)
#define RGB_BROWN	RGB(0xD, 0xB, 0x8)

void vga_draw_line(unsigned x1, unsigned y1, unsigned x2, unsigned y2, color_t color);

void vga_fill_rectangle(unsigned x1, unsigned y1, unsigned x2, unsigned y2, color_t bg_color);

void vga_move_rectangle(unsigned src_x1, unsigned src_y1, unsigned src_x2, unsigned src_y2,
						unsigned dst_x1, unsigned dst_y1);

void vga_sprite_set_address(unsigned sprite_idx, const void *base_address);
void vga_sprite_set_xy(unsigned sprite_idx, unsigned x, unsigned y);
void vga_sprite_set_color(unsigned sprite_idx, color_t color);
void vga_sprite_enable(unsigned sprite_idx, int enabled);

#endif /* VGA_DRIVER_H_ */
