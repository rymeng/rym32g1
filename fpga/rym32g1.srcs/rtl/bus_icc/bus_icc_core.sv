`timescale 1ns / 1ps

module bus_icc_core (
    /* Bus matrix clock and reset signal */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    /* Remap signal */
    input  logic [3:0]  remap_i,
    /* Cortex-M3 IBUS */
    input  logic        hsel_cm3_ibus_i,
    input  logic [31:0] haddr_cm3_ibus_i,
    input  logic        hwrite_cm3_ibus_i,
    input  logic [2:0]  hsize_cm3_ibus_i,
    input  logic [2:0]  hburst_cm3_ibus_i,
    input  logic [3:0]  hprot_cm3_ibus_i,
    input  logic [3:0]  hmaster_cm3_ibus_i,
    input  logic [1:0]  htrans_cm3_ibus_i,
    input  logic        hmastlock_cm3_ibus_i,
    input  logic [31:0] hwdata_cm3_ibus_i,
    input  logic        hready_cm3_ibus_i,
    output logic        hreadyout_cm3_ibus_o,
    output logic        hresp_cm3_ibus_o,
    output logic [31:0] hrdata_cm3_ibus_o,
    /* Cortex-M3 DBUS */
    input  logic        hsel_cm3_dbus_i,
    input  logic [31:0] haddr_cm3_dbus_i,
    input  logic        hwrite_cm3_dbus_i,
    input  logic [2:0]  hsize_cm3_dbus_i,
    input  logic [2:0]  hburst_cm3_dbus_i,
    input  logic [3:0]  hprot_cm3_dbus_i,
    input  logic [3:0]  hmaster_cm3_dbus_i,
    input  logic [1:0]  htrans_cm3_dbus_i,
    input  logic        hmastlock_cm3_dbus_i,
    input  logic [31:0] hwdata_cm3_dbus_i,
    input  logic        hready_cm3_dbus_i,
    output logic        hreadyout_cm3_dbus_o,
    output logic        hresp_cm3_dbus_o,
    output logic [31:0] hrdata_cm3_dbus_o,
    /* Cortex-M3 SBUS */
    input  logic        hsel_cm3_sbus_i,
    input  logic [31:0] haddr_cm3_sbus_i,
    input  logic        hwrite_cm3_sbus_i,
    input  logic [2:0]  hsize_cm3_sbus_i,
    input  logic [2:0]  hburst_cm3_sbus_i,
    input  logic [3:0]  hprot_cm3_sbus_i,
    input  logic [3:0]  hmaster_cm3_sbus_i,
    input  logic [1:0]  htrans_cm3_sbus_i,
    input  logic        hmastlock_cm3_sbus_i,
    input  logic [31:0] hwdata_cm3_sbus_i,
    input  logic        hready_cm3_sbus_i,
    output logic        hreadyout_cm3_sbus_o,
    output logic        hresp_cm3_sbus_o,
    output logic [31:0] hrdata_cm3_sbus_o,
    /* RCC */
    output logic        hsel_rcc_o,
    output logic [31:0] haddr_rcc_o,
    output logic        hwrite_rcc_o,
    output logic [2:0]  hsize_rcc_o,
    output logic [3:0]  hmaster_rcc_o,
    output logic [1:0]  htrans_rcc_o,
    output logic [2:0]  hburst_rcc_o,
    output logic [3:0]  hprot_rcc_o,
    output logic        hmastlock_rcc_o,
    output logic        hready_rcc_o,
    output logic [31:0] hwdata_rcc_o,
    input  logic        hreadyout_rcc_i,
    input  logic        hresp_rcc_i,
    input  logic [31:0] hrdata_rcc_i,
    /* Flash */
    output logic        hsel_flash_o,
    output logic [31:0] haddr_flash_o,
    output logic        hwrite_flash_o,
    output logic [2:0]  hsize_flash_o,
    output logic [3:0]  hmaster_flash_o,
    output logic [1:0]  htrans_flash_o,
    output logic [2:0]  hburst_flash_o,
    output logic [3:0]  hprot_flash_o,
    output logic        hmastlock_flash_o,
    output logic        hready_flash_o,
    output logic [31:0] hwdata_flash_o,
    input  logic        hreadyout_flash_i,
    input  logic        hresp_flash_i,
    input  logic [31:0] hrdata_flash_i,
    /* SRAM */
    output logic        hsel_sram_o,
    output logic [31:0] haddr_sram_o,
    output logic        hwrite_sram_o,
    output logic [2:0]  hsize_sram_o,
    output logic [3:0]  hmaster_sram_o,
    output logic [1:0]  htrans_sram_o,
    output logic [2:0]  hburst_sram_o,
    output logic [3:0]  hprot_sram_o,
    output logic        hmastlock_sram_o,
    output logic        hready_sram_o,
    output logic [31:0] hwdata_sram_o,
    input  logic        hreadyout_sram_i,
    input  logic        hresp_sram_i,
    input  logic [31:0] hrdata_sram_i,
    /* GPIOA */
    output logic        hsel_gpioa_o,
    output logic [31:0] haddr_gpioa_o,
    output logic        hwrite_gpioa_o,
    output logic [2:0]  hsize_gpioa_o,
    output logic [3:0]  hmaster_gpioa_o,
    output logic [1:0]  htrans_gpioa_o,
    output logic [2:0]  hburst_gpioa_o,
    output logic [3:0]  hprot_gpioa_o,
    output logic        hmastlock_gpioa_o,
    output logic        hready_gpioa_o,
    output logic [31:0] hwdata_gpioa_o,
    input  logic        hreadyout_gpioa_i,
    input  logic        hresp_gpioa_i,
    input  logic [31:0] hrdata_gpioa_i,
    /* GPIOB */
    output logic        hsel_gpiob_o,
    output logic [31:0] haddr_gpiob_o,
    output logic        hwrite_gpiob_o,
    output logic [2:0]  hsize_gpiob_o,
    output logic [3:0]  hmaster_gpiob_o,
    output logic [1:0]  htrans_gpiob_o,
    output logic [2:0]  hburst_gpiob_o,
    output logic [3:0]  hprot_gpiob_o,
    output logic        hmastlock_gpiob_o,
    output logic        hready_gpiob_o,
    output logic [31:0] hwdata_gpiob_o,
    input  logic        hreadyout_gpiob_i,
    input  logic        hresp_gpiob_i,
    input  logic [31:0] hrdata_gpiob_i,
    /* FMC */
    output logic        hsel_fmc_o,
    output logic [31:0] haddr_fmc_o,
    output logic        hwrite_fmc_o,
    output logic [2:0]  hsize_fmc_o,
    output logic [3:0]  hmaster_fmc_o,
    output logic [1:0]  htrans_fmc_o,
    output logic [2:0]  hburst_fmc_o,
    output logic [3:0]  hprot_fmc_o,
    output logic        hmastlock_fmc_o,
    output logic        hready_fmc_o,
    output logic [31:0] hwdata_fmc_o,
    input  logic        hreadyout_fmc_i,
    input  logic        hresp_fmc_i,
    input  logic [31:0] hrdata_fmc_i,
    /* APB1 bridge */
    output logic        hsel_apb1_br_o,
    output logic [31:0] haddr_apb1_br_o,
    output logic        hwrite_apb1_br_o,
    output logic [2:0]  hsize_apb1_br_o,
    output logic [3:0]  hmaster_apb1_br_o,
    output logic [1:0]  htrans_apb1_br_o,
    output logic [2:0]  hburst_apb1_br_o,
    output logic [3:0]  hprot_apb1_br_o,
    output logic        hmastlock_apb1_br_o,
    output logic        hready_apb1_br_o,
    output logic [31:0] hwdata_apb1_br_o,
    input  logic        hreadyout_apb1_br_i,
    input  logic        hresp_apb1_br_i,
    input  logic [31:0] hrdata_apb1_br_i
);
    /* Remap function: @todo */

    /* From Cortex-M3 IBUS stage signals */
    logic        hsel_from_cm3_ibus_stage_to_cm3_ibus_decoder;
    logic [31:0] haddr_from_cm3_ibus_stage_to_cm3_ibus_decoder;
    logic [31:0] haddr_from_cm3_ibus_stage_to_all_slave_stage;
    logic        hwrite_from_cm3_ibus_stage_to_all_slave_stage;
    logic [2:0]  hsize_from_cm3_ibus_stage_to_all_slave_stage;
    logic [2:0]  hburst_from_cm3_ibus_stage_to_all_slave_stage;
    logic [3:0]  hprot_from_cm3_ibus_stage_to_all_slave_stage;
    logic [3:0]  hmaster_from_cm3_ibus_stage_to_all_slave_stage;
    logic [1:0]  htrans_from_cm3_ibus_stage_to_cm3_ibus_decoder;
    logic [1:0]  htrans_from_cm3_ibus_stage_to_all_slave_stage;
    logic        hmastlock_from_cm3_ibus_stage_to_all_slave_stage;
    logic        xfer_req_from_cm3_ibus_stage_to_all_slave_stage;

    /* From Cortex-M3 DBUS stage signals */
    logic        hsel_from_cm3_dbus_stage_to_cm3_dbus_decoder;
    logic [31:0] haddr_from_cm3_dbus_stage_to_cm3_dbus_decoder;
    logic [31:0] haddr_from_cm3_dbus_stage_to_all_slave_stage;
    logic        hwrite_from_cm3_dbus_stage_to_all_slave_stage;
    logic [2:0]  hsize_from_cm3_dbus_stage_to_all_slave_stage;
    logic [2:0]  hburst_from_cm3_dbus_stage_to_all_slave_stage;
    logic [3:0]  hprot_from_cm3_dbus_stage_to_all_slave_stage;
    logic [3:0]  hmaster_from_cm3_dbus_stage_to_all_slave_stage;
    logic [1:0]  htrans_from_cm3_dbus_stage_to_cm3_dbus_decoder;
    logic [1:0]  htrans_from_cm3_dbus_stage_to_all_slave_stage;
    logic        hmastlock_from_cm3_dbus_stage_to_all_slave_stage;
    logic        xfer_req_from_cm3_dbus_stage_to_all_slave_stage;

    /* From Cortex-M3 SBUS stage signals */
    logic        hsel_from_cm3_sbus_stage_to_cm3_sbus_decoder;
    logic [31:0] haddr_from_cm3_sbus_stage_to_cm3_sbus_decoder;
    logic [31:0] haddr_from_cm3_sbus_stage_to_all_slave_stage;
    logic        hwrite_from_cm3_sbus_stage_to_all_slave_stage;
    logic [2:0]  hsize_from_cm3_sbus_stage_to_all_slave_stage;
    logic [2:0]  hburst_from_cm3_sbus_stage_to_all_slave_stage;
    logic [3:0]  hprot_from_cm3_sbus_stage_to_all_slave_stage;
    logic [3:0]  hmaster_from_cm3_sbus_stage_to_all_slave_stage;
    logic [1:0]  htrans_from_cm3_sbus_stage_to_cm3_sbus_decoder;
    logic [1:0]  htrans_from_cm3_sbus_stage_to_all_slave_stage;
    logic        hmastlock_from_cm3_sbus_stage_to_all_slave_stage;
    logic        xfer_req_from_cm3_sbus_stage_to_all_slave_stage;

    /* From Cortex-M3 IBUS decoder signals */
    logic        hsel_from_cm3_ibus_decoder_to_rcc_stage;
    logic        hsel_from_cm3_ibus_decoder_to_flash_stage;
    logic        hsel_from_cm3_ibus_decoder_to_sram_stage;
    logic        hsel_from_cm3_ibus_decoder_to_gpioa_stage;
    logic        hsel_from_cm3_ibus_decoder_to_gpiob_stage;
    logic        hsel_from_cm3_ibus_decoder_to_fmc_stage;
    logic        hsel_from_cm3_ibus_decoder_to_apb1_br_stage;
    logic        hreadyout_from_cm3_ibus_decoder_to_cm3_ibus_stage;
    logic        hresp_from_cm3_ibus_decoder_to_cm3_ibus_stage;
    logic        xfer_granted_from_cm3_ibus_decoder_to_cm3_ibus_stage;

    /* From Cortex-M3 DBUS decoder signals */
    logic        hsel_from_cm3_dbus_decoder_to_rcc_stage;
    logic        hsel_from_cm3_dbus_decoder_to_flash_stage;
    logic        hsel_from_cm3_dbus_decoder_to_sram_stage;
    logic        hsel_from_cm3_dbus_decoder_to_gpioa_stage;
    logic        hsel_from_cm3_dbus_decoder_to_gpiob_stage;
    logic        hsel_from_cm3_dbus_decoder_to_fmc_stage;
    logic        hsel_from_cm3_dbus_decoder_to_apb1_br_stage;
    logic        hreadyout_from_cm3_dbus_decoder_to_cm3_dbus_stage;
    logic        hresp_from_cm3_dbus_decoder_to_cm3_dbus_stage;
    logic        xfer_granted_from_cm3_dbus_decoder_to_cm3_dbus_stage;

    /* From Cortex-M3 SBUS decoder signals */
    logic        hsel_from_cm3_sbus_decoder_to_rcc_stage;
    logic        hsel_from_cm3_sbus_decoder_to_flash_stage;
    logic        hsel_from_cm3_sbus_decoder_to_sram_stage;
    logic        hsel_from_cm3_sbus_decoder_to_gpioa_stage;
    logic        hsel_from_cm3_sbus_decoder_to_gpiob_stage;
    logic        hsel_from_cm3_sbus_decoder_to_fmc_stage;
    logic        hsel_from_cm3_sbus_decoder_to_apb1_br_stage;
    logic        hreadyout_from_cm3_sbus_decoder_to_cm3_sbus_stage;
    logic        hresp_from_cm3_sbus_decoder_to_cm3_sbus_stage;
    logic        xfer_granted_from_cm3_sbus_decoder_to_cm3_sbus_stage;

    /* From RCC stage signals */
    logic        hready_rcc;
    logic        hreadyout_from_rcc_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_rcc_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_rcc_stage_to_cm3_sbus_decoder;
    logic        hresp_from_rcc_stage_to_cm3_ibus_decoder;
    logic        hresp_from_rcc_stage_to_cm3_dbus_decoder;
    logic        hresp_from_rcc_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_rcc_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_rcc_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_rcc_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_rcc_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_rcc_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_rcc_stage_to_cm3_sbus_decoder;

    /* From Flash stage signals */
    logic        hready_flash;
    logic        hreadyout_from_flash_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_flash_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_flash_stage_to_cm3_sbus_decoder;
    logic        hresp_from_flash_stage_to_cm3_ibus_decoder;
    logic        hresp_from_flash_stage_to_cm3_dbus_decoder;
    logic        hresp_from_flash_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_flash_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_flash_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_flash_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_flash_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_flash_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_flash_stage_to_cm3_sbus_decoder;

    /* From SRAM stage signals */
    logic        hready_sram;
    logic        hreadyout_from_sram_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_sram_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_sram_stage_to_cm3_sbus_decoder;
    logic        hresp_from_sram_stage_to_cm3_ibus_decoder;
    logic        hresp_from_sram_stage_to_cm3_dbus_decoder;
    logic        hresp_from_sram_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_sram_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_sram_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_sram_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_sram_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_sram_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_sram_stage_to_cm3_sbus_decoder;

    /* From GPIOA stage signals */
    logic        hready_gpioa;
    logic        hreadyout_from_gpioa_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_gpioa_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_gpioa_stage_to_cm3_sbus_decoder;
    logic        hresp_from_gpioa_stage_to_cm3_ibus_decoder;
    logic        hresp_from_gpioa_stage_to_cm3_dbus_decoder;
    logic        hresp_from_gpioa_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_gpioa_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_gpioa_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_gpioa_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_gpioa_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_gpioa_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_gpioa_stage_to_cm3_sbus_decoder;

    /* From GPIOB stage signals */
    logic        hready_gpiob;
    logic        hreadyout_from_gpiob_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_gpiob_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_gpiob_stage_to_cm3_sbus_decoder;
    logic        hresp_from_gpiob_stage_to_cm3_ibus_decoder;
    logic        hresp_from_gpiob_stage_to_cm3_dbus_decoder;
    logic        hresp_from_gpiob_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_gpiob_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_gpiob_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_gpiob_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_gpiob_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_gpiob_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_gpiob_stage_to_cm3_sbus_decoder;

    /* From FMC stage signals */
    logic        hready_fmc;
    logic        hreadyout_from_fmc_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_fmc_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_fmc_stage_to_cm3_sbus_decoder;
    logic        hresp_from_fmc_stage_to_cm3_ibus_decoder;
    logic        hresp_from_fmc_stage_to_cm3_dbus_decoder;
    logic        hresp_from_fmc_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_fmc_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_fmc_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_fmc_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_fmc_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_fmc_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_fmc_stage_to_cm3_sbus_decoder;

    /* From APB1 bridge stage signals */
    logic        hready_apb1_br;
    logic        hreadyout_from_apb1_br_stage_to_cm3_ibus_decoder;
    logic        hreadyout_from_apb1_br_stage_to_cm3_dbus_decoder;
    logic        hreadyout_from_apb1_br_stage_to_cm3_sbus_decoder;
    logic        hresp_from_apb1_br_stage_to_cm3_ibus_decoder;
    logic        hresp_from_apb1_br_stage_to_cm3_dbus_decoder;
    logic        hresp_from_apb1_br_stage_to_cm3_sbus_decoder;
    logic [31:0] hrdata_from_apb1_br_stage_to_cm3_ibus_decoder;
    logic [31:0] hrdata_from_apb1_br_stage_to_cm3_dbus_decoder;
    logic [31:0] hrdata_from_apb1_br_stage_to_cm3_sbus_decoder;
    logic        xfer_granted_from_apb1_br_stage_to_cm3_ibus_decoder;
    logic        xfer_granted_from_apb1_br_stage_to_cm3_dbus_decoder;
    logic        xfer_granted_from_apb1_br_stage_to_cm3_sbus_decoder;

    /* Cortex-M3 IBUS stage */
    bus_icc_master_stage bus_icc_cm3_ibus_stage (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_cm3_ibus_i),
        .haddr_master_i          (haddr_cm3_ibus_i),
        .hwrite_master_i         (hwrite_cm3_ibus_i),
        .hsize_master_i          (hsize_cm3_ibus_i),
        .hburst_master_i         (hburst_cm3_ibus_i),
        .hprot_master_i          (hprot_cm3_ibus_i),
        .hmaster_master_i        (hmaster_cm3_ibus_i),
        .htrans_master_i         (htrans_cm3_ibus_i),
        .hmastlock_master_i      (hmastlock_cm3_ibus_i),
        .hready_master_i         (hready_cm3_ibus_i),
        .hreadyout_master_o      (hreadyout_cm3_ibus_o),
        .hresp_master_o          (hresp_cm3_ibus_o),
        .hsel_decoder_o          (hsel_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .haddr_decoder_o         (haddr_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .htrans_decoder_o        (htrans_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .hreadyout_decoder_i     (hreadyout_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .hresp_decoder_i         (hresp_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .xfer_granted_decoder_i  (xfer_granted_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .haddr_slave_stage_o     (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_slave_stage_o    (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_slave_stage_o     (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_slave_stage_o   (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_slave_stage_o    (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_slave_stage_o    (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_slave_stage_o     (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_slave_stage_o (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .xfer_req_slave_stage_o  (xfer_req_from_cm3_ibus_stage_to_all_slave_stage)
    );

    /* Cortex-M3 DBUS stage */
    bus_icc_master_stage bus_icc_cm3_dbus_stage (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_cm3_dbus_i),
        .haddr_master_i          (haddr_cm3_dbus_i),
        .hwrite_master_i         (hwrite_cm3_dbus_i),
        .hsize_master_i          (hsize_cm3_dbus_i),
        .hburst_master_i         (hburst_cm3_dbus_i),
        .hprot_master_i          (hprot_cm3_dbus_i),
        .hmaster_master_i        (hmaster_cm3_dbus_i),
        .htrans_master_i         (htrans_cm3_dbus_i),
        .hmastlock_master_i      (hmastlock_cm3_dbus_i),
        .hready_master_i         (hready_cm3_dbus_i),
        .hreadyout_master_o      (hreadyout_cm3_dbus_o),
        .hresp_master_o          (hresp_cm3_dbus_o),
        .hsel_decoder_o          (hsel_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .haddr_decoder_o         (haddr_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .htrans_decoder_o        (htrans_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .hreadyout_decoder_i     (hreadyout_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .hresp_decoder_i         (hresp_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .xfer_granted_decoder_i  (xfer_granted_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .haddr_slave_stage_o     (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_slave_stage_o    (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_slave_stage_o     (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_slave_stage_o   (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_slave_stage_o    (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_slave_stage_o    (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_slave_stage_o     (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_slave_stage_o (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .xfer_req_slave_stage_o  (xfer_req_from_cm3_dbus_stage_to_all_slave_stage)
    );

    /* Cortex-M3 SBUS stage */
    bus_icc_master_stage bus_icc_cm3_sbus_stage (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_cm3_sbus_i),
        .haddr_master_i          (haddr_cm3_sbus_i),
        .hwrite_master_i         (hwrite_cm3_sbus_i),
        .hsize_master_i          (hsize_cm3_sbus_i),
        .hburst_master_i         (hburst_cm3_sbus_i),
        .hprot_master_i          (hprot_cm3_sbus_i),
        .hmaster_master_i        (hmaster_cm3_sbus_i),
        .htrans_master_i         (htrans_cm3_sbus_i),
        .hmastlock_master_i      (hmastlock_cm3_sbus_i),
        .hready_master_i         (hready_cm3_sbus_i),
        .hreadyout_master_o      (hreadyout_cm3_sbus_o),
        .hresp_master_o          (hresp_cm3_sbus_o),
        .hsel_decoder_o          (hsel_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .haddr_decoder_o         (haddr_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .htrans_decoder_o        (htrans_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .hreadyout_decoder_i     (hreadyout_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .hresp_decoder_i         (hresp_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .xfer_granted_decoder_i  (xfer_granted_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .haddr_slave_stage_o     (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_slave_stage_o    (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_slave_stage_o     (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_slave_stage_o   (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_slave_stage_o    (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_slave_stage_o    (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_slave_stage_o     (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_slave_stage_o (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .xfer_req_slave_stage_o  (xfer_req_from_cm3_sbus_stage_to_all_slave_stage)
    );

    /* Cortex-M3 IBUS decoder */
    bus_icc_decoder bus_icc_cm3_ibus_decoder (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (hsel_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .haddr_master_stage_i        (haddr_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .htrans_master_stage_i       (htrans_from_cm3_ibus_stage_to_cm3_ibus_decoder),
        .hready_master_stage_i       (hready_cm3_ibus_i),
        .hreadyout_master_stage_o    (hreadyout_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .hresp_master_stage_o        (hresp_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .hrdata_master_stage_o       (hrdata_cm3_ibus_o),
        .master_stage_xfer_granted_o (xfer_granted_from_cm3_ibus_decoder_to_cm3_ibus_stage),
        .hsel_rcc_o                  (hsel_from_cm3_ibus_decoder_to_rcc_stage),
        .hreadyout_rcc_i             (hreadyout_from_rcc_stage_to_cm3_ibus_decoder),
        .hresp_rcc_i                 (hresp_from_rcc_stage_to_cm3_ibus_decoder),
        .hrdata_rcc_i                (hrdata_from_rcc_stage_to_cm3_ibus_decoder),
        .rcc_xfer_granted_i          (xfer_granted_from_rcc_stage_to_cm3_ibus_decoder),
        .hsel_flash_o                (hsel_from_cm3_ibus_decoder_to_flash_stage),
        .hreadyout_flash_i           (hreadyout_from_flash_stage_to_cm3_ibus_decoder),
        .hresp_flash_i               (hresp_from_flash_stage_to_cm3_ibus_decoder),
        .hrdata_flash_i              (hrdata_from_flash_stage_to_cm3_ibus_decoder),
        .flash_xfer_granted_i        (xfer_granted_from_flash_stage_to_cm3_ibus_decoder),
        .hsel_sram_o                 (hsel_from_cm3_ibus_decoder_to_sram_stage),
        .hreadyout_sram_i            (hreadyout_from_sram_stage_to_cm3_ibus_decoder),
        .hresp_sram_i                (hresp_from_sram_stage_to_cm3_ibus_decoder),
        .hrdata_sram_i               (hrdata_from_sram_stage_to_cm3_ibus_decoder),
        .sram_xfer_granted_i         (xfer_granted_from_sram_stage_to_cm3_ibus_decoder),
        .hsel_gpioa_o                (hsel_from_cm3_ibus_decoder_to_gpioa_stage),
        .hreadyout_gpioa_i           (hreadyout_from_gpioa_stage_to_cm3_ibus_decoder),
        .hresp_gpioa_i               (hresp_from_gpioa_stage_to_cm3_ibus_decoder),
        .hrdata_gpioa_i              (hrdata_from_gpioa_stage_to_cm3_ibus_decoder),
        .gpioa_xfer_granted_i        (xfer_granted_from_gpioa_stage_to_cm3_ibus_decoder),
        .hsel_gpiob_o                (hsel_from_cm3_ibus_decoder_to_gpiob_stage),
        .hreadyout_gpiob_i           (hreadyout_from_gpiob_stage_to_cm3_ibus_decoder),
        .hresp_gpiob_i               (hresp_from_gpiob_stage_to_cm3_ibus_decoder),
        .hrdata_gpiob_i              (hrdata_from_gpiob_stage_to_cm3_ibus_decoder),
        .gpiob_xfer_granted_i        (xfer_granted_from_gpiob_stage_to_cm3_ibus_decoder),
        .hsel_fmc_o                  (hsel_from_cm3_ibus_decoder_to_fmc_stage),
        .hreadyout_fmc_i             (hreadyout_from_fmc_stage_to_cm3_ibus_decoder),
        .hresp_fmc_i                 (hresp_from_fmc_stage_to_cm3_ibus_decoder),
        .hrdata_fmc_i                (hrdata_from_fmc_stage_to_cm3_ibus_decoder),
        .fmc_xfer_granted_i          (xfer_granted_from_fmc_stage_to_cm3_ibus_decoder),
        .hsel_apb1_br_o              (hsel_from_cm3_ibus_decoder_to_apb1_br_stage),
        .hreadyout_apb1_br_i         (hreadyout_from_apb1_br_stage_to_cm3_ibus_decoder),
        .hresp_apb1_br_i             (hresp_from_apb1_br_stage_to_cm3_ibus_decoder),
        .hrdata_apb1_br_i            (hrdata_from_apb1_br_stage_to_cm3_ibus_decoder),
        .apb1_br_xfer_granted_i      (xfer_granted_from_apb1_br_stage_to_cm3_ibus_decoder)
    );

    /* Cortex-M3 DBUS decoder */
    bus_icc_decoder bus_icc_cm3_dbus_decoder (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (hsel_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .haddr_master_stage_i        (haddr_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .htrans_master_stage_i       (htrans_from_cm3_dbus_stage_to_cm3_dbus_decoder),
        .hready_master_stage_i       (hready_cm3_dbus_i),
        .hreadyout_master_stage_o    (hreadyout_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .hresp_master_stage_o        (hresp_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .hrdata_master_stage_o       (hrdata_cm3_dbus_o),
        .master_stage_xfer_granted_o (xfer_granted_from_cm3_dbus_decoder_to_cm3_dbus_stage),
        .hsel_rcc_o                  (hsel_from_cm3_dbus_decoder_to_rcc_stage),
        .hreadyout_rcc_i             (hreadyout_from_rcc_stage_to_cm3_dbus_decoder),
        .hresp_rcc_i                 (hresp_from_rcc_stage_to_cm3_dbus_decoder),
        .hrdata_rcc_i                (hrdata_from_rcc_stage_to_cm3_dbus_decoder),
        .rcc_xfer_granted_i          (xfer_granted_from_rcc_stage_to_cm3_dbus_decoder),
        .hsel_flash_o                (hsel_from_cm3_dbus_decoder_to_flash_stage),
        .hreadyout_flash_i           (hreadyout_from_flash_stage_to_cm3_dbus_decoder),
        .hresp_flash_i               (hresp_from_flash_stage_to_cm3_dbus_decoder),
        .hrdata_flash_i              (hrdata_from_flash_stage_to_cm3_dbus_decoder),
        .flash_xfer_granted_i        (xfer_granted_from_flash_stage_to_cm3_dbus_decoder),
        .hsel_sram_o                 (hsel_from_cm3_dbus_decoder_to_sram_stage),
        .hreadyout_sram_i            (hreadyout_from_sram_stage_to_cm3_dbus_decoder),
        .hresp_sram_i                (hresp_from_sram_stage_to_cm3_dbus_decoder),
        .hrdata_sram_i               (hrdata_from_sram_stage_to_cm3_dbus_decoder),
        .sram_xfer_granted_i         (xfer_granted_from_sram_stage_to_cm3_dbus_decoder),
        .hsel_gpioa_o                (hsel_from_cm3_dbus_decoder_to_gpioa_stage),
        .hreadyout_gpioa_i           (hreadyout_from_gpioa_stage_to_cm3_dbus_decoder),
        .hresp_gpioa_i               (hresp_from_gpioa_stage_to_cm3_dbus_decoder),
        .hrdata_gpioa_i              (hrdata_from_gpioa_stage_to_cm3_dbus_decoder),
        .gpioa_xfer_granted_i        (xfer_granted_from_gpioa_stage_to_cm3_dbus_decoder),
        .hsel_gpiob_o                (hsel_from_cm3_dbus_decoder_to_gpiob_stage),
        .hreadyout_gpiob_i           (hreadyout_from_gpiob_stage_to_cm3_dbus_decoder),
        .hresp_gpiob_i               (hresp_from_gpiob_stage_to_cm3_dbus_decoder),
        .hrdata_gpiob_i              (hrdata_from_gpiob_stage_to_cm3_dbus_decoder),
        .gpiob_xfer_granted_i        (xfer_granted_from_gpiob_stage_to_cm3_dbus_decoder),
        .hsel_fmc_o                  (hsel_from_cm3_dbus_decoder_to_fmc_stage),
        .hreadyout_fmc_i             (hreadyout_from_fmc_stage_to_cm3_dbus_decoder),
        .hresp_fmc_i                 (hresp_from_fmc_stage_to_cm3_dbus_decoder),
        .hrdata_fmc_i                (hrdata_from_fmc_stage_to_cm3_dbus_decoder),
        .fmc_xfer_granted_i          (xfer_granted_from_fmc_stage_to_cm3_dbus_decoder),
        .hsel_apb1_br_o              (hsel_from_cm3_dbus_decoder_to_apb1_br_stage),
        .hreadyout_apb1_br_i         (hreadyout_from_apb1_br_stage_to_cm3_dbus_decoder),
        .hresp_apb1_br_i             (hresp_from_apb1_br_stage_to_cm3_dbus_decoder),
        .hrdata_apb1_br_i            (hrdata_from_apb1_br_stage_to_cm3_dbus_decoder),
        .apb1_br_xfer_granted_i      (xfer_granted_from_apb1_br_stage_to_cm3_dbus_decoder)
    );

    /* Cortex-M3 SBUS decoder */
    bus_icc_decoder bus_icc_cm3_sbus_decoder (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (hsel_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .haddr_master_stage_i        (haddr_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .htrans_master_stage_i       (htrans_from_cm3_sbus_stage_to_cm3_sbus_decoder),
        .hready_master_stage_i       (hready_cm3_sbus_i),
        .hreadyout_master_stage_o    (hreadyout_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .hresp_master_stage_o        (hresp_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .hrdata_master_stage_o       (hrdata_cm3_sbus_o),
        .master_stage_xfer_granted_o (xfer_granted_from_cm3_sbus_decoder_to_cm3_sbus_stage),
        .hsel_rcc_o                  (hsel_from_cm3_sbus_decoder_to_rcc_stage),
        .hreadyout_rcc_i             (hreadyout_from_rcc_stage_to_cm3_sbus_decoder),
        .hresp_rcc_i                 (hresp_from_rcc_stage_to_cm3_sbus_decoder),
        .hrdata_rcc_i                (hrdata_from_rcc_stage_to_cm3_sbus_decoder),
        .rcc_xfer_granted_i          (xfer_granted_from_rcc_stage_to_cm3_sbus_decoder),
        .hsel_flash_o                (hsel_from_cm3_sbus_decoder_to_flash_stage),
        .hreadyout_flash_i           (hreadyout_from_flash_stage_to_cm3_sbus_decoder),
        .hresp_flash_i               (hresp_from_flash_stage_to_cm3_sbus_decoder),
        .hrdata_flash_i              (hrdata_from_flash_stage_to_cm3_sbus_decoder),
        .flash_xfer_granted_i        (xfer_granted_from_flash_stage_to_cm3_sbus_decoder),
        .hsel_sram_o                 (hsel_from_cm3_sbus_decoder_to_sram_stage),
        .hreadyout_sram_i            (hreadyout_from_sram_stage_to_cm3_sbus_decoder),
        .hresp_sram_i                (hresp_from_sram_stage_to_cm3_sbus_decoder),
        .hrdata_sram_i               (hrdata_from_sram_stage_to_cm3_sbus_decoder),
        .sram_xfer_granted_i         (xfer_granted_from_sram_stage_to_cm3_sbus_decoder),
        .hsel_gpioa_o                (hsel_from_cm3_sbus_decoder_to_gpioa_stage),
        .hreadyout_gpioa_i           (hreadyout_from_gpioa_stage_to_cm3_sbus_decoder),
        .hresp_gpioa_i               (hresp_from_gpioa_stage_to_cm3_sbus_decoder),
        .hrdata_gpioa_i              (hrdata_from_gpioa_stage_to_cm3_sbus_decoder),
        .gpioa_xfer_granted_i        (xfer_granted_from_gpioa_stage_to_cm3_sbus_decoder),
        .hsel_gpiob_o                (hsel_from_cm3_sbus_decoder_to_gpiob_stage),
        .hreadyout_gpiob_i           (hreadyout_from_gpiob_stage_to_cm3_sbus_decoder),
        .hresp_gpiob_i               (hresp_from_gpiob_stage_to_cm3_sbus_decoder),
        .hrdata_gpiob_i              (hrdata_from_gpiob_stage_to_cm3_sbus_decoder),
        .gpiob_xfer_granted_i        (xfer_granted_from_gpiob_stage_to_cm3_sbus_decoder),
        .hsel_fmc_o                  (hsel_from_cm3_sbus_decoder_to_fmc_stage),
        .hreadyout_fmc_i             (hreadyout_from_fmc_stage_to_cm3_sbus_decoder),
        .hresp_fmc_i                 (hresp_from_fmc_stage_to_cm3_sbus_decoder),
        .hrdata_fmc_i                (hrdata_from_fmc_stage_to_cm3_sbus_decoder),
        .fmc_xfer_granted_i          (xfer_granted_from_fmc_stage_to_cm3_sbus_decoder),
        .hsel_apb1_br_o              (hsel_from_cm3_sbus_decoder_to_apb1_br_stage),
        .hreadyout_apb1_br_i         (hreadyout_from_apb1_br_stage_to_cm3_sbus_decoder),
        .hresp_apb1_br_i             (hresp_from_apb1_br_stage_to_cm3_sbus_decoder),
        .hrdata_apb1_br_i            (hrdata_from_apb1_br_stage_to_cm3_sbus_decoder),
        .apb1_br_xfer_granted_i      (xfer_granted_from_apb1_br_stage_to_cm3_sbus_decoder)
    );

    /* RCC stage */
    bus_icc_slave_stage bus_icc_rcc_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_rcc_o),
        .haddr_slave_o                   (haddr_rcc_o),
        .hwrite_slave_o                  (hwrite_rcc_o),
        .hsize_slave_o                   (hsize_rcc_o),
        .hmaster_slave_o                 (hmaster_rcc_o),
        .htrans_slave_o                  (htrans_rcc_o),
        .hburst_slave_o                  (hburst_rcc_o),
        .hprot_slave_o                   (hprot_rcc_o),
        .hmastlock_slave_o               (hmastlock_rcc_o),
        .hready_slave_o                  (hready_rcc),
        .hwdata_slave_o                  (hwdata_rcc_o),
        .hreadyout_slave_i               (hreadyout_rcc_i),
        .hresp_slave_i                   (hresp_rcc_i),
        .hrdata_slave_i                  (hrdata_rcc_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_rcc_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_rcc_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_rcc_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_rcc_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_rcc_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_rcc_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_rcc_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_rcc_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_rcc_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_rcc_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_rcc_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_rcc_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_rcc_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_rcc_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_rcc_stage_to_cm3_sbus_decoder)
    );

    /* Flash stage */
    bus_icc_slave_stage bus_icc_flash_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_flash_o),
        .haddr_slave_o                   (haddr_flash_o),
        .hwrite_slave_o                  (hwrite_flash_o),
        .hsize_slave_o                   (hsize_flash_o),
        .hmaster_slave_o                 (hmaster_flash_o),
        .htrans_slave_o                  (htrans_flash_o),
        .hburst_slave_o                  (hburst_flash_o),
        .hprot_slave_o                   (hprot_flash_o),
        .hmastlock_slave_o               (hmastlock_flash_o),
        .hready_slave_o                  (hready_flash),
        .hwdata_slave_o                  (hwdata_flash_o),
        .hreadyout_slave_i               (hreadyout_flash_i),
        .hresp_slave_i                   (hresp_flash_i),
        .hrdata_slave_i                  (hrdata_flash_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_flash_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_flash_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_flash_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_flash_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_flash_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_flash_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_flash_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_flash_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_flash_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_flash_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_flash_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_flash_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_flash_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_flash_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_flash_stage_to_cm3_sbus_decoder)
    );

    /* SRAM stage */
    bus_icc_slave_stage bus_icc_sram_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_sram_o),
        .haddr_slave_o                   (haddr_sram_o),
        .hwrite_slave_o                  (hwrite_sram_o),
        .hsize_slave_o                   (hsize_sram_o),
        .hmaster_slave_o                 (hmaster_sram_o),
        .htrans_slave_o                  (htrans_sram_o),
        .hburst_slave_o                  (hburst_sram_o),
        .hprot_slave_o                   (hprot_sram_o),
        .hmastlock_slave_o               (hmastlock_sram_o),
        .hready_slave_o                  (hready_sram),
        .hwdata_slave_o                  (hwdata_sram_o),
        .hreadyout_slave_i               (hreadyout_sram_i),
        .hresp_slave_i                   (hresp_sram_i),
        .hrdata_slave_i                  (hrdata_sram_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_sram_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_sram_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_sram_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_sram_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_sram_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_sram_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_sram_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_sram_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_sram_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_sram_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_sram_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_sram_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_sram_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_sram_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_sram_stage_to_cm3_sbus_decoder)
    );

    /* GPIOA stage */
    bus_icc_slave_stage bus_icc_gpioa_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_gpioa_o),
        .haddr_slave_o                   (haddr_gpioa_o),
        .hwrite_slave_o                  (hwrite_gpioa_o),
        .hsize_slave_o                   (hsize_gpioa_o),
        .hmaster_slave_o                 (hmaster_gpioa_o),
        .htrans_slave_o                  (htrans_gpioa_o),
        .hburst_slave_o                  (hburst_gpioa_o),
        .hprot_slave_o                   (hprot_gpioa_o),
        .hmastlock_slave_o               (hmastlock_gpioa_o),
        .hready_slave_o                  (hready_gpioa),
        .hwdata_slave_o                  (hwdata_gpioa_o),
        .hreadyout_slave_i               (hreadyout_gpioa_i),
        .hresp_slave_i                   (hresp_gpioa_i),
        .hrdata_slave_i                  (hrdata_gpioa_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_gpioa_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_gpioa_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_gpioa_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_gpioa_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_gpioa_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_gpioa_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_gpioa_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_gpioa_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_gpioa_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_gpioa_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_gpioa_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_gpioa_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_gpioa_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_gpioa_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_gpioa_stage_to_cm3_sbus_decoder)
    );

    /* GPIOB stage */
    bus_icc_slave_stage bus_icc_gpiob_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_gpiob_o),
        .haddr_slave_o                   (haddr_gpiob_o),
        .hwrite_slave_o                  (hwrite_gpiob_o),
        .hsize_slave_o                   (hsize_gpiob_o),
        .hmaster_slave_o                 (hmaster_gpiob_o),
        .htrans_slave_o                  (htrans_gpiob_o),
        .hburst_slave_o                  (hburst_gpiob_o),
        .hprot_slave_o                   (hprot_gpiob_o),
        .hmastlock_slave_o               (hmastlock_gpiob_o),
        .hready_slave_o                  (hready_gpiob),
        .hwdata_slave_o                  (hwdata_gpiob_o),
        .hreadyout_slave_i               (hreadyout_gpiob_i),
        .hresp_slave_i                   (hresp_gpiob_i),
        .hrdata_slave_i                  (hrdata_gpiob_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_gpiob_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_gpiob_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_gpiob_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_gpiob_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_gpiob_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_gpiob_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_gpiob_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_gpiob_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_gpiob_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_gpiob_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_gpiob_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_gpiob_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_gpiob_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_gpiob_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_gpiob_stage_to_cm3_sbus_decoder)
    );

    /* FMC stage */
    bus_icc_slave_stage bus_icc_fmc_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_fmc_o),
        .haddr_slave_o                   (haddr_fmc_o),
        .hwrite_slave_o                  (hwrite_fmc_o),
        .hsize_slave_o                   (hsize_fmc_o),
        .hmaster_slave_o                 (hmaster_fmc_o),
        .htrans_slave_o                  (htrans_fmc_o),
        .hburst_slave_o                  (hburst_fmc_o),
        .hprot_slave_o                   (hprot_fmc_o),
        .hmastlock_slave_o               (hmastlock_fmc_o),
        .hready_slave_o                  (hready_fmc),
        .hwdata_slave_o                  (hwdata_fmc_o),
        .hreadyout_slave_i               (hreadyout_fmc_i),
        .hresp_slave_i                   (hresp_fmc_i),
        .hrdata_slave_i                  (hrdata_fmc_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_fmc_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_fmc_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_fmc_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_fmc_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_fmc_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_fmc_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_fmc_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_fmc_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_fmc_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_fmc_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_fmc_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_fmc_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_fmc_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_fmc_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_fmc_stage_to_cm3_sbus_decoder)
    );

    /* APB1 bridge stage */
    bus_icc_slave_stage bus_icc_apb1_br_stage (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_slave_o                    (hsel_apb1_br_o),
        .haddr_slave_o                   (haddr_apb1_br_o),
        .hwrite_slave_o                  (hwrite_apb1_br_o),
        .hsize_slave_o                   (hsize_apb1_br_o),
        .hmaster_slave_o                 (hmaster_apb1_br_o),
        .htrans_slave_o                  (htrans_apb1_br_o),
        .hburst_slave_o                  (hburst_apb1_br_o),
        .hprot_slave_o                   (hprot_apb1_br_o),
        .hmastlock_slave_o               (hmastlock_apb1_br_o),
        .hready_slave_o                  (hready_apb1_br),
        .hwdata_slave_o                  (hwdata_apb1_br_o),
        .hreadyout_slave_i               (hreadyout_apb1_br_i),
        .hresp_slave_i                   (hresp_apb1_br_i),
        .hrdata_slave_i                  (hrdata_apb1_br_i),
        .hsel_cm3_ibus_decoder_i         (hsel_from_cm3_ibus_decoder_to_apb1_br_stage),
        .haddr_cm3_ibus_stage_i          (haddr_from_cm3_ibus_stage_to_all_slave_stage),
        .hwrite_cm3_ibus_stage_i         (hwrite_from_cm3_ibus_stage_to_all_slave_stage),
        .hsize_cm3_ibus_stage_i          (hsize_from_cm3_ibus_stage_to_all_slave_stage),
        .hmaster_cm3_ibus_stage_i        (hmaster_from_cm3_ibus_stage_to_all_slave_stage),
        .htrans_cm3_ibus_stage_i         (htrans_from_cm3_ibus_stage_to_all_slave_stage),
        .hburst_cm3_ibus_stage_i         (hburst_from_cm3_ibus_stage_to_all_slave_stage),
        .hprot_cm3_ibus_stage_i          (hprot_from_cm3_ibus_stage_to_all_slave_stage),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_from_cm3_ibus_stage_to_all_slave_stage),
        .hwdata_cm3_ibus_stage_i         (hwdata_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_from_cm3_ibus_stage_to_all_slave_stage),
        .hreadyout_cm3_ibus_decoder_o    (hreadyout_from_apb1_br_stage_to_cm3_ibus_decoder),
        .hresp_cm3_ibus_decoder_o        (hresp_from_apb1_br_stage_to_cm3_ibus_decoder),
        .hrdata_cm3_ibus_decoder_o       (hrdata_from_apb1_br_stage_to_cm3_ibus_decoder),
        .xfer_granted_cm3_ibus_decoder_o (xfer_granted_from_apb1_br_stage_to_cm3_ibus_decoder),
        .hsel_cm3_dbus_decoder_i         (hsel_from_cm3_dbus_decoder_to_apb1_br_stage),
        .haddr_cm3_dbus_stage_i          (haddr_from_cm3_dbus_stage_to_all_slave_stage),
        .hwrite_cm3_dbus_stage_i         (hwrite_from_cm3_dbus_stage_to_all_slave_stage),
        .hsize_cm3_dbus_stage_i          (hsize_from_cm3_dbus_stage_to_all_slave_stage),
        .hmaster_cm3_dbus_stage_i        (hmaster_from_cm3_dbus_stage_to_all_slave_stage),
        .htrans_cm3_dbus_stage_i         (htrans_from_cm3_dbus_stage_to_all_slave_stage),
        .hburst_cm3_dbus_stage_i         (hburst_from_cm3_dbus_stage_to_all_slave_stage),
        .hprot_cm3_dbus_stage_i          (hprot_from_cm3_dbus_stage_to_all_slave_stage),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_from_cm3_dbus_stage_to_all_slave_stage),
        .hwdata_cm3_dbus_stage_i         (hwdata_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_from_cm3_dbus_stage_to_all_slave_stage),
        .hreadyout_cm3_dbus_decoder_o    (hreadyout_from_apb1_br_stage_to_cm3_dbus_decoder),
        .hresp_cm3_dbus_decoder_o        (hresp_from_apb1_br_stage_to_cm3_dbus_decoder),
        .hrdata_cm3_dbus_decoder_o       (hrdata_from_apb1_br_stage_to_cm3_dbus_decoder),
        .xfer_granted_cm3_dbus_decoder_o (xfer_granted_from_apb1_br_stage_to_cm3_dbus_decoder),
        .hsel_cm3_sbus_decoder_i         (hsel_from_cm3_sbus_decoder_to_apb1_br_stage),
        .haddr_cm3_sbus_stage_i          (haddr_from_cm3_sbus_stage_to_all_slave_stage),
        .hwrite_cm3_sbus_stage_i         (hwrite_from_cm3_sbus_stage_to_all_slave_stage),
        .hsize_cm3_sbus_stage_i          (hsize_from_cm3_sbus_stage_to_all_slave_stage),
        .hmaster_cm3_sbus_stage_i        (hmaster_from_cm3_sbus_stage_to_all_slave_stage),
        .htrans_cm3_sbus_stage_i         (htrans_from_cm3_sbus_stage_to_all_slave_stage),
        .hburst_cm3_sbus_stage_i         (hburst_from_cm3_sbus_stage_to_all_slave_stage),
        .hprot_cm3_sbus_stage_i          (hprot_from_cm3_sbus_stage_to_all_slave_stage),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_from_cm3_sbus_stage_to_all_slave_stage),
        .hwdata_cm3_sbus_stage_i         (hwdata_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_from_cm3_sbus_stage_to_all_slave_stage),
        .hreadyout_cm3_sbus_decoder_o    (hreadyout_from_apb1_br_stage_to_cm3_sbus_decoder),
        .hresp_cm3_sbus_decoder_o        (hresp_from_apb1_br_stage_to_cm3_sbus_decoder),
        .hrdata_cm3_sbus_decoder_o       (hrdata_from_apb1_br_stage_to_cm3_sbus_decoder),
        .xfer_granted_cm3_sbus_decoder_o (xfer_granted_from_apb1_br_stage_to_cm3_sbus_decoder)
    );

    assign hready_rcc_o = hready_rcc;
    assign hready_flash_o = hready_flash;
    assign hready_sram_o = hready_sram;
    assign hready_gpioa_o = hready_gpioa;
    assign hready_gpiob_o = hready_gpiob;
    assign hready_fmc_o = hready_fmc;
    assign hready_apb1_br_o = hready_apb1_br;

endmodule
