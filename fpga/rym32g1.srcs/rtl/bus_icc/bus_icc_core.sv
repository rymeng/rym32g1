`timescale 1ns / 1ps

module bus_icc_core (
    /* Bus matrix clock and reset signal */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    /* Remap signal */
    input  logic [3:0]  remap_i,
    /* AHB-Lite master: Cortex-M3 IBUS */
    input  logic        hsel_master_cm3_ibus_i,
    input  logic [31:0] haddr_master_cm3_ibus_i,
    input  logic        hwrite_master_cm3_ibus_i,
    input  logic [2:0]  hsize_master_cm3_ibus_i,
    input  logic [2:0]  hburst_master_cm3_ibus_i,
    input  logic [3:0]  hprot_master_cm3_ibus_i,
    input  logic [3:0]  hmaster_master_cm3_ibus_i,
    input  logic [1:0]  htrans_master_cm3_ibus_i,
    input  logic        hmastlock_master_cm3_ibus_i,
    input  logic [31:0] hwdata_master_cm3_ibus_i,
    input  logic        hready_master_cm3_ibus_i,
    output logic        hreadyout_master_cm3_ibus_o,
    output logic [1:0]  hresp_master_cm3_ibus_o,
    output logic [31:0] hrdata_master_cm3_ibus_o,
    /* AHB-Lite master: Cortex-M3 DBUS */
    input  logic        hsel_master_cm3_dbus_i,
    input  logic [31:0] haddr_master_cm3_dbus_i,
    input  logic        hwrite_master_cm3_dbus_i,
    input  logic [2:0]  hsize_master_cm3_dbus_i,
    input  logic [2:0]  hburst_master_cm3_dbus_i,
    input  logic [3:0]  hprot_master_cm3_dbus_i,
    input  logic [3:0]  hmaster_master_cm3_dbus_i,
    input  logic [1:0]  htrans_master_cm3_dbus_i,
    input  logic        hmastlock_master_cm3_dbus_i,
    input  logic [31:0] hwdata_master_cm3_dbus_i,
    input  logic        hready_master_cm3_dbus_i,
    output logic        hreadyout_master_cm3_dbus_o,
    output logic [1:0]  hresp_master_cm3_dbus_o,
    output logic [31:0] hrdata_master_cm3_dbus_o,
    /* AHB-Lite master: Cortex-M3 SBUS */
    input  logic        hsel_master_cm3_sbus_i,
    input  logic [31:0] haddr_master_cm3_sbus_i,
    input  logic        hwrite_master_cm3_sbus_i,
    input  logic [2:0]  hsize_master_cm3_sbus_i,
    input  logic [2:0]  hburst_master_cm3_sbus_i,
    input  logic [3:0]  hprot_master_cm3_sbus_i,
    input  logic [3:0]  hmaster_master_cm3_sbus_i,
    input  logic [1:0]  htrans_master_cm3_sbus_i,
    input  logic        hmastlock_master_cm3_sbus_i,
    input  logic [31:0] hwdata_master_cm3_sbus_i,
    input  logic        hready_master_cm3_sbus_i,
    output logic        hreadyout_master_cm3_sbus_o,
    output logic [1:0]  hresp_master_cm3_sbus_o,
    output logic [31:0] hrdata_master_cm3_sbus_o,
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
    input  logic [1:0]  hresp_rcc_i,
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
    input  logic [1:0]  hresp_flash_i,
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
    input  logic [1:0]  hresp_sram_i,
    input  logic [31:0] hrdata_sram_i,
    /* GPIO A */
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
    input  logic [1:0]  hresp_gpioa_i,
    input  logic [31:0] hrdata_gpioa_i,
    /* GPIO B */
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
    input  logic [1:0]  hresp_gpiob_i,
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
    input  logic [1:0]  hresp_fmc_i,
    input  logic [31:0] hrdata_fmc_i,
    /* AHB to APB bridge */
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
    input  logic [1:0]  hresp_apb1_br_i,
    input  logic [31:0] hrdata_apb1_br_i
);
    /* Remap function: @todo */

    /* Cortex-M3 IBUS signals */
    logic        decoder_hsel_master_cm3_ibus;
    logic [31:0] haddr_master_cm3_ibus;
    logic [31:0]  decoder_haddr_master_cm3_ibus;
    logic        hwrite_master_cm3_ibus;
    logic [2:0]  hsize_master_cm3_ibus;
    logic [2:0]  hburst_master_cm3_ibus;
    logic [3:0]  hprot_master_cm3_ibus;
    logic [3:0]  hmaster_master_cm3_ibus;
    logic [1:0]  htrans_master_cm3_ibus;
    logic [1:0]   decoder_htrans_master_cm3_ibus;
    logic        hmastlock_master_cm3_ibus;
    logic        master_stage_hreadyout_master_cm3_ibus;
    logic [1:0]  master_stage_hresp_master_cm3_ibus;

    logic master_stage_xfer_granted_master_cm3_ibus;
    logic xfer_req_master_cm3_ibus;

    /* Cortex-M3 DBUS signals */
    logic        decoder_hsel_master_cm3_dbus;
    logic [31:0] haddr_master_cm3_dbus;
    logic [31:0]  decoder_haddr_master_cm3_dbus;
    logic        hwrite_master_cm3_dbus;
    logic [2:0]  hsize_master_cm3_dbus;
    logic [2:0]  hburst_master_cm3_dbus;
    logic [3:0]  hprot_master_cm3_dbus;
    logic [3:0]  hmaster_master_cm3_dbus;
    logic [1:0]  htrans_master_cm3_dbus;
    logic [1:0]   decoder_htrans_master_cm3_dbus;
    logic        hmastlock_master_cm3_dbus;
    logic        master_stage_hreadyout_master_cm3_dbus;
    logic [1:0]  master_stage_hresp_master_cm3_dbus;

    logic master_stage_xfer_granted_master_cm3_dbus;
    logic xfer_req_master_cm3_dbus;

    /* Cortex-M3 SBUS signals */
    logic        decoder_hsel_master_cm3_sbus;
    logic [31:0] haddr_master_cm3_sbus;
    logic [31:0]  decoder_haddr_master_cm3_sbus;
    logic        hwrite_master_cm3_sbus;
    logic [2:0]  hsize_master_cm3_sbus;
    logic [2:0]  hburst_master_cm3_sbus;
    logic [3:0]  hprot_master_cm3_sbus;
    logic [3:0]  hmaster_master_cm3_sbus;
    logic [1:0]  htrans_master_cm3_sbus;
    logic [1:0]   decoder_htrans_master_cm3_sbus;
    logic        hmastlock_master_cm3_sbus;
    logic        master_stage_hreadyout_master_cm3_sbus;
    logic [1:0]  master_stage_hresp_master_cm3_sbus;

    logic master_stage_xfer_granted_master_cm3_sbus;
    logic xfer_req_master_cm3_sbus;

    /* Slave port ready signals */
    logic hready_rcc;
    logic hready_flash;
    logic hready_sram;
    logic hready_gpioa;
    logic hready_gpiob;
    logic hready_fmc;
    logic hready_apb1_br;

    /* Slave response to master decoders */
    logic        rcc_hreadyout_master_cm3_ibus;
    logic [1:0]  rcc_hresp_master_cm3_ibus;
    logic [31:0] rcc_hrdata_master_cm3_ibus;
    logic        flash_hreadyout_master_cm3_ibus;
    logic [1:0]  flash_hresp_master_cm3_ibus;
    logic [31:0] flash_hrdata_master_cm3_ibus;
    logic        sram_hreadyout_master_cm3_ibus;
    logic [1:0]  sram_hresp_master_cm3_ibus;
    logic [31:0] sram_hrdata_master_cm3_ibus;
    logic        gpioa_hreadyout_master_cm3_ibus;
    logic [1:0]  gpioa_hresp_master_cm3_ibus;
    logic [31:0] gpioa_hrdata_master_cm3_ibus;
    logic        gpiob_hreadyout_master_cm3_ibus;
    logic [1:0]  gpiob_hresp_master_cm3_ibus;
    logic [31:0] gpiob_hrdata_master_cm3_ibus;
    logic        fmc_hreadyout_master_cm3_ibus;
    logic [1:0]  fmc_hresp_master_cm3_ibus;
    logic [31:0] fmc_hrdata_master_cm3_ibus;
    logic        apb1_br_hreadyout_master_cm3_ibus;
    logic [1:0]  apb1_br_hresp_master_cm3_ibus;
    logic [31:0] apb1_br_hrdata_master_cm3_ibus;

    logic        rcc_hreadyout_master_cm3_dbus;
    logic [1:0]  rcc_hresp_master_cm3_dbus;
    logic [31:0] rcc_hrdata_master_cm3_dbus;
    logic        flash_hreadyout_master_cm3_dbus;
    logic [1:0]  flash_hresp_master_cm3_dbus;
    logic [31:0] flash_hrdata_master_cm3_dbus;
    logic        sram_hreadyout_master_cm3_dbus;
    logic [1:0]  sram_hresp_master_cm3_dbus;
    logic [31:0] sram_hrdata_master_cm3_dbus;
    logic        gpioa_hreadyout_master_cm3_dbus;
    logic [1:0]  gpioa_hresp_master_cm3_dbus;
    logic [31:0] gpioa_hrdata_master_cm3_dbus;
    logic        gpiob_hreadyout_master_cm3_dbus;
    logic [1:0]  gpiob_hresp_master_cm3_dbus;
    logic [31:0] gpiob_hrdata_master_cm3_dbus;
    logic        fmc_hreadyout_master_cm3_dbus;
    logic [1:0]  fmc_hresp_master_cm3_dbus;
    logic [31:0] fmc_hrdata_master_cm3_dbus;
    logic        apb1_br_hreadyout_master_cm3_dbus;
    logic [1:0]  apb1_br_hresp_master_cm3_dbus;
    logic [31:0] apb1_br_hrdata_master_cm3_dbus;

    logic        rcc_hreadyout_master_cm3_sbus;
    logic [1:0]  rcc_hresp_master_cm3_sbus;
    logic [31:0] rcc_hrdata_master_cm3_sbus;
    logic        flash_hreadyout_master_cm3_sbus;
    logic [1:0]  flash_hresp_master_cm3_sbus;
    logic [31:0] flash_hrdata_master_cm3_sbus;
    logic        sram_hreadyout_master_cm3_sbus;
    logic [1:0]  sram_hresp_master_cm3_sbus;
    logic [31:0] sram_hrdata_master_cm3_sbus;
    logic        gpioa_hreadyout_master_cm3_sbus;
    logic [1:0]  gpioa_hresp_master_cm3_sbus;
    logic [31:0] gpioa_hrdata_master_cm3_sbus;
    logic        gpiob_hreadyout_master_cm3_sbus;
    logic [1:0]  gpiob_hresp_master_cm3_sbus;
    logic [31:0] gpiob_hrdata_master_cm3_sbus;
    logic        fmc_hreadyout_master_cm3_sbus;
    logic [1:0]  fmc_hresp_master_cm3_sbus;
    logic [31:0] fmc_hrdata_master_cm3_sbus;
    logic        apb1_br_hreadyout_master_cm3_sbus;
    logic [1:0]  apb1_br_hresp_master_cm3_sbus;
    logic [31:0] apb1_br_hrdata_master_cm3_sbus;

    /* Cortex-M3 IBUS to slave signals */
    logic rcc_hsel_master_cm3_ibus;
    logic flash_hsel_master_cm3_ibus;
    logic sram_hsel_master_cm3_ibus;
    logic gpioa_hsel_master_cm3_ibus;
    logic gpiob_hsel_master_cm3_ibus;
    logic fmc_hsel_master_cm3_ibus;
    logic apb1_br_hsel_master_cm3_ibus;

    logic rcc_xfer_granted_master_cm3_ibus;
    logic flash_xfer_granted_master_cm3_ibus;
    logic sram_xfer_granted_master_cm3_ibus;
    logic gpioa_xfer_granted_master_cm3_ibus;
    logic gpiob_xfer_granted_master_cm3_ibus;
    logic fmc_xfer_granted_master_cm3_ibus;
    logic apb1_br_xfer_granted_master_cm3_ibus;

    /* Cortex-M3 DBUS to slave signals */
    logic rcc_hsel_master_cm3_dbus;
    logic flash_hsel_master_cm3_dbus;
    logic sram_hsel_master_cm3_dbus;
    logic gpioa_hsel_master_cm3_dbus;
    logic gpiob_hsel_master_cm3_dbus;
    logic fmc_hsel_master_cm3_dbus;
    logic apb1_br_hsel_master_cm3_dbus;

    logic rcc_xfer_granted_master_cm3_dbus;
    logic flash_xfer_granted_master_cm3_dbus;
    logic sram_xfer_granted_master_cm3_dbus;
    logic gpioa_xfer_granted_master_cm3_dbus;
    logic gpiob_xfer_granted_master_cm3_dbus;
    logic fmc_xfer_granted_master_cm3_dbus;
    logic apb1_br_xfer_granted_master_cm3_dbus;

    /* Cortex-M3 SBUS to slave signals */
    logic rcc_hsel_master_cm3_sbus;
    logic flash_hsel_master_cm3_sbus;
    logic sram_hsel_master_cm3_sbus;
    logic gpioa_hsel_master_cm3_sbus;
    logic gpiob_hsel_master_cm3_sbus;
    logic fmc_hsel_master_cm3_sbus;
    logic apb1_br_hsel_master_cm3_sbus;

    logic rcc_xfer_granted_master_cm3_sbus;
    logic flash_xfer_granted_master_cm3_sbus;
    logic sram_xfer_granted_master_cm3_sbus;
    logic gpioa_xfer_granted_master_cm3_sbus;
    logic gpiob_xfer_granted_master_cm3_sbus;
    logic fmc_xfer_granted_master_cm3_sbus;
    logic apb1_br_xfer_granted_master_cm3_sbus;

    /* Master stage of Cortex-M3 IBUS */
    bus_icc_master_stage master_stage_cm3_ibus_inst (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_master_cm3_ibus_i),
        .haddr_master_i          (haddr_master_cm3_ibus_i),
        .hwrite_master_i         (hwrite_master_cm3_ibus_i),
        .hsize_master_i          (hsize_master_cm3_ibus_i),
        .hburst_master_i         (hburst_master_cm3_ibus_i),
        .hprot_master_i          (hprot_master_cm3_ibus_i),
        .hmaster_master_i        (hmaster_master_cm3_ibus_i),
        .htrans_master_i         (htrans_master_cm3_ibus_i),
        .hmastlock_master_i      (hmastlock_master_cm3_ibus_i),
        .hready_master_i         (hready_master_cm3_ibus_i),
        .hreadyout_master_o      (hreadyout_master_cm3_ibus_o),
        .hresp_master_o          (hresp_master_cm3_ibus_o),
        .hsel_decoder_o          (decoder_hsel_master_cm3_ibus),
        .haddr_decoder_o         (decoder_haddr_master_cm3_ibus),
        .htrans_decoder_o        (decoder_htrans_master_cm3_ibus),
        .hreadyout_decoder_i     (master_stage_hreadyout_master_cm3_ibus),
        .hresp_decoder_i         (master_stage_hresp_master_cm3_ibus),
        .xfer_granted_decoder_i  (master_stage_xfer_granted_master_cm3_ibus),
        .haddr_slave_stage_o     (haddr_master_cm3_ibus),
        .hwrite_slave_stage_o    (hwrite_master_cm3_ibus),
        .hsize_slave_stage_o     (hsize_master_cm3_ibus),
        .hmaster_slave_stage_o   (hmaster_master_cm3_ibus),
        .htrans_slave_stage_o    (htrans_master_cm3_ibus),
        .hburst_slave_stage_o    (hburst_master_cm3_ibus),
        .hprot_slave_stage_o     (hprot_master_cm3_ibus),
        .hmastlock_slave_stage_o (hmastlock_master_cm3_ibus),
        .xfer_req_slave_stage_o  (xfer_req_master_cm3_ibus)
    );

    /* Master stage of Cortex-M3 DBUS */
    bus_icc_master_stage master_stage_cm3_dbus_inst (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_master_cm3_dbus_i),
        .haddr_master_i          (haddr_master_cm3_dbus_i),
        .hwrite_master_i         (hwrite_master_cm3_dbus_i),
        .hsize_master_i          (hsize_master_cm3_dbus_i),
        .hburst_master_i         (hburst_master_cm3_dbus_i),
        .hprot_master_i          (hprot_master_cm3_dbus_i),
        .hmaster_master_i        (hmaster_master_cm3_dbus_i),
        .htrans_master_i         (htrans_master_cm3_dbus_i),
        .hmastlock_master_i      (hmastlock_master_cm3_dbus_i),
        .hready_master_i         (hready_master_cm3_dbus_i),
        .hreadyout_master_o      (hreadyout_master_cm3_dbus_o),
        .hresp_master_o          (hresp_master_cm3_dbus_o),
        .hsel_decoder_o          (decoder_hsel_master_cm3_dbus),
        .haddr_decoder_o         (decoder_haddr_master_cm3_dbus),
        .htrans_decoder_o        (decoder_htrans_master_cm3_dbus),
        .hreadyout_decoder_i     (master_stage_hreadyout_master_cm3_dbus),
        .hresp_decoder_i         (master_stage_hresp_master_cm3_dbus),
        .xfer_granted_decoder_i  (master_stage_xfer_granted_master_cm3_dbus),
        .haddr_slave_stage_o     (haddr_master_cm3_dbus),
        .hwrite_slave_stage_o    (hwrite_master_cm3_dbus),
        .hsize_slave_stage_o     (hsize_master_cm3_dbus),
        .hmaster_slave_stage_o   (hmaster_master_cm3_dbus),
        .htrans_slave_stage_o    (htrans_master_cm3_dbus),
        .hburst_slave_stage_o    (hburst_master_cm3_dbus),
        .hprot_slave_stage_o     (hprot_master_cm3_dbus),
        .hmastlock_slave_stage_o (hmastlock_master_cm3_dbus),
        .xfer_req_slave_stage_o  (xfer_req_master_cm3_dbus)
    );

    /* Master stage of Cortex-M3 SBUS */
    bus_icc_master_stage master_stage_cm3_sbus_inst (
        .hclk_i                  (hclk_i),
        .hreset_n_i              (hreset_n_i),
        .hsel_master_i           (hsel_master_cm3_sbus_i),
        .haddr_master_i          (haddr_master_cm3_sbus_i),
        .hwrite_master_i         (hwrite_master_cm3_sbus_i),
        .hsize_master_i          (hsize_master_cm3_sbus_i),
        .hburst_master_i         (hburst_master_cm3_sbus_i),
        .hprot_master_i          (hprot_master_cm3_sbus_i),
        .hmaster_master_i        (hmaster_master_cm3_sbus_i),
        .htrans_master_i         (htrans_master_cm3_sbus_i),
        .hmastlock_master_i      (hmastlock_master_cm3_sbus_i),
        .hready_master_i         (hready_master_cm3_sbus_i),
        .hreadyout_master_o      (hreadyout_master_cm3_sbus_o),
        .hresp_master_o          (hresp_master_cm3_sbus_o),
        .hsel_decoder_o          (decoder_hsel_master_cm3_sbus),
        .haddr_decoder_o         (decoder_haddr_master_cm3_sbus),
        .htrans_decoder_o        (decoder_htrans_master_cm3_sbus),
        .hreadyout_decoder_i     (master_stage_hreadyout_master_cm3_sbus),
        .hresp_decoder_i         (master_stage_hresp_master_cm3_sbus),
        .xfer_granted_decoder_i  (master_stage_xfer_granted_master_cm3_sbus),
        .haddr_slave_stage_o     (haddr_master_cm3_sbus),
        .hwrite_slave_stage_o    (hwrite_master_cm3_sbus),
        .hsize_slave_stage_o     (hsize_master_cm3_sbus),
        .hmaster_slave_stage_o   (hmaster_master_cm3_sbus),
        .htrans_slave_stage_o    (htrans_master_cm3_sbus),
        .hburst_slave_stage_o    (hburst_master_cm3_sbus),
        .hprot_slave_stage_o     (hprot_master_cm3_sbus),
        .hmastlock_slave_stage_o (hmastlock_master_cm3_sbus),
        .xfer_req_slave_stage_o  (xfer_req_master_cm3_sbus)
    );

    /* Address decoder of Cortex-M3 IBUS */
    bus_icc_decoder decoder_cm3_ibus_inst (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (decoder_hsel_master_cm3_ibus),
        .haddr_master_stage_i        (decoder_haddr_master_cm3_ibus),
        .htrans_master_stage_i       (decoder_htrans_master_cm3_ibus),
        .hready_master_stage_i       (hready_master_cm3_ibus_i),
        .master_stage_xfer_granted_o (master_stage_xfer_granted_master_cm3_ibus),
        .hreadyout_master_stage_o    (master_stage_hreadyout_master_cm3_ibus),
        .hresp_master_stage_o        (master_stage_hresp_master_cm3_ibus),
        .hrdata_master_stage_o       (hrdata_master_cm3_ibus_o),
        .hsel_rcc_o                  (rcc_hsel_master_cm3_ibus),
        .hreadyout_rcc_i             (rcc_hreadyout_master_cm3_ibus),
        .hresp_rcc_i                 (rcc_hresp_master_cm3_ibus),
        .hrdata_rcc_i                (rcc_hrdata_master_cm3_ibus),
        .rcc_xfer_granted_i          (rcc_xfer_granted_master_cm3_ibus),
        .hsel_flash_o                (flash_hsel_master_cm3_ibus),
        .hreadyout_flash_i           (flash_hreadyout_master_cm3_ibus),
        .hresp_flash_i               (flash_hresp_master_cm3_ibus),
        .hrdata_flash_i              (flash_hrdata_master_cm3_ibus),
        .flash_xfer_granted_i        (flash_xfer_granted_master_cm3_ibus),
        .hsel_sram_o                 (sram_hsel_master_cm3_ibus),
        .hreadyout_sram_i            (sram_hreadyout_master_cm3_ibus),
        .hresp_sram_i                (sram_hresp_master_cm3_ibus),
        .hrdata_sram_i               (sram_hrdata_master_cm3_ibus),
        .sram_xfer_granted_i         (sram_xfer_granted_master_cm3_ibus),
        .hsel_gpioa_o                (gpioa_hsel_master_cm3_ibus),
        .hreadyout_gpioa_i           (gpioa_hreadyout_master_cm3_ibus),
        .hresp_gpioa_i               (gpioa_hresp_master_cm3_ibus),
        .hrdata_gpioa_i              (gpioa_hrdata_master_cm3_ibus),
        .gpioa_xfer_granted_i        (gpioa_xfer_granted_master_cm3_ibus),
        .hsel_gpiob_o                (gpiob_hsel_master_cm3_ibus),
        .hreadyout_gpiob_i           (gpiob_hreadyout_master_cm3_ibus),
        .hresp_gpiob_i               (gpiob_hresp_master_cm3_ibus),
        .hrdata_gpiob_i              (gpiob_hrdata_master_cm3_ibus),
        .gpiob_xfer_granted_i        (gpiob_xfer_granted_master_cm3_ibus),
        .hsel_fmc_o                  (fmc_hsel_master_cm3_ibus),
        .hreadyout_fmc_i             (fmc_hreadyout_master_cm3_ibus),
        .hresp_fmc_i                 (fmc_hresp_master_cm3_ibus),
        .hrdata_fmc_i                (fmc_hrdata_master_cm3_ibus),
        .fmc_xfer_granted_i          (fmc_xfer_granted_master_cm3_ibus),
        .hsel_apb1_br_o              (apb1_br_hsel_master_cm3_ibus),
        .hreadyout_apb1_br_i         (apb1_br_hreadyout_master_cm3_ibus),
        .hresp_apb1_br_i             (apb1_br_hresp_master_cm3_ibus),
        .hrdata_apb1_br_i            (apb1_br_hrdata_master_cm3_ibus),
        .apb1_br_xfer_granted_i      (apb1_br_xfer_granted_master_cm3_ibus)
    );

    /* Address decoder of Cortex-M3 DBUS */
    bus_icc_decoder decoder_cm3_dbus_inst (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (decoder_hsel_master_cm3_dbus),
        .haddr_master_stage_i        (decoder_haddr_master_cm3_dbus),
        .htrans_master_stage_i       (decoder_htrans_master_cm3_dbus),
        .hready_master_stage_i       (hready_master_cm3_dbus_i),
        .master_stage_xfer_granted_o (master_stage_xfer_granted_master_cm3_dbus),
        .hreadyout_master_stage_o    (master_stage_hreadyout_master_cm3_dbus),
        .hresp_master_stage_o        (master_stage_hresp_master_cm3_dbus),
        .hrdata_master_stage_o       (hrdata_master_cm3_dbus_o),
        .hsel_rcc_o                  (rcc_hsel_master_cm3_dbus),
        .hreadyout_rcc_i             (rcc_hreadyout_master_cm3_dbus),
        .hresp_rcc_i                 (rcc_hresp_master_cm3_dbus),
        .hrdata_rcc_i                (rcc_hrdata_master_cm3_dbus),
        .rcc_xfer_granted_i          (rcc_xfer_granted_master_cm3_dbus),
        .hsel_flash_o                (flash_hsel_master_cm3_dbus),
        .hreadyout_flash_i           (flash_hreadyout_master_cm3_dbus),
        .hresp_flash_i               (flash_hresp_master_cm3_dbus),
        .hrdata_flash_i              (flash_hrdata_master_cm3_dbus),
        .flash_xfer_granted_i        (flash_xfer_granted_master_cm3_dbus),
        .hsel_sram_o                 (sram_hsel_master_cm3_dbus),
        .hreadyout_sram_i            (sram_hreadyout_master_cm3_dbus),
        .hresp_sram_i                (sram_hresp_master_cm3_dbus),
        .hrdata_sram_i               (sram_hrdata_master_cm3_dbus),
        .sram_xfer_granted_i         (sram_xfer_granted_master_cm3_dbus),
        .hsel_gpioa_o                (gpioa_hsel_master_cm3_dbus),
        .hreadyout_gpioa_i           (gpioa_hreadyout_master_cm3_dbus),
        .hresp_gpioa_i               (gpioa_hresp_master_cm3_dbus),
        .hrdata_gpioa_i              (gpioa_hrdata_master_cm3_dbus),
        .gpioa_xfer_granted_i        (gpioa_xfer_granted_master_cm3_dbus),
        .hsel_gpiob_o                (gpiob_hsel_master_cm3_dbus),
        .hreadyout_gpiob_i           (gpiob_hreadyout_master_cm3_dbus),
        .hresp_gpiob_i               (gpiob_hresp_master_cm3_dbus),
        .hrdata_gpiob_i              (gpiob_hrdata_master_cm3_dbus),
        .gpiob_xfer_granted_i        (gpiob_xfer_granted_master_cm3_dbus),
        .hsel_fmc_o                  (fmc_hsel_master_cm3_dbus),
        .hreadyout_fmc_i             (fmc_hreadyout_master_cm3_dbus),
        .hresp_fmc_i                 (fmc_hresp_master_cm3_dbus),
        .hrdata_fmc_i                (fmc_hrdata_master_cm3_dbus),
        .fmc_xfer_granted_i          (fmc_xfer_granted_master_cm3_dbus),
        .hsel_apb1_br_o              (apb1_br_hsel_master_cm3_dbus),
        .hreadyout_apb1_br_i         (apb1_br_hreadyout_master_cm3_dbus),
        .hresp_apb1_br_i             (apb1_br_hresp_master_cm3_dbus),
        .hrdata_apb1_br_i            (apb1_br_hrdata_master_cm3_dbus),
        .apb1_br_xfer_granted_i      (apb1_br_xfer_granted_master_cm3_dbus)
    );

    /* Address decoder of Cortex-M3 SBUS */
    bus_icc_decoder decoder_cm3_sbus_inst (
        .hclk_i                      (hclk_i),
        .hreset_n_i                  (hreset_n_i),
        .hsel_master_stage_i         (decoder_hsel_master_cm3_sbus),
        .haddr_master_stage_i        (decoder_haddr_master_cm3_sbus),
        .htrans_master_stage_i       (decoder_htrans_master_cm3_sbus),
        .hready_master_stage_i       (hready_master_cm3_sbus_i),
        .master_stage_xfer_granted_o (master_stage_xfer_granted_master_cm3_sbus),
        .hreadyout_master_stage_o    (master_stage_hreadyout_master_cm3_sbus),
        .hresp_master_stage_o        (master_stage_hresp_master_cm3_sbus),
        .hrdata_master_stage_o       (hrdata_master_cm3_sbus_o),
        .hsel_rcc_o                  (rcc_hsel_master_cm3_sbus),
        .hreadyout_rcc_i             (rcc_hreadyout_master_cm3_sbus),
        .hresp_rcc_i                 (rcc_hresp_master_cm3_sbus),
        .hrdata_rcc_i                (rcc_hrdata_master_cm3_sbus),
        .rcc_xfer_granted_i          (rcc_xfer_granted_master_cm3_sbus),
        .hsel_flash_o                (flash_hsel_master_cm3_sbus),
        .hreadyout_flash_i           (flash_hreadyout_master_cm3_sbus),
        .hresp_flash_i               (flash_hresp_master_cm3_sbus),
        .hrdata_flash_i              (flash_hrdata_master_cm3_sbus),
        .flash_xfer_granted_i        (flash_xfer_granted_master_cm3_sbus),
        .hsel_sram_o                 (sram_hsel_master_cm3_sbus),
        .hreadyout_sram_i            (sram_hreadyout_master_cm3_sbus),
        .hresp_sram_i                (sram_hresp_master_cm3_sbus),
        .hrdata_sram_i               (sram_hrdata_master_cm3_sbus),
        .sram_xfer_granted_i         (sram_xfer_granted_master_cm3_sbus),
        .hsel_gpioa_o                (gpioa_hsel_master_cm3_sbus),
        .hreadyout_gpioa_i           (gpioa_hreadyout_master_cm3_sbus),
        .hresp_gpioa_i               (gpioa_hresp_master_cm3_sbus),
        .hrdata_gpioa_i              (gpioa_hrdata_master_cm3_sbus),
        .gpioa_xfer_granted_i        (gpioa_xfer_granted_master_cm3_sbus),
        .hsel_gpiob_o                (gpiob_hsel_master_cm3_sbus),
        .hreadyout_gpiob_i           (gpiob_hreadyout_master_cm3_sbus),
        .hresp_gpiob_i               (gpiob_hresp_master_cm3_sbus),
        .hrdata_gpiob_i              (gpiob_hrdata_master_cm3_sbus),
        .gpiob_xfer_granted_i        (gpiob_xfer_granted_master_cm3_sbus),
        .hsel_fmc_o                  (fmc_hsel_master_cm3_sbus),
        .hreadyout_fmc_i             (fmc_hreadyout_master_cm3_sbus),
        .hresp_fmc_i                 (fmc_hresp_master_cm3_sbus),
        .hrdata_fmc_i                (fmc_hrdata_master_cm3_sbus),
        .fmc_xfer_granted_i          (fmc_xfer_granted_master_cm3_sbus),
        .hsel_apb1_br_o              (apb1_br_hsel_master_cm3_sbus),
        .hreadyout_apb1_br_i         (apb1_br_hreadyout_master_cm3_sbus),
        .hresp_apb1_br_i             (apb1_br_hresp_master_cm3_sbus),
        .hrdata_apb1_br_i            (apb1_br_hrdata_master_cm3_sbus),
        .apb1_br_xfer_granted_i      (apb1_br_xfer_granted_master_cm3_sbus)
    );

    /* Slave stage of RCC */
    bus_icc_slave_stage slave_stage_rcc_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (rcc_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (rcc_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (rcc_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (rcc_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (rcc_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (rcc_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (rcc_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (rcc_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (rcc_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (rcc_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (rcc_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (rcc_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (rcc_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (rcc_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (rcc_hrdata_master_cm3_sbus)
    );

    /* Slave stage of Flash */
    bus_icc_slave_stage slave_stage_flash_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (flash_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (flash_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (flash_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (flash_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (flash_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (flash_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (flash_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (flash_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (flash_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (flash_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (flash_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (flash_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (flash_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (flash_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (flash_hrdata_master_cm3_sbus)
    );

    /* Slave stage of SRAM */
    bus_icc_slave_stage slave_stage_sram_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (sram_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (sram_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (sram_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (sram_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (sram_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (sram_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (sram_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (sram_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (sram_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (sram_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (sram_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (sram_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (sram_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (sram_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (sram_hrdata_master_cm3_sbus)
    );

    /* Slave stage of GPIO A */
    bus_icc_slave_stage slave_stage_gpioa_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (gpioa_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (gpioa_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (gpioa_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (gpioa_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (gpioa_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (gpioa_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (gpioa_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (gpioa_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (gpioa_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (gpioa_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (gpioa_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (gpioa_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (gpioa_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (gpioa_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (gpioa_hrdata_master_cm3_sbus)
    );

    /* Slave stage of GPIO B */
    bus_icc_slave_stage slave_stage_gpiob_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (gpiob_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (gpiob_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (gpiob_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (gpiob_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (gpiob_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (gpiob_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (gpiob_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (gpiob_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (gpiob_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (gpiob_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (gpiob_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (gpiob_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (gpiob_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (gpiob_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (gpiob_hrdata_master_cm3_sbus)
    );

    /* Slave stage of FMC */
    bus_icc_slave_stage slave_stage_fmc_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (fmc_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (fmc_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (fmc_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (fmc_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (fmc_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (fmc_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (fmc_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (fmc_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (fmc_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (fmc_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (fmc_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (fmc_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (fmc_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (fmc_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (fmc_hrdata_master_cm3_sbus)
    );

    /* Slave stage of AHB to APB bridge */
    bus_icc_slave_stage slave_stage_apb1_br_inst (
        .hclk_i                          (hclk_i),
        .hreset_n_i                      (hreset_n_i),
        .hsel_cm3_ibus_decoder_i         (apb1_br_hsel_master_cm3_ibus),
        .haddr_cm3_ibus_stage_i          (haddr_master_cm3_ibus),
        .hwrite_cm3_ibus_stage_i         (hwrite_master_cm3_ibus),
        .hsize_cm3_ibus_stage_i          (hsize_master_cm3_ibus),
        .hmaster_cm3_ibus_stage_i        (hmaster_master_cm3_ibus),
        .htrans_cm3_ibus_stage_i         (htrans_master_cm3_ibus),
        .hburst_cm3_ibus_stage_i         (hburst_master_cm3_ibus),
        .hprot_cm3_ibus_stage_i          (hprot_master_cm3_ibus),
        .hmastlock_cm3_ibus_stage_i      (hmastlock_master_cm3_ibus),
        .hwdata_cm3_ibus_stage_i         (hwdata_master_cm3_ibus_i),
        .xfer_req_cm3_ibus_stage_i       (xfer_req_master_cm3_ibus),
        .xfer_granted_cm3_ibus_decoder_o (apb1_br_xfer_granted_master_cm3_ibus),
        .hsel_cm3_dbus_decoder_i         (apb1_br_hsel_master_cm3_dbus),
        .haddr_cm3_dbus_stage_i          (haddr_master_cm3_dbus),
        .hwrite_cm3_dbus_stage_i         (hwrite_master_cm3_dbus),
        .hsize_cm3_dbus_stage_i          (hsize_master_cm3_dbus),
        .hmaster_cm3_dbus_stage_i        (hmaster_master_cm3_dbus),
        .htrans_cm3_dbus_stage_i         (htrans_master_cm3_dbus),
        .hburst_cm3_dbus_stage_i         (hburst_master_cm3_dbus),
        .hprot_cm3_dbus_stage_i          (hprot_master_cm3_dbus),
        .hmastlock_cm3_dbus_stage_i      (hmastlock_master_cm3_dbus),
        .hwdata_cm3_dbus_stage_i         (hwdata_master_cm3_dbus_i),
        .xfer_req_cm3_dbus_stage_i       (xfer_req_master_cm3_dbus),
        .xfer_granted_cm3_dbus_decoder_o (apb1_br_xfer_granted_master_cm3_dbus),
        .hsel_cm3_sbus_decoder_i         (apb1_br_hsel_master_cm3_sbus),
        .haddr_cm3_sbus_stage_i          (haddr_master_cm3_sbus),
        .hwrite_cm3_sbus_stage_i         (hwrite_master_cm3_sbus),
        .hsize_cm3_sbus_stage_i          (hsize_master_cm3_sbus),
        .hmaster_cm3_sbus_stage_i        (hmaster_master_cm3_sbus),
        .htrans_cm3_sbus_stage_i         (htrans_master_cm3_sbus),
        .hburst_cm3_sbus_stage_i         (hburst_master_cm3_sbus),
        .hprot_cm3_sbus_stage_i          (hprot_master_cm3_sbus),
        .hmastlock_cm3_sbus_stage_i      (hmastlock_master_cm3_sbus),
        .hwdata_cm3_sbus_stage_i         (hwdata_master_cm3_sbus_i),
        .xfer_req_cm3_sbus_stage_i       (xfer_req_master_cm3_sbus),
        .xfer_granted_cm3_sbus_decoder_o (apb1_br_xfer_granted_master_cm3_sbus),
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
        .hreadyout_cm3_ibus_decoder_o    (apb1_br_hreadyout_master_cm3_ibus),
        .hresp_cm3_ibus_decoder_o        (apb1_br_hresp_master_cm3_ibus),
        .hrdata_cm3_ibus_decoder_o       (apb1_br_hrdata_master_cm3_ibus),
        .hreadyout_cm3_dbus_decoder_o    (apb1_br_hreadyout_master_cm3_dbus),
        .hresp_cm3_dbus_decoder_o        (apb1_br_hresp_master_cm3_dbus),
        .hrdata_cm3_dbus_decoder_o       (apb1_br_hrdata_master_cm3_dbus),
        .hreadyout_cm3_sbus_decoder_o    (apb1_br_hreadyout_master_cm3_sbus),
        .hresp_cm3_sbus_decoder_o        (apb1_br_hresp_master_cm3_sbus),
        .hrdata_cm3_sbus_decoder_o       (apb1_br_hrdata_master_cm3_sbus)
    );

    assign hready_rcc_o = hready_rcc;
    assign hready_flash_o = hready_flash;
    assign hready_sram_o = hready_sram;
    assign hready_gpioa_o = hready_gpioa;
    assign hready_gpiob_o = hready_gpiob;
    assign hready_fmc_o = hready_fmc;
    assign hready_apb1_br_o = hready_apb1_br;

endmodule
