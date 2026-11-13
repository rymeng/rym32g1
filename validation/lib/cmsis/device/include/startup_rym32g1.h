#ifndef STARTUP_RYM32G1_H
#define STARTUP_RYM32G1_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include "rym32g1.h"

typedef void (*IRQHandler_Type)(void);

#if defined(__ARMCC_VERSION) && (__ARMCC_VERSION >= 6100100)
extern uint32_t Image$$ARM_LIB_STACK$$ZI$$Limit;
extern uint32_t Image$$ARM_LIB_STACK$$ZI$$Base;
extern __NO_RETURN void __main(void);
#endif

#if defined(__ICCARM__)
extern uint32_t CSTACK$$Limit;
extern __NO_RETURN void __iar_program_start(void);
#endif

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* STARTUP_RYM32G1_H */
