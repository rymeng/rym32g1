#include "board.h"

void board_uart_init(void)
{
    RCC->AHBENR1.bit.GPIOBENA = 0x1UL;
    RCC->AHBENR2.bit.UART1ENA = 0x1UL;
    __DSB();

    RCC->AHBRSTR1.bit.GPIOBRST = 0x1UL;
    RCC->AHBRSTR2.bit.UART1RST = 0x1UL;
    __DSB();

    RCC->AHBRSTR1.bit.GPIOBRST = 0x0UL;
    RCC->AHBRSTR2.bit.UART1RST = 0x0UL;
    __DSB();

    AF_UART1_TX_PB6();

    UART1->BRR.bit.DIVMANT = 0x1UL;
    UART1->OSRR.bit.OSR = 0x1UL;
    UART1->CR1.bit.DATALEN = 0x7UL;
    UART1->CR1.bit.PARITYEN = 0x0UL;
    UART1->CR1.bit.STOPLEN = 0x1UL;
    __DSB();

    UART1->CR2.bit.TXEN = 0x1UL;
    __DSB();

    return;
}

void board_uart_deinit(void)
{
    RCC->AHBRSTR1.bit.GPIOBRST = 0x1UL;
    RCC->AHBRSTR2.bit.UART1RST = 0x1UL;
    __DSB();

    RCC->AHBRSTR1.bit.GPIOBRST = 0x0UL;
    RCC->AHBRSTR2.bit.UART1RST = 0x0UL;
    __DSB();

    return;
}

_ARMABI __attribute__((__nonnull__(2))) int fputc(int c, FILE *stream)
{
    if (stream == stdout) {
        while (!UART1->ISR.bit.TXRDY) {
            ;
        }
        UART1->TDR.reg = c;
    }

    return c;
}
