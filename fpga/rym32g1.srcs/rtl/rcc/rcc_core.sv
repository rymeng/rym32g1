`timescale 1ns / 1ps

module rcc_core (
/* HCLK input */
    input logic hclk_master_i,
/* Flash Model Main Bank */
    output logic hclk_flash_o,
/* SRAM Model */
    output logic hclk_sram_o,
/* GPIO A */
    output logic hclk_gpioa_o,
/* GPIO B */
    output logic hclk_gpiob_o,
/* FMC */
    output logic hclk_fmc_o,
/* AHB to APB bridge */
    output logic hclk_apb1_br_o
);
    /* Distribute the always-on HCLK to each peripheral */
    assign hclk_flash_o = hclk_master_i;
    assign hclk_sram_o = hclk_master_i;
    assign hclk_gpioa_o = hclk_master_i;
    assign hclk_gpiob_o = hclk_master_i;
    assign hclk_fmc_o = hclk_master_i;
    assign hclk_apb1_br_o = hclk_master_i;

endmodule