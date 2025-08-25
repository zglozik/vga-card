
#include "dino.h"
#include "dino_1bit.h"
#include "vga_driver.h"

// Use sprite 0 for the dino
#define DINO_SPRITE_IDX		0

#define DINO_BASE_X		180
#define DINO_BASE_Y		380
#define DINO_JUMP_Y		(DINO_BASE_Y - 70)

unsigned dino_x, dino_y;

// Current dino sprite frame index
static unsigned dino_frame_idx;

// Dino horizontal speed, number of ticks between frame changes
static unsigned dino_frame_period;

// Y coordinate change by tick while jumping (0 means stationary)
static int dino_vertical_speed;

#define DINO_SLOWEST_PERIOD 10
#define DINO_FASTEST_PERIOD 3

void dino_init()
{
	dino_frame_idx = 0;
	dino_frame_period = DINO_SLOWEST_PERIOD;
	dino_vertical_speed = 0;
	dino_x = DINO_BASE_X;
	dino_y = DINO_BASE_Y;

	vga_sprite_set_address(DINO_SPRITE_IDX, &dino_1bit_data[dino_frame_idx]);
	vga_sprite_set_xy(DINO_SPRITE_IDX, dino_x, dino_y);
	vga_sprite_set_color(DINO_SPRITE_IDX, RGB_BROWN);
	vga_sprite_enable(DINO_SPRITE_IDX, 1);
}

void dino_timer_tick(alt_u32 now)
{
	if (dino_vertical_speed != 0) {
		if (dino_vertical_speed < 0) {
			if (dino_y <= DINO_JUMP_Y) {
				// Start moving down
				dino_vertical_speed = 1;
			} else {
				dino_y += dino_vertical_speed;
				dino_vertical_speed = -(4 * (dino_y - DINO_JUMP_Y) / (DINO_BASE_Y - DINO_JUMP_Y) + 1);
			}
		} else {
			if (dino_y >= DINO_BASE_Y) {
				// Landed back
				dino_y = DINO_BASE_Y;
				dino_vertical_speed = 0;
			} else {
				dino_y += dino_vertical_speed;
				dino_vertical_speed = 4 * (dino_y - DINO_JUMP_Y) / (DINO_BASE_Y - DINO_JUMP_Y) + 1;
			}
		}
		vga_sprite_set_xy(DINO_SPRITE_IDX, dino_x, dino_y);
	} else if (now % dino_frame_period == 0) {
		dino_frame_idx = (dino_frame_idx + 1) % DINO_FRAME_COUNT;
		vga_sprite_set_address(DINO_SPRITE_IDX, &dino_1bit_data[dino_frame_idx]);
	}
}
void dino_increase_speed()
{
	if (dino_frame_period > DINO_FASTEST_PERIOD) {
		dino_frame_period -= 1;
	}
}

void dino_jump(alt_u32 now)
{
	// Ignore if already jumping
	if (dino_vertical_speed == 0) {
		dino_vertical_speed = -4;
	}
}
