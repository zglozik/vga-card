
#include "utils.h"
#include "vga_driver.h"

#include <stdlib.h>

#define HORIZON_Y 		420
#define MIN_HORIZ_Y		(HORIZON_Y - 3)
#define MAX_HORIZ_Y		(HORIZON_Y + 3)
#define PEBBLES_MAX_Y	(MAX_HORIZ_Y + 25)

// Right-most segment of the generated horizon, horizon_edge_x2 >= VGA_WIDTH
static unsigned horizon_edge_x1, horizon_edge_y1, horizon_edge_x2, horizon_edge_y2;

// Coordinate and color of next pebble, always outside of the frame
static unsigned pebble_x, pebble_y;
static color_t  pebble_color;
static unsigned pebble_size;

static void background_next_horizon_segment(unsigned last_x, unsigned last_y,
							                unsigned *next_x, unsigned *next_y)
{
	*next_x = last_x + (10 + rand() % 10);
	*next_y = last_y + rand() % 3 - 1;
	if (*next_y > MAX_HORIZ_Y) {
		*next_y = MAX_HORIZ_Y;
	} else if (*next_y < MIN_HORIZ_Y) {
		*next_y = MIN_HORIZ_Y;
	}

}

static void background_next_pebble(unsigned last_x, unsigned last_y,
								   unsigned *next_x, unsigned *next_y,
								   color_t *next_color, unsigned *next_pebble_size)
{
	*next_x = last_x + 5 + rand() % 20;
	*next_y = MAX_HORIZ_Y + rand() % (PEBBLES_MAX_Y - MAX_HORIZ_Y - 1);
	*next_color = RGB(0xC + random() % 3 - 1, 0x9 + random() % 3 - 1, 0x7 + random() % 3 - 1);
	*next_pebble_size = 1 + random() % 2;
}

static void background_draw_horizon()
{
	while (horizon_edge_x2 < VGA_WIDTH) {
		vga_draw_line(horizon_edge_x1, horizon_edge_y2, horizon_edge_x2, horizon_edge_y2, RGB_GREY);

		horizon_edge_x1 = horizon_edge_x2;
		horizon_edge_y1 = horizon_edge_y2;

		background_next_horizon_segment(horizon_edge_x1, horizon_edge_y1,
										&horizon_edge_x2, &horizon_edge_y2);
	}
	vga_draw_line(horizon_edge_x1, horizon_edge_y2, VGA_WIDTH-1, horizon_edge_y2, RGB_GREY);
}

static void background_draw_pebbles()
{
	while (pebble_x + pebble_size < VGA_WIDTH) {
		vga_fill_rectangle(pebble_x, pebble_y,
						   pebble_x + pebble_size, pebble_y + pebble_size,
						   pebble_color);
		background_next_pebble(pebble_x, pebble_y, &pebble_x, &pebble_y, &pebble_color, &pebble_size);
	}

}
void background_init()
{
	// Clear screen
	vga_fill_rectangle(0, 0, 639, 479, RGB(0x0, 0x0, 0x0));

	// Draw horizon
	horizon_edge_x1 = 0;
	horizon_edge_y1 = HORIZON_Y;
	horizon_edge_x2 = horizon_edge_x1;
	horizon_edge_y2 = horizon_edge_y1;

	background_draw_horizon();

	background_next_pebble(0, HORIZON_Y, &pebble_x, &pebble_y, &pebble_color, &pebble_size);
	background_draw_pebbles();
}

void background_shift(unsigned pixels)
{
	// Shift landscape to the left
	vga_move_rectangle(pixels, MIN_HORIZ_Y, VGA_WIDTH - 1, PEBBLES_MAX_Y, 0, MIN_HORIZ_Y);
	vga_fill_rectangle(VGA_WIDTH - pixels, MIN_HORIZ_Y, VGA_WIDTH - 1, PEBBLES_MAX_Y, RGB_BLACK);

	// Update invisible objects
	horizon_edge_x1 -= pixels;
	horizon_edge_x2 -= pixels;
	background_draw_horizon();

	pebble_x -= pixels;
	background_draw_pebbles();
}
