
#include "vga_driver.h"

#include <io.h>
#include <system.h>
#include <sys/alt_timestamp.h>

#include <stdio.h>

// Define registers and types used by the hardware

// Hardware: graphics_line

#define LINE_REG_START		 0
#define LINE_REG_END 		 1
#define LINE_REG_COLOR 		 2

// Hardware: graphics_rect_fill

#define RECT_FILL_REG_POINT1 0
#define RECT_FILL_REG_POINT2 1
#define RECT_FILL_REG_COLOR  2

// Hardware: graphics_rect_move

#define RECT_MOVE_REG_SRC_POINT1 0
#define RECT_MOVE_REG_SRC_POINT2 1
#define RECT_MOVE_REG_DST_POINT  2

// VGA_SPRITE_STREAM registers
#define VGA_SPRITE_STREAM_ENABLE_REG   1
#define VGA_SPRITE_STREAM_ADDRESS_REG  2
#define VGA_SPRITE_STREAM_XY_REG       3
#define VGA_SPRITE_STREAM_COLOR_REG    4

// Base addresses of each supported sprite
static const void *sprite_bases[] = {
		(void*) VGA_SPRITE_STREAM_1_BASE,
		(void*) VGA_SPRITE_STREAM_2_BASE,
		(void*) VGA_SPRITE_STREAM_3_BASE
};

// Calling custom instruction for various graphics operations, hardware: graphics_instruction
typedef enum {
	LINE_OPCODE = 1,
	RECT_FILL_OPCODE = 2,
	RECT_MOVE_OPCODE = 3
} graphics_instruction_op_code_t;

static void graphics_instruction(graphics_instruction_op_code_t opcode)
{
	__builtin_custom_ni(ALT_CI_GRAPHICS_INSTRUCTION_0_N, opcode);
}

void vga_draw_line(unsigned x1, unsigned y1, unsigned x2, unsigned y2, color_t color)
{
	coordinate_t point1 = {.point.x = x1, .point.y = y1 };
	coordinate_t point2 = {.point.x = x2, .point.y = y2 };

	IOWR(GRAPHICS_LINE_0_BASE, LINE_REG_START, point1.data);
	IOWR(GRAPHICS_LINE_0_BASE, LINE_REG_END,   point2.data);
	IOWR(GRAPHICS_LINE_0_BASE, LINE_REG_COLOR, color);

	graphics_instruction(LINE_OPCODE);
}

void vga_fill_rectangle(unsigned x1, unsigned y1, unsigned x2, unsigned y2, color_t bg_color)
{
	coordinate_t point1 = {.point.x = x1, .point.y = y1 };
	coordinate_t point2 = {.point.x = x2, .point.y = y2 };

	IOWR(GRAPHICS_RECT_FILL_0_BASE, RECT_FILL_REG_POINT1, point1.data);
	IOWR(GRAPHICS_RECT_FILL_0_BASE, RECT_FILL_REG_POINT2, point2.data);
	IOWR(GRAPHICS_RECT_FILL_0_BASE, RECT_FILL_REG_COLOR, bg_color);

	graphics_instruction(RECT_FILL_OPCODE);
}

void vga_move_rectangle(unsigned src_x1, unsigned src_y1, unsigned src_x2, unsigned src_y2,
						unsigned dst_x1, unsigned dst_y1)
{
	coordinate_t src_point1 = {.point.x = src_x1, .point.y = src_y1 };
	coordinate_t src_point2 = {.point.x = src_x2, .point.y = src_y2 };
	coordinate_t dst_point  = {.point.x = dst_x1, .point.y = dst_y1 };

	IOWR(GRAPHICS_RECT_MOVE_0_BASE, RECT_MOVE_REG_SRC_POINT1, src_point1.data);
	IOWR(GRAPHICS_RECT_MOVE_0_BASE, RECT_MOVE_REG_SRC_POINT2, src_point2.data);
	IOWR(GRAPHICS_RECT_MOVE_0_BASE, RECT_MOVE_REG_DST_POINT, dst_point.data);

	graphics_instruction(RECT_MOVE_OPCODE);
}

void vga_sprite_set_address(unsigned sprite_idx, const void *base_address)
{
	IOWR(sprite_bases[sprite_idx], VGA_SPRITE_STREAM_ADDRESS_REG, (alt_u32) base_address);
}

void vga_sprite_set_xy(unsigned sprite_idx, unsigned x, unsigned y)
{
	coordinate_t point1 = {.point.x = x, .point.y = y};
	IOWR(sprite_bases[sprite_idx], VGA_SPRITE_STREAM_XY_REG, point1.data);
}

void vga_sprite_set_color(unsigned sprite_idx, color_t color)
{
	IOWR(sprite_bases[sprite_idx], VGA_SPRITE_STREAM_COLOR_REG, color);
}

void vga_sprite_enable(unsigned sprite_idx, int enabled)
{
	IOWR(sprite_bases[sprite_idx], VGA_SPRITE_STREAM_ENABLE_REG, enabled);
}
