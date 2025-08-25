
#include "cactus.h"
#include "dino_1bit.h"
#include "cactus_1bit.h"
#include "utils.h"
#include "vga_driver.h"

#include <stdlib.h>

#define CACTUS_BASE_Y		380

// Macros for collision detection
#define DINO_LEFT_OFFSET	1
#define DINO_RIGHT_OFFSET	(DINO_FRAME_WIDTH - 10)

#define CACTUS_LEFT_OFFSET	15
#define CACTUS_RIGHT_OFFSET	(CACTUS_FRAME_WIDTH - 15)

#define DINO_MIN_HEIGHT		(CACTUS_BASE_Y - 40)

// Minimum/maximum pixels between subsequent cactuses
#define CACTUS_MIN_DISTANCE		250
#define CACTUS_MAX_DISTANCE		700

typedef struct {
	unsigned sprite_idx;
	unsigned x;	// Current X position of the cactus, might be off screen on the right
} cactus_state_t;

// One sprite is used for the dino
#define NUM_CACTUSES (NUM_SPRITES - 1)

cactus_state_t cactus_states[NUM_CACTUSES];

unsigned last_cactus_idx;

static unsigned next_distance(unsigned last_x)
{
	unsigned new_x = last_x + CACTUS_MIN_DISTANCE + random() % (CACTUS_MAX_DISTANCE - CACTUS_MIN_DISTANCE);

	// New cactus can't show up in the middle of the screen
	return max(new_x, VGA_WIDTH);
}

static void cactus_update_display(unsigned index)
{
	if (cactus_states[index].x + CACTUS_FRAME_WIDTH < VGA_WIDTH) {
		vga_sprite_set_xy(cactus_states[index].sprite_idx, cactus_states[index].x, CACTUS_BASE_Y);
		vga_sprite_enable(cactus_states[index].sprite_idx, 1);
	} else {
		vga_sprite_enable(cactus_states[index].sprite_idx, 0);
	}
}

static void cactus_setup_new_state(unsigned last_x, unsigned index)
{
	vga_sprite_enable(cactus_states[index].sprite_idx, 0);

	cactus_states[index].x = next_distance(last_x);
	unsigned frame_idx = random() % CACTUS_FRAME_COUNT;
	vga_sprite_set_address(cactus_states[index].sprite_idx, &cactus_1bit_data[frame_idx]);
	unsigned green_shade = 8 + random() % 8;
	vga_sprite_set_color(cactus_states[index].sprite_idx, RGB(0x0, green_shade, 0x0));
	cactus_update_display(index);
}

void cactus_init()
{
	unsigned prev_x = 800;
	for (int i = 0; i < NUM_CACTUSES; ++i) {
		cactus_states[i].sprite_idx = i + 1;
		cactus_setup_new_state(prev_x, i);
		last_cactus_idx = i;

		prev_x = cactus_states[i].x;
	}
}

int cactus_shift(unsigned dino_x, unsigned dino_y, unsigned pixels)
{
	int collision = 0;
	for (int i = 0; i < NUM_CACTUSES; ++i) {
		if (cactus_states[i].x < pixels) {
			// It would go off screen, move to the right
			cactus_setup_new_state(cactus_states[last_cactus_idx].x, i);
			last_cactus_idx = i;
		} else {
			cactus_states[i].x -= pixels;
			cactus_update_display(i);
			if (!collision) {
				collision = dino_y >= DINO_MIN_HEIGHT
						&& !(dino_x + DINO_RIGHT_OFFSET < cactus_states[i].x + CACTUS_LEFT_OFFSET
							|| dino_x + DINO_LEFT_OFFSET > cactus_states[i].x + CACTUS_RIGHT_OFFSET);
			}
		}
	}
	return collision;
}
