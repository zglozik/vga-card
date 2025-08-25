
#ifndef DINO_H_
#define DINO_H_

#include <alt_types.h>

extern unsigned dino_x, dino_y;

void dino_init();

void dino_timer_tick(alt_u32 now);

void dino_increase_speed();

void dino_jump(alt_u32 now);

#endif /* DINO_H_ */
