#include <stdint.h>
#include "openrisc.h"
#include "uart16550.h"
#include "board.h"

void delay(unsigned int t)
{
	volatile uint32_t i, j;
	for(i = 0; i < t; i++)
		for(j = 0; j < 1024; j++);
}

int main(void)
{
	volatile int num;

    // GPIO
	*((volatile uint32_t *)(GPIO_BASE + 8)) = 0xff;
	*((volatile uint32_t *)(GPIO_BASE + 4)) = 0xaa;

    // UART 115200 8N1
    uart_init(27);
    uart_puts("OpenRISC Boot ...\r\n");

	while(1) {
		*((volatile uint32_t *)(DDR_BASE + 0x10)) = 0xaa;
		num = *((volatile uint32_t *)(DDR_BASE + 0x10));
		*((volatile uint32_t *)(GPIO_BASE + 4)) = num;
		delay(5000);
		*((volatile uint32_t *)(DDR_BASE + 0x10)) = 0x55;
		num = *((volatile uint32_t *)(DDR_BASE + 0x10));
        *((volatile uint32_t *)(GPIO_BASE + 4)) = num;
		delay(5000);
	}

	return 0;
}
