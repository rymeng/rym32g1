#include "algorithm.h"

/* Import framework macros */
#include "framework.h"

static uint16_t crc16(uint8_t *buffer, uint32_t size);
static uint16_t __crc16(uint8_t *buffer, uint32_t size, uint16_t initial_value);

#pragma diag_suppress=Pe186

uint32_t __mem_region_init(uint32_t address)
{
    uint32_t ret = RESULT_OK;

    if ((address >= FLASH_MAIN_BANK_BASE_ADDR) &&
        (address <= FLASH_MAIN_BANK_END_ADDR)) {
        FMC->KEYR.reg = 0x5555AAAAUL;
        __DSB();
        FMC->KEYR.reg = 0x3333CCCCUL;
        __DSB();
    } else {
        ret = RESULT_ERROR;
    }

    return ret;
}

uint32_t __mem_region_deinit(void)
{
    uint32_t ret = RESULT_OK;

    FMC->CR1.bit.LOCK = 1UL;
    __DSB();

    return ret;
}

uint32_t __mem_region_erase_sector(uint32_t address)
{
    uint32_t ret = RESULT_OK;

    if ((address >= FLASH_MAIN_BANK_BASE_ADDR) &&
        (address <= FLASH_MAIN_BANK_LAST_ERASE_UNIT_ADDR)) {
        FMC->ICR.reg = 0xFFFFFFFFUL;
        __DSB();

        FMC->CR1.bit.SEREN = 1UL;
        FMC->AR.reg = address;
        __DSB();

        FMC->CR2.reg = FMC_CR2_START_Msk;
        while (FMC->SR.bit.BUSY) {
            ;
        }

        if (FMC->ISR.bit.DONE) {
            ret = RESULT_OK;
            FMC->ICR.reg = FMC_ICR_DONE_Msk;
            __DSB();
        } else {
            ret = RESULT_ERROR;
        }

        FMC->CR1.bit.SEREN = 0UL;
        __DSB();
    } else {
        ret = RESULT_ERROR;
    }

    return ret;
}

uint32_t __mem_region_program(uint32_t address, uint32_t size, uint8_t *buffer)
{
    uint32_t ret = RESULT_OK;

    if ((address >= FLASH_MAIN_BANK_BASE_ADDR) &&
        (address <= FLASH_MAIN_BANK_LAST_PROGRAM_UNIT_ADDR)) {
        FMC->ICR.reg = 0xFFFFFFFFUL;
        __DSB();

        uint32_t aligned_size = ALIGN(size, PROGRAM_SIZE);
        if (aligned_size != size) {
            memset(buffer + size, 0xFF, aligned_size - size);
            size = aligned_size;
        }

        FMC->CR1.bit.PGEN = 1UL;
        __DSB();

        for (uint32_t i = 0UL; i < size; i += PROGRAM_SIZE) {
            *(volatile uint64_t *)(address + i) = *(uint64_t *)(buffer + i);
            __DSB();
            while (FMC->SR.bit.BUSY) {
                ;
            }
        }

        if (FMC->ISR.bit.DONE) {
            FMC->ICR.reg = FMC_ICR_DONE_Msk;
            __DSB();
            if (FMC->ISR.bit.PGERR || FMC->ISR.bit.PGNALN) {
                ret = RESULT_ERROR;
            } else {
                ret = RESULT_OK;
            }
        } else {
            ret = RESULT_ERROR;
        }

        FMC->CR1.bit.PGEN = 0UL;
        __DSB();
    } else {
        ret = RESULT_ERROR;
    }

    return ret;
}

uint32_t __mem_region_verify(uint32_t address, uint32_t size)
{
    uint8_t *buffer = (uint8_t *)address;

    return crc16(buffer, size);
}

static uint16_t crc16(uint8_t *buffer, uint32_t size)
{
    uint8_t data_tail[2UL] = {0U, 0U};
    uint16_t result = 0U;

    result = __crc16(buffer, size, result);
    result = __crc16(data_tail, 2UL, result);

    return result;
}

static uint16_t __crc16(uint8_t *buffer, uint32_t size, uint16_t initial_value)
{
    uint16_t result = initial_value;

    while (size--) {
        uint8_t current_byte = *buffer;
        for (uint32_t i = 0UL; i < 8UL; ++i) {
            uint16_t last_result = result;
            result <<= 1UL;
            if (current_byte & 0x80U) {
                result |= 0x1U;
            }
            if (last_result & 0x8000U) {
                result ^= 0x1021U;
            }
            current_byte <<= 1UL;
        }
        ++buffer;
    }

    return result;
}

#pragma diag_default=Pe186
