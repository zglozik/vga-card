
#include "seg7_display_driver.h"

#include <io.h>
#include <system.h>

// Hardware registers for 7 segment display control
#define SEG7_NUMBER_DISPLAY_REG_ENABLE	0
#define SEG7_NUMBER_DISPLAY_REG_NUMBER	1

void seg7_display_enable(int flag)
{
	IOWR(SEG7_NUMBER_DISPLAY_0_BASE, SEG7_NUMBER_DISPLAY_REG_ENABLE, flag);
}

void seg7_display_set_number(alt_u32 number)
{
	IOWR(SEG7_NUMBER_DISPLAY_0_BASE, SEG7_NUMBER_DISPLAY_REG_NUMBER, number);
}
