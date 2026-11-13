# RYM32G1 Memory Map

| Bridge | Peripheral | Base | Limit | Size |
| :---: | :---: | :---: | :---: | :---: |
|  | FLASH | `0x0000 0000` | `0x0000 FFFF` | 64 KB |
|  | SRAM | `0x2000 0000` | `0x2000 FFFF` | 64 KB |
|  | GPIOA | `0x4008 0000` | `0x4008 03FF` | 1 KB |
|  | GPIOB | `0x4008 0400` | `0x4008 07FF` | 1 KB |
|  | RCC | `0x400B 0000` | `0x400B 0FFF` | 4 KB |
|  | FMC | `0x400B 1000` | `0x400B 1FFF` | 4 KB |
| `APB1` | WWDG | `0x4000 0000` | `0x4000 03FF` | 1 KB |
| `APB1` | UART1 | `0x4000 1000` | `0x4000 13FF` | 1 KB |
| `APB1` | UART2 | `0x4001 1400` | `0x4001 17FF` | 1 KB |
| `APB1` | TUART1 | `0x4001 1800` | `0x4001 1BFF` | 1 KB |
