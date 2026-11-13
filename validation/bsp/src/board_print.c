#include "board_print.h"

void board_print_serial_port_init(uint32_t hclk_rate_hz, uint32_t baud_rate)
{
    (void)hclk_rate_hz;
    (void)baud_rate;

    return;
}

#if defined(__ARMCC_VERSION) && (__ARMCC_VERSION >= 6100100)
_ARMABI __attribute__((__nonnull__(2))) int fputc(int c, FILE *stream)
{
    if (stream == stdout) {
        ;
    } else {
        ;
    }

    return c;
}
#elif defined(__ICCARM__)
#endif
