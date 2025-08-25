
#ifndef CACTUS_H_
#define CACTUS_H_

#include <alt_types.h>

void cactus_init();

// Return true if one of the cactuses collides with the dino
int cactus_shift(unsigned dino_x, unsigned dino_y, unsigned pixels);

#endif /* CACTUS_H_ */
