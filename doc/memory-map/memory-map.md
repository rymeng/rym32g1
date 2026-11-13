# RYM32 Memory Map

| Slave port | Peripheral | Base address | Size |
| --- | --- | --- | --- |
| `rcc` | RCC | `0x400B_0000` | 4 KB |
| `flash` | Flash Model | `0x0000_0000` | 64 KB |
| `sram` | SRAM Model | `0x2000_0000` | 64 KB |
| `gpioa` | GPIOA | `0x4008_0000` | 1 KB |
| `gpiob` | GPIOB | `0x4008_0400` | 1 KB |
| `fmc` | FMC | `0x400B_1000` | 4 KB |
| `apb1_br` | APB1 bridge | `0x4000_0000` | 128 KB |

## APB1 ports

| APB port | Peripheral | Base address | Size |
| --- | --- | --- | --- |
| `wwdg` | WWDG | `0x4000_0000` | 1 KB |
| `uart1` | UART1 | `0x4000_1000` | 1 KB |
| `uart2` | UART2 | `0x4001_1400` | 1 KB |
| `tuart1` | TUART1 | `0x4001_1800` | 1 KB |
