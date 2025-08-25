/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include <io.h>
#include <system.h>
#include <sys/alt_alarm.h>
#include <sys/alt_timestamp.h>
#include <altera_avalon_pio_regs.h>

#include "vga_driver.h"
#include "seg7_display_driver.h"
#include "background.h"
#include "dino_1bit.h"
#include "dino.h"
#include "cactus.h"

#define SPRITE_WIDTH  48
#define SPRITE_HEIGHT 48

// VGA_SPRITE_STREAM registers
#define VGA_SPRITE_STREAM_ENABLE_REG   1
#define VGA_SPRITE_STREAM_ADDRESS_REG  2
#define VGA_SPRITE_STREAM_XY_REG       3
#define VGA_SPRITE_STREAM_COLOR_REG    4

static volatile int alarm_ticked = 0;

static alt_u32 alarm_callback(void* context)
{
	alarm_ticked = 1;

	return 1;
}

static int button_pressed()
{
	return IORD_ALTERA_AVALON_PIO_DATA(PIO_0_BASE) & 0x01;
}

static void draw_blood()
{
	unsigned x = dino_x + DINO_FRAME_WIDTH / 2 + random() % 50 - 25;
	unsigned y = dino_y + DINO_FRAME_HEIGHT / 2 + random() % 50 - 25;
	unsigned size = random() % 3;
	vga_fill_rectangle(x, y, x + size, y + size, RGB(0xF, 0x0, 0x0));
}

static void init_game(unsigned *bg_shift, int *collision, unsigned *collision_timer, alt_u32 *score)
{
	*bg_shift = 1;
	*collision = 0;
	*collision_timer = 300;

	background_init();
	dino_init();
	cactus_init();

	*score = 0;
	seg7_display_set_number(*score);
	seg7_display_enable(1);
}

static int game_event(alt_u32 now, unsigned *bg_shift, alt_u32 *score)
{
	dino_timer_tick(now);
	background_shift(*bg_shift);
	int collision = cactus_shift(dino_x, dino_y, *bg_shift);

	if (now % 500 == 0) {
	  if (*bg_shift < 7) {
		  ++*bg_shift;
		  dino_increase_speed();
	  } else {
		  dino_init();
		  *bg_shift = 1;
	  }
	}

	if (button_pressed()) {
	  dino_jump(now);
	}

	++*score;
	seg7_display_set_number(*score);

	return collision;
}

int main()
{
	printf("Hello from Nios II, drawing sprites!\n");

	alt_u32 now = 0;
	alt_alarm alarm;
	alt_alarm_start(&alarm, 0, &alarm_callback, NULL);

	printf("ticks_per_second: %lu\n", alt_ticks_per_second());
	printf("timestamp frequency: %lu\n", alt_timestamp_freq());

	unsigned 	bg_shift;
	int 		collision;
	unsigned 	collision_timer;
	alt_u32 	score;
	init_game(&bg_shift, &collision, &collision_timer, &score);

	while (1) {
	  while (!alarm_ticked) {
		  // no-op
	  }
	  alarm_ticked = 0;
	  ++now;
	  if (collision) {
		  if (--collision_timer == 0) {
			  init_game(&bg_shift, &collision, &collision_timer, &score);
		  } else if (collision_timer > 100 && collision_timer % 3 == 0) {
			  draw_blood();
		  }
	  } else {
		  collision = game_event(now, &bg_shift, &score);
	  }
	}

	printf("DONE!\n");

	return 0;
}
