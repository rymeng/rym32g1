`timescale 1ns / 1ps

module top (
    input  logic       refclk_i,
    input  logic       porst_n_i,
    input  logic       xrst_n_i,
    input  logic       swclk_i,
    inout logic        swdio_io,
    input  logic       tdi_i,
    output logic       tdo_o,
    output logic       ntdoen_o,
    input  logic       ntrst_n_i,
    output logic       swv_o,
    output logic       trace_clk_o,
    output logic [3:0] trace_data_o,
    inout logic [15:0] port_a_io,
    inout logic [15:0] port_b_io
);
    /* The MMCM generates HSI; the RCC picks the HCLK source out of it, which
       for now is a direct connection to HSI. FCLK clocks the NVIC, SysTick and
       debug and always runs. HCLK clocks the AHB bus and the processor; it
       stays a separate net so that it can be gated off later, for example
       while no debugger is attached. */
    logic hsi;
    logic fclk;
    logic hclk;
    logic hsi_ready;
    logic refrst_n;
    logic porst_n;
    logic sysrst_n;
    logic core_sysrst_req;
    logic gpioa_rst_req;
    logic gpiob_rst_req;
    logic uart1_rst_req;
    logic uart2_rst_req;
    logic tuart1_rst_req;
    logic wwdg_rst_req;
    logic wwdg_ewi_interrupt;
    logic uart1_rx_irq;
    logic uart1_tx_irq;
    logic uart2_rx_irq;
    logic uart2_tx_irq;
    logic hrst_n_flash;
    logic hrst_n_sram;
    logic hrst_n_gpioa;
    logic hrst_n_gpiob;
    logic hrst_n_fmc;
    logic hrst_n_apb1_br;
    logic uart1_rst_n;
    logic uart2_rst_n;
    logic tuart1_rst_n;

    clk_gen_top hsi_gen (
        .refclk_i        (refclk_i),
        .rst_n_i         (refrst_n),
        .clk_out_o       (hsi),
        .clk_out_ready_o (hsi_ready)
    );

    assign fclk = hsi;
    assign hclk = hsi;

    /* Keep rst bypass disabled during normal operation */
    logic rst_bypass_enabled;
    assign rst_bypass_enabled = 1'b0;

    /* Debug port sub-system */
    logic swdi;
    logic swdo;
    logic swdo_enabled;
    logic ntrst;
    logic tdi;
    logic debug_restart;
    logic external_debug_req;

    assign swdi = swdio_io;
    assign swdio_io = (swdo_enabled) ? swdo : 1'bz;
    assign ntrst = ntrst_n_i;
    assign tdi = tdi_i;
    assign debug_restart = 1'b0;
    assign external_debug_req = 1'b0;

    /* PMU sub-system, always-on domain: REFCLK and the always-on POR only,
       never HCLK, SYSRESETn or the HSI-qualified POR */
    logic sleep_hold_req_n;
    logic sleep_hold_ack_n;
    logic wkup_it_ctrl_en_req;
    logic wkup_it_ctrl_en_ack;
    logic wkup;
    logic core_debug_power_up_req;
    logic core_debug_power_up_ack;

    pmu_top pmu (
        .always_on_clk_i       (refclk_i),
        .always_on_rst_n_i     (refrst_n),
        .debug_power_up_req_i  (core_debug_power_up_req),
        .sleep_hold_ack_n_i    (sleep_hold_ack_n),
        .wkup_it_ctrl_en_ack_i (wkup_it_ctrl_en_ack),
        .wkup_i                (wkup),
        .debug_power_up_ack_o  (core_debug_power_up_ack),
        .sleep_hold_req_n_o    (sleep_hold_req_n),
        .wkup_it_ctrl_en_req_o (wkup_it_ctrl_en_req)
    );

    /* Interrupt sub-system */
    logic [239:0] interrupt_req;
    logic         non_maskable_interrupt;
    logic         rx_event;

    assign rx_event = 1'b0;
    assign non_maskable_interrupt = 1'b0;

    it_icc_top it_icc (
        .wwdg_it_req_i     (wwdg_ewi_interrupt),
        .uart1_rx_it_req_i (uart1_rx_irq),
        .uart1_tx_it_req_i (uart1_tx_irq),
        .uart2_rx_it_req_i (uart2_rx_irq),
        .uart2_tx_it_req_i (uart2_tx_irq),
        .nvic_it_req_o     (interrupt_req)
    );

    /* SysTick sub-system: no reference clock, exact 10 ms reload at 10 MHz HCLK */
    logic [25:0] systick_calibration;

    assign systick_calibration = {1'b1, 1'b0, 24'd100000};

    /* Scan mode sub-system */
    logic scan_enabled;

    assign scan_enabled = 1'b0;

    /* AHB-Lite instruction master signal */
    logic [31:0] haddr_master_cm3_ibus;
    logic        hwrite_master_cm3_ibus;
    logic [2:0]  hsize_master_cm3_ibus;
    logic [2:0]  hburst_master_cm3_ibus;
    logic [3:0]  hprot_master_cm3_ibus;
    logic [3:0]  hmaster_master_cm3_ibus;
    logic [1:0]  htrans_master_cm3_ibus;
    logic        hmastlock_master_cm3_ibus;
    logic [31:0] hwdata_master_cm3_ibus;
    logic        hready_master_cm3_ibus;
    logic [1:0]  hresp_master_cm3_ibus;
    logic [31:0] hrdata_master_cm3_ibus;

    /* AHB-Lite data master signal */
    logic [31:0] haddr_master_cm3_dbus;
    logic [31:0] hwdata_master_cm3_dbus;
    logic        hwrite_master_cm3_dbus;
    logic [1:0]  htrans_master_cm3_dbus;
    logic [2:0]  hsize_master_cm3_dbus;
    logic [2:0]  hburst_master_cm3_dbus;
    logic [3:0]  hprot_master_cm3_dbus;
    logic [1:0]  hmaster_master_cm3_dbus;
    logic        hmastlock_master_cm3_dbus;
    logic        hready_master_cm3_dbus;
    logic [1:0]  hresp_master_cm3_dbus;
    logic [31:0] hrdata_master_cm3_dbus;
    logic        exresp_master_cm3_dbus;

    /* AHB-Lite system master signal */
    logic [31:0] haddr_master_cm3_sbus;
    logic        hwrite_master_cm3_sbus;
    logic [2:0]  hsize_master_cm3_sbus;
    logic [2:0]  hburst_master_cm3_sbus;
    logic [3:0]  hprot_master_cm3_sbus;
    logic [1:0]  hmaster_master_cm3_sbus;
    logic [1:0]  htrans_master_cm3_sbus;
    logic        hmastlock_master_cm3_sbus;
    logic [31:0] hwdata_master_cm3_sbus;
    logic        hready_master_cm3_sbus;
    logic [1:0]  hresp_master_cm3_sbus;
    logic [31:0] hrdata_master_cm3_sbus;
    logic        exresp_master_cm3_sbus;

    /* Instruction master performs read-only accesses on the code bus */
    assign hwdata_master_cm3_ibus = 32'b0;
    assign hwrite_master_cm3_ibus = 1'b0;
    assign hmastlock_master_cm3_ibus = 1'b0;

    /* Data master exposes no lock signal at the integration level */
    assign hmastlock_master_cm3_dbus = 1'b0;

    /* Code bus is processor-only, so HMASTER 0 identifies the CPU */
    assign hmaster_master_cm3_ibus = 4'h0;

    /* ARM Cortex-M3 DesignStart sub-system (obfuscated eval netlist) */
    CORTEXM3INTEGRATIONDS core1 (
        .ISOLATEn      (1'b1),
        .RETAINn       (1'b1),
        .nTRST         (ntrst),
        .SWCLKTCK      (swclk_i),
        .SWDITMS       (swdi),
        .TDI           (tdi),
        .CDBGPWRUPACK  (core_debug_power_up_ack),

        .PORESETn      (porst_n),
        .SYSRESETn     (sysrst_n),
        .RSTBYPASS     (rst_bypass_enabled),
        .CGBYPASS      (1'b0),
        .FCLK          (fclk),
        .HCLK          (hclk),
        .TRACECLKIN    (fclk),
        /* No secondary SysTick clock, so tie STCLK instead of looping HCLK back */
        .STCLK         (1'b1),
        .STCALIB       (systick_calibration),
        .AUXFAULT      (32'b0),
        .BIGEND        (1'b0),

        .INTISR        (interrupt_req),
        .INTNMI        (non_maskable_interrupt),

        .HREADYI       (hready_master_cm3_ibus),
        .HRDATAI       (hrdata_master_cm3_ibus),
        .HRESPI        (hresp_master_cm3_ibus),
        .IFLUSH        (1'b0),
        .HREADYD       (hready_master_cm3_dbus),
        .HRDATAD       (hrdata_master_cm3_dbus),
        .HRESPD        (hresp_master_cm3_dbus),
        .EXRESPD       (exresp_master_cm3_dbus),
        .HREADYS       (hready_master_cm3_sbus),
        .HRDATAS       (hrdata_master_cm3_sbus),
        .HRESPS        (hresp_master_cm3_sbus),
        .EXRESPS       (exresp_master_cm3_sbus),

        .RXEV          (rx_event),
        .SLEEPHOLDREQn (sleep_hold_req_n),
        .EDBGRQ        (external_debug_req),
        .DBGRESTART    (debug_restart),
        .FIXMASTERTYPE (1'b0),
        .WICENREQ      (wkup_it_ctrl_en_req),
        .TSVALUEB      (48'b0),
        .SE            (scan_enabled),
        .MPUDISABLE    (1'b0),
        .DBGEN         (1'b1),
        .NIDEN         (1'b1),
        .DNOTITRANS    (1'b0),

        .TDO           (tdo_o),
        .nTDOEN        (ntdoen_o),
        .CDBGPWRUPREQ  (core_debug_power_up_req),
        .SWDO          (swdo),
        .SWDOEN        (swdo_enabled),
        .JTAGNSW       (),
        .SWV           (swv_o),
        .TRACECLK      (trace_clk_o),
        .TRACEDATA     (trace_data_o),
        .HTMDHADDR     (),
        .HTMDHTRANS    (),
        .HTMDHSIZE     (),
        .HTMDHBURST    (),
        .HTMDHPROT     (),
        .HTMDHWDATA    (),
        .HTMDHWRITE    (),
        .HTMDHRDATA    (),
        .HTMDHREADY    (),
        .HTMDHRESP     (),

        .HADDRI        (haddr_master_cm3_ibus),
        .HTRANSI       (htrans_master_cm3_ibus),
        .HSIZEI        (hsize_master_cm3_ibus),
        .HBURSTI       (hburst_master_cm3_ibus),
        .HPROTI        (hprot_master_cm3_ibus),
        .MEMATTRI      (),
        .HADDRD        (haddr_master_cm3_dbus),
        .HTRANSD       (htrans_master_cm3_dbus),
        .HSIZED        (hsize_master_cm3_dbus),
        .HWRITED       (hwrite_master_cm3_dbus),
        .HBURSTD       (hburst_master_cm3_dbus),
        .HPROTD        (hprot_master_cm3_dbus),
        .MEMATTRD      (),
        .HMASTERD       (hmaster_master_cm3_dbus),
        .HWDATAD       (hwdata_master_cm3_dbus),
        .EXREQD        (),
        .HADDRS        (haddr_master_cm3_sbus),
        .HTRANSS       (htrans_master_cm3_sbus),
        .HSIZES        (hsize_master_cm3_sbus),
        .HWRITES       (hwrite_master_cm3_sbus),
        .HBURSTS       (hburst_master_cm3_sbus),
        .HPROTS        (hprot_master_cm3_sbus),
        .HMASTLOCKS    (hmastlock_master_cm3_sbus),
        .MEMATTRS      (),
        .HMASTERS       (hmaster_master_cm3_sbus),
        .HWDATAS       (hwdata_master_cm3_sbus),
        .EXREQS        (),

        .BRCHSTAT      (),
        .HALTED        (),
        .DBGRESTARTED  (),
        .LOCKUP        (),
        .SLEEPING      (),
        .SLEEPDEEP     (),
        .SLEEPHOLDACKn (sleep_hold_ack_n),
        .ETMINTNUM     (),
        .ETMINTSTAT    (),
        .TRCENA        (),
        .CURRPRI       (),
        .SYSRESETREQ   (core_sysrst_req),
        .TXEV          (),
        .GATEHCLK      (),
        .WICENACK      (wkup_it_ctrl_en_ack),
        .WAKEUP        (wkup)
    );

    /* IOMUX sub-system */
    logic        uart1_txd;
    logic        uart1_rxd;
    logic        uart1_swap;
    logic        uart1_rts_n;
    logic        uart1_cts_n;
    logic        uart2_txd;
    logic        uart2_rxd;
    logic        uart2_swap;
    logic        uart2_rts_n;
    logic        uart2_cts_n;
    logic        tuart1_txd;
    logic        tuart1_rxd;
    logic        tuart1_swap;
    logic [3:0]  gpioa_pin00_alternate_number;
    logic [3:0]  gpioa_pin01_alternate_number;
    logic [3:0]  gpioa_pin02_alternate_number;
    logic [3:0]  gpioa_pin03_alternate_number;
    logic [3:0]  gpioa_pin04_alternate_number;
    logic [3:0]  gpioa_pin05_alternate_number;
    logic [3:0]  gpioa_pin06_alternate_number;
    logic [3:0]  gpioa_pin07_alternate_number;
    logic [3:0]  gpioa_pin08_alternate_number;
    logic [3:0]  gpioa_pin09_alternate_number;
    logic [3:0]  gpioa_pin10_alternate_number;
    logic [3:0]  gpioa_pin11_alternate_number;
    logic [3:0]  gpioa_pin12_alternate_number;
    logic [3:0]  gpioa_pin13_alternate_number;
    logic [3:0]  gpioa_pin14_alternate_number;
    logic [3:0]  gpioa_pin15_alternate_number;
    logic [15:0] gpioa_afio_enabled;
    logic [15:0] gpioa_afio_output_enabled;
    logic [15:0] gpioa_afio_output_data;
    logic [15:0] gpioa_afio_input_data;
    logic [3:0]  gpiob_pin00_alternate_number;
    logic [3:0]  gpiob_pin01_alternate_number;
    logic [3:0]  gpiob_pin02_alternate_number;
    logic [3:0]  gpiob_pin03_alternate_number;
    logic [3:0]  gpiob_pin04_alternate_number;
    logic [3:0]  gpiob_pin05_alternate_number;
    logic [3:0]  gpiob_pin06_alternate_number;
    logic [3:0]  gpiob_pin07_alternate_number;
    logic [3:0]  gpiob_pin08_alternate_number;
    logic [3:0]  gpiob_pin09_alternate_number;
    logic [3:0]  gpiob_pin10_alternate_number;
    logic [3:0]  gpiob_pin11_alternate_number;
    logic [3:0]  gpiob_pin12_alternate_number;
    logic [3:0]  gpiob_pin13_alternate_number;
    logic [3:0]  gpiob_pin14_alternate_number;
    logic [3:0]  gpiob_pin15_alternate_number;
    logic [15:0] gpiob_afio_enabled;
    logic [15:0] gpiob_afio_output_enabled;
    logic [15:0] gpiob_afio_output_data;
    logic [15:0] gpiob_afio_input_data;

    iomux_top iomux (
        .gpioa_pin00_alternate_number_i (gpioa_pin00_alternate_number),
        .gpioa_pin01_alternate_number_i (gpioa_pin01_alternate_number),
        .gpioa_pin02_alternate_number_i (gpioa_pin02_alternate_number),
        .gpioa_pin03_alternate_number_i (gpioa_pin03_alternate_number),
        .gpioa_pin04_alternate_number_i (gpioa_pin04_alternate_number),
        .gpioa_pin05_alternate_number_i (gpioa_pin05_alternate_number),
        .gpioa_pin06_alternate_number_i (gpioa_pin06_alternate_number),
        .gpioa_pin07_alternate_number_i (gpioa_pin07_alternate_number),
        .gpioa_pin08_alternate_number_i (gpioa_pin08_alternate_number),
        .gpioa_pin09_alternate_number_i (gpioa_pin09_alternate_number),
        .gpioa_pin10_alternate_number_i (gpioa_pin10_alternate_number),
        .gpioa_pin11_alternate_number_i (gpioa_pin11_alternate_number),
        .gpioa_pin12_alternate_number_i (gpioa_pin12_alternate_number),
        .gpioa_pin13_alternate_number_i (gpioa_pin13_alternate_number),
        .gpioa_pin14_alternate_number_i (gpioa_pin14_alternate_number),
        .gpioa_pin15_alternate_number_i (gpioa_pin15_alternate_number),
        .gpiob_pin00_alternate_number_i (gpiob_pin00_alternate_number),
        .gpiob_pin01_alternate_number_i (gpiob_pin01_alternate_number),
        .gpiob_pin02_alternate_number_i (gpiob_pin02_alternate_number),
        .gpiob_pin03_alternate_number_i (gpiob_pin03_alternate_number),
        .gpiob_pin04_alternate_number_i (gpiob_pin04_alternate_number),
        .gpiob_pin05_alternate_number_i (gpiob_pin05_alternate_number),
        .gpiob_pin06_alternate_number_i (gpiob_pin06_alternate_number),
        .gpiob_pin07_alternate_number_i (gpiob_pin07_alternate_number),
        .gpiob_pin08_alternate_number_i (gpiob_pin08_alternate_number),
        .gpiob_pin09_alternate_number_i (gpiob_pin09_alternate_number),
        .gpiob_pin10_alternate_number_i (gpiob_pin10_alternate_number),
        .gpiob_pin11_alternate_number_i (gpiob_pin11_alternate_number),
        .gpiob_pin12_alternate_number_i (gpiob_pin12_alternate_number),
        .gpiob_pin13_alternate_number_i (gpiob_pin13_alternate_number),
        .gpiob_pin14_alternate_number_i (gpiob_pin14_alternate_number),
        .gpiob_pin15_alternate_number_i (gpiob_pin15_alternate_number),
        .gpioa_afio_enabled_o           (gpioa_afio_enabled),
        .gpioa_afio_output_enabled_o    (gpioa_afio_output_enabled),
        .gpioa_afio_output_data_o       (gpioa_afio_output_data),
        .gpioa_afio_input_data_i        (gpioa_afio_input_data),
        .gpiob_afio_enabled_o           (gpiob_afio_enabled),
        .gpiob_afio_output_enabled_o    (gpiob_afio_output_enabled),
        .gpiob_afio_output_data_o       (gpiob_afio_output_data),
        .gpiob_afio_input_data_i        (gpiob_afio_input_data),
        .uart1_swap_i                   (uart1_swap),
        .uart1_txd_i                    (uart1_txd),
        .uart1_rxd_o                    (uart1_rxd),
        .uart1_rts_n_i                  (uart1_rts_n),
        .uart1_cts_n_o                  (uart1_cts_n),
        .uart2_swap_i                   (uart2_swap),
        .uart2_txd_i                    (uart2_txd),
        .uart2_rxd_o                    (uart2_rxd),
        .uart2_rts_n_i                  (uart2_rts_n),
        .uart2_cts_n_o                  (uart2_cts_n),
        .tuart1_swap_i                  (tuart1_swap),
        .tuart1_txd_i                   (tuart1_txd),
        .tuart1_rxd_o                   (tuart1_rxd)
    );

    /* HCLK distribution signals from RCC */
    logic hclk_flash;
    logic hclk_sram;
    logic hclk_gpioa;
    logic hclk_gpiob;
    logic hclk_fmc;
    logic hclk_apb1_br;

    /* RCC signal */
    logic        hsel_rcc;
    logic [31:0] haddr_rcc;
    logic        hwrite_rcc;
    logic [2:0]  hsize_rcc;
    logic [3:0]  hmaster_rcc;
    logic [1:0]  htrans_rcc;
    logic [2:0]  hburst_rcc;
    logic [3:0]  hprot_rcc;
    logic        hmastlock_rcc;
    logic        hready_rcc;
    logic [31:0] hwdata_rcc;
    logic        hreadyout_rcc;
    logic        hresp_rcc;
    logic [31:0] hrdata_rcc;

    rcc_top rcc (
        .hclk_i                 (hclk),
        .hreset_n_i             (sysrst_n),
        .hsel_i                 (hsel_rcc),
        .haddr_i                (haddr_rcc),
        .hwrite_i               (hwrite_rcc),
        .hsize_i                (hsize_rcc),
        .hmaster_i              (hmaster_rcc),
        .htrans_i               (htrans_rcc),
        .hburst_i               (hburst_rcc),
        .hprot_i                (hprot_rcc),
        .hmastlock_i            (hmastlock_rcc),
        .hready_i               (hready_rcc),
        .hwdata_i               (hwdata_rcc),
        .hreadyout_o            (hreadyout_rcc),
        .hresp_o                (hresp_rcc),
        .hrdata_o               (hrdata_rcc),

        .hclk_flash_o           (hclk_flash),
        .hclk_sram_o            (hclk_sram),
        .hclk_gpioa_o           (hclk_gpioa),
        .gpioa_reset_request_o  (gpioa_rst_req),
        .hclk_gpiob_o           (hclk_gpiob),
        .gpiob_reset_request_o  (gpiob_rst_req),
        .hclk_fmc_o             (hclk_fmc),
        .hclk_apb1_br_o         (hclk_apb1_br),
        .uart1_reset_request_o  (uart1_rst_req),
        .uart2_reset_request_o  (uart2_rst_req),
        .tuart1_reset_request_o (tuart1_rst_req)
    );

    /* Flash Model Main Bank signal */
    logic        hsel_flash;
    logic [31:0] haddr_flash;
    logic [31:0] hwdata_flash;
    logic        hwrite_flash;
    logic [1:0]  htrans_flash;
    logic [2:0]  hburst_flash;
    logic [3:0]  hprot_flash;
    logic        hmastlock_flash;
    logic [2:0]  hsize_flash;
    logic [3:0]  hmaster_flash;
    logic        hready_flash;
    logic        hreadyout_flash;
    logic        hresp_flash;
    logic [31:0] hrdata_flash;

    /* FMC and flash model interconnect signal */
    logic       flash_model_bank_erase_req;
    logic       flash_model_sector_erase_req;
    logic [5:0] flash_model_sector_erase_sector_idx;
    logic       flash_model_program_en;
    logic       flash_model_busy;
    logic       flash_model_ops_done;
    logic       flash_model_program_precheck_err;
    logic       flash_model_program_unaligned;
    logic       flash_model_program_pending;

    flash_model_top #(.ADDR_WIDTH (14)) flash_model_main_bank (
        .hclk_i                    (hclk_flash),
        .hreset_n_i                (hrst_n_flash),
        .hsel_i                    (hsel_flash),
        .haddr_i                   (haddr_flash),
        .hwrite_i                  (hwrite_flash),
        .hsize_i                   (hsize_flash),
        .hmaster_i                 (hmaster_flash),
        .htrans_i                  (htrans_flash),
        .hburst_i                  (hburst_flash),
        .hprot_i                   (hprot_flash),
        .hmastlock_i               (hmastlock_flash),
        .hready_i                  (hready_flash),
        .hwdata_i                  (hwdata_flash),
        .hreadyout_o               (hreadyout_flash),
        .hresp_o                   (hresp_flash),
        .hrdata_o                  (hrdata_flash),
        .bank_erase_req_i          (flash_model_bank_erase_req),
        .sector_erase_req_i        (flash_model_sector_erase_req),
        .sector_erase_sector_idx_i (flash_model_sector_erase_sector_idx),
        .program_en_i              (flash_model_program_en),
        .busy_o                    (flash_model_busy),
        .ops_done_o                (flash_model_ops_done),
        .program_precheck_err_o    (flash_model_program_precheck_err),
        .program_unaligned_o       (flash_model_program_unaligned),
        .program_pending_o         (flash_model_program_pending)
    );

    /* SRAM Model signal */
    logic        hsel_sram;
    logic [31:0] haddr_sram;
    logic        hwrite_sram;
    logic [2:0]  hsize_sram;
    logic [3:0]  hmaster_sram;
    logic [1:0]  htrans_sram;
    logic [2:0]  hburst_sram;
    logic [3:0]  hprot_sram;
    logic        hmastlock_sram;
    logic        hready_sram;
    logic [31:0] hwdata_sram;
    logic        hreadyout_sram;
    logic        hresp_sram;
    logic [31:0] hrdata_sram;

    sram_model_top #(.ADDR_WIDTH (14)) sram_model (
        .hclk_i      (hclk_sram),
        .hreset_n_i  (hrst_n_sram),
        .hsel_i      (hsel_sram),
        .haddr_i     (haddr_sram),
        .hwrite_i    (hwrite_sram),
        .hsize_i     (hsize_sram),
        .hmaster_i   (hmaster_sram),
        .htrans_i    (htrans_sram),
        .hburst_i    (hburst_sram),
        .hprot_i     (hprot_sram),
        .hmastlock_i (hmastlock_sram),
        .hready_i    (hready_sram),
        .hwdata_i    (hwdata_sram),
        .hreadyout_o (hreadyout_sram),
        .hresp_o     (hresp_sram),
        .hrdata_o    (hrdata_sram)
    );

    /* GPIO A signal */
    logic        hsel_gpioa;
    logic [31:0] haddr_gpioa;
    logic        hwrite_gpioa;
    logic [2:0]  hsize_gpioa;
    logic [3:0]  hmaster_gpioa;
    logic [1:0]  htrans_gpioa;
    logic [2:0]  hburst_gpioa;
    logic [3:0]  hprot_gpioa;
    logic        hmastlock_gpioa;
    logic        hready_gpioa;
    logic [31:0] hwdata_gpioa;
    logic        hreadyout_gpioa;
    logic        hresp_gpioa;
    logic [31:0] hrdata_gpioa;

    gpio_top gpioa (
        .hclk_i                   (hclk_gpioa),
        .hreset_n_i               (hrst_n_gpioa),
        .hsel_i                   (hsel_gpioa),
        .haddr_i                  (haddr_gpioa),
        .hwrite_i                 (hwrite_gpioa),
        .hsize_i                  (hsize_gpioa),
        .hmaster_i                (hmaster_gpioa),
        .htrans_i                 (htrans_gpioa),
        .hburst_i                 (hburst_gpioa),
        .hprot_i                  (hprot_gpioa),
        .hmastlock_i              (hmastlock_gpioa),
        .hready_i                 (hready_gpioa),
        .hwdata_i                 (hwdata_gpioa),
        .hreadyout_o              (hreadyout_gpioa),
        .hresp_o                  (hresp_gpioa),
        .hrdata_o                 (hrdata_gpioa),
        .pin00_alternate_number_o (gpioa_pin00_alternate_number),
        .pin01_alternate_number_o (gpioa_pin01_alternate_number),
        .pin02_alternate_number_o (gpioa_pin02_alternate_number),
        .pin03_alternate_number_o (gpioa_pin03_alternate_number),
        .pin04_alternate_number_o (gpioa_pin04_alternate_number),
        .pin05_alternate_number_o (gpioa_pin05_alternate_number),
        .pin06_alternate_number_o (gpioa_pin06_alternate_number),
        .pin07_alternate_number_o (gpioa_pin07_alternate_number),
        .pin08_alternate_number_o (gpioa_pin08_alternate_number),
        .pin09_alternate_number_o (gpioa_pin09_alternate_number),
        .pin10_alternate_number_o (gpioa_pin10_alternate_number),
        .pin11_alternate_number_o (gpioa_pin11_alternate_number),
        .pin12_alternate_number_o (gpioa_pin12_alternate_number),
        .pin13_alternate_number_o (gpioa_pin13_alternate_number),
        .pin14_alternate_number_o (gpioa_pin14_alternate_number),
        .pin15_alternate_number_o (gpioa_pin15_alternate_number),
        .afio_enabled_i           (gpioa_afio_enabled),
        .afio_output_enabled_i    (gpioa_afio_output_enabled),
        .afio_output_data_i       (gpioa_afio_output_data),
        .afio_input_data_o        (gpioa_afio_input_data),
        .pin_io                   (port_a_io)
    );

    /* GPIO B signal */
    logic        hsel_gpiob;
    logic [31:0] haddr_gpiob;
    logic        hwrite_gpiob;
    logic [2:0]  hsize_gpiob;
    logic [3:0]  hmaster_gpiob;
    logic [1:0]  htrans_gpiob;
    logic [2:0]  hburst_gpiob;
    logic [3:0]  hprot_gpiob;
    logic        hmastlock_gpiob;
    logic        hready_gpiob;
    logic [31:0] hwdata_gpiob;
    logic        hreadyout_gpiob;
    logic        hresp_gpiob;
    logic [31:0] hrdata_gpiob;

    gpio_top gpiob (
        .hclk_i                   (hclk_gpiob),
        .hreset_n_i               (hrst_n_gpiob),
        .hsel_i                   (hsel_gpiob),
        .haddr_i                  (haddr_gpiob),
        .hwrite_i                 (hwrite_gpiob),
        .hsize_i                  (hsize_gpiob),
        .hmaster_i                (hmaster_gpiob),
        .htrans_i                 (htrans_gpiob),
        .hburst_i                 (hburst_gpiob),
        .hprot_i                  (hprot_gpiob),
        .hmastlock_i              (hmastlock_gpiob),
        .hready_i                 (hready_gpiob),
        .hwdata_i                 (hwdata_gpiob),
        .hreadyout_o              (hreadyout_gpiob),
        .hresp_o                  (hresp_gpiob),
        .hrdata_o                 (hrdata_gpiob),
        .pin00_alternate_number_o (gpiob_pin00_alternate_number),
        .pin01_alternate_number_o (gpiob_pin01_alternate_number),
        .pin02_alternate_number_o (gpiob_pin02_alternate_number),
        .pin03_alternate_number_o (gpiob_pin03_alternate_number),
        .pin04_alternate_number_o (gpiob_pin04_alternate_number),
        .pin05_alternate_number_o (gpiob_pin05_alternate_number),
        .pin06_alternate_number_o (gpiob_pin06_alternate_number),
        .pin07_alternate_number_o (gpiob_pin07_alternate_number),
        .pin08_alternate_number_o (gpiob_pin08_alternate_number),
        .pin09_alternate_number_o (gpiob_pin09_alternate_number),
        .pin10_alternate_number_o (gpiob_pin10_alternate_number),
        .pin11_alternate_number_o (gpiob_pin11_alternate_number),
        .pin12_alternate_number_o (gpiob_pin12_alternate_number),
        .pin13_alternate_number_o (gpiob_pin13_alternate_number),
        .pin14_alternate_number_o (gpiob_pin14_alternate_number),
        .pin15_alternate_number_o (gpiob_pin15_alternate_number),
        .afio_enabled_i           (gpiob_afio_enabled),
        .afio_output_enabled_i    (gpiob_afio_output_enabled),
        .afio_output_data_i       (gpiob_afio_output_data),
        .afio_input_data_o        (gpiob_afio_input_data),
        .pin_io                   (port_b_io)
    );

    /* FMC signal */
    logic        hsel_fmc;
    logic [31:0] haddr_fmc;
    logic        hwrite_fmc;
    logic [2:0]  hsize_fmc;
    logic [3:0]  hmaster_fmc;
    logic [1:0]  htrans_fmc;
    logic [2:0]  hburst_fmc;
    logic [3:0]  hprot_fmc;
    logic        hmastlock_fmc;
    logic        hready_fmc;
    logic [31:0] hwdata_fmc;
    logic        hreadyout_fmc;
    logic        hresp_fmc;
    logic [31:0] hrdata_fmc;

    fmc_top fmc (
        .hclk_i                                (hclk_fmc),
        .hreset_n_i                            (hrst_n_fmc),
        .hsel_i                                (hsel_fmc),
        .haddr_i                               (haddr_fmc),
        .hwrite_i                              (hwrite_fmc),
        .hsize_i                               (hsize_fmc),
        .hmaster_i                             (hmaster_fmc),
        .htrans_i                              (htrans_fmc),
        .hburst_i                              (hburst_fmc),
        .hprot_i                               (hprot_fmc),
        .hmastlock_i                           (hmastlock_fmc),
        .hready_i                              (hready_fmc),
        .hwdata_i                              (hwdata_fmc),
        .hreadyout_o                           (hreadyout_fmc),
        .hresp_o                               (hresp_fmc),
        .hrdata_o                              (hrdata_fmc),
        .flash_model_busy_i                    (flash_model_busy),
        .flash_model_ops_done_i                (flash_model_ops_done),
        .flash_model_program_precheck_err_i    (flash_model_program_precheck_err),
        .flash_model_program_unaligned_i       (flash_model_program_unaligned),
        .flash_model_program_pending_i         (flash_model_program_pending),
        .flash_model_bank_erase_req_o          (flash_model_bank_erase_req),
        .flash_model_sector_erase_req_o        (flash_model_sector_erase_req),
        .flash_model_sector_erase_sector_idx_o (flash_model_sector_erase_sector_idx),
        .flash_model_program_en_o              (flash_model_program_en)
    );

    /* AHB to APB bridge signal */
    logic        hsel_apb1_br;
    logic [31:0] haddr_apb1_br;
    logic        hwrite_apb1_br;
    logic [2:0]  hsize_apb1_br;
    logic [3:0]  hmaster_apb1_br;
    logic [1:0]  htrans_apb1_br;
    logic [2:0]  hburst_apb1_br;
    logic [3:0]  hprot_apb1_br;
    logic        hmastlock_apb1_br;
    logic        hready_apb1_br;
    logic [31:0] hwdata_apb1_br;
    logic        hreadyout_apb1_br;
    logic        hresp_apb1_br;
    logic [31:0] hrdata_apb1_br;

    /* APB1 interconnect signals */
    logic        apb_penable;
    logic [31:0] apb_paddr;
    logic        apb_pwrite;
    logic [3:0]  apb_pstrb;
    logic [2:0]  apb_pprot;
    logic [31:0] apb_pwdata;
    logic        apb_psel_uart1;
    logic        apb_pready_uart1;
    logic        apb_pslverr_uart1;
    logic [31:0] apb_prdata_uart1;
    logic        apb_psel_uart2;
    logic        apb_pready_uart2;
    logic        apb_pslverr_uart2;
    logic [31:0] apb_prdata_uart2;
    logic        apb_psel_tuart1;
    logic        apb_pready_tuart1;
    logic        apb_pslverr_tuart1;
    logic [31:0] apb_prdata_tuart1;
    logic        apb_psel_wwdg;
    logic        apb_pready_wwdg;
    logic        apb_pslverr_wwdg;
    logic [31:0] apb_prdata_wwdg;

    apb1_br_top apb1_br (
        .hclk_i           (hclk_apb1_br),
        .hreset_n_i       (hrst_n_apb1_br),
        .hsel_i           (hsel_apb1_br),
        .haddr_i          (haddr_apb1_br),
        .hwrite_i         (hwrite_apb1_br),
        .hsize_i          (hsize_apb1_br),
        .hmaster_i        (hmaster_apb1_br),
        .htrans_i         (htrans_apb1_br),
        .hburst_i         (hburst_apb1_br),
        .hprot_i          (hprot_apb1_br),
        .hmastlock_i      (hmastlock_apb1_br),
        .hready_i         (hready_apb1_br),
        .hwdata_i         (hwdata_apb1_br),
        .pclken_i         (1'b1),
        .hreadyout_o      (hreadyout_apb1_br),
        .hresp_o          (hresp_apb1_br),
        .hrdata_o         (hrdata_apb1_br),
        .penable_o        (apb_penable),
        .paddr_o          (apb_paddr),
        .pwrite_o         (apb_pwrite),
        .pstrb_o          (apb_pstrb),
        .pprot_o          (apb_pprot),
        .pwdata_o         (apb_pwdata),
        .psel_uart1_o     (apb_psel_uart1),
        .pready_uart1_i   (apb_pready_uart1),
        .pslverr_uart1_i  (apb_pslverr_uart1),
        .prdata_uart1_i   (apb_prdata_uart1),
        .psel_uart2_o     (apb_psel_uart2),
        .pready_uart2_i   (apb_pready_uart2),
        .pslverr_uart2_i  (apb_pslverr_uart2),
        .prdata_uart2_i   (apb_prdata_uart2),
        .psel_tuart1_o    (apb_psel_tuart1),
        .pready_tuart1_i  (apb_pready_tuart1),
        .pslverr_tuart1_i (apb_pslverr_tuart1),
        .prdata_tuart1_i  (apb_prdata_tuart1),
        .psel_wwdg_o      (apb_psel_wwdg),
        .pready_wwdg_i    (apb_pready_wwdg),
        .pslverr_wwdg_i   (apb_pslverr_wwdg),
        .prdata_wwdg_i    (apb_prdata_wwdg)
    );

    /* APB1 UART1 */
    uart_top uart1 (
        .pclk_i     (hclk_apb1_br),
        .preset_n_i (uart1_rst_n),
        .psel_i     (apb_psel_uart1),
        .penable_i  (apb_penable),
        .paddr_i    (apb_paddr),
        .pwrite_i   (apb_pwrite),
        .pstrb_i    (apb_pstrb),
        .pprot_i    (apb_pprot),
        .pwdata_i   (apb_pwdata),
        .pready_o   (apb_pready_uart1),
        .pslverr_o  (apb_pslverr_uart1),
        .prdata_o   (apb_prdata_uart1),
        .rxd_i      (uart1_rxd),
        .txd_o      (uart1_txd),
        .swap_o     (uart1_swap),
        .cts_n_i    (uart1_cts_n),
        .rts_n_o    (uart1_rts_n),
        .rx_irq_o   (uart1_rx_irq),
        .tx_irq_o   (uart1_tx_irq)
    );

    /* APB1 UART2 */
    uart_top uart2 (
        .pclk_i     (hclk_apb1_br),
        .preset_n_i (uart2_rst_n),
        .psel_i     (apb_psel_uart2),
        .penable_i  (apb_penable),
        .paddr_i    (apb_paddr),
        .pwrite_i   (apb_pwrite),
        .pstrb_i    (apb_pstrb),
        .pprot_i    (apb_pprot),
        .pwdata_i   (apb_pwdata),
        .pready_o   (apb_pready_uart2),
        .pslverr_o  (apb_pslverr_uart2),
        .prdata_o   (apb_prdata_uart2),
        .rxd_i      (uart2_rxd),
        .txd_o      (uart2_txd),
        .swap_o     (uart2_swap),
        .cts_n_i    (uart2_cts_n),
        .rts_n_o    (uart2_rts_n),
        .rx_irq_o   (uart2_rx_irq),
        .tx_irq_o   (uart2_tx_irq)
    );

    /* APB1 TUART1 */
    tuart_top tuart1 (
        .pclk_i     (hclk_apb1_br),
        .preset_n_i (tuart1_rst_n),
        .psel_i     (apb_psel_tuart1),
        .penable_i  (apb_penable),
        .paddr_i    (apb_paddr),
        .pwrite_i   (apb_pwrite),
        .pstrb_i    (apb_pstrb),
        .pprot_i    (apb_pprot),
        .pwdata_i   (apb_pwdata),
        .pready_o   (apb_pready_tuart1),
        .pslverr_o  (apb_pslverr_tuart1),
        .prdata_o   (apb_prdata_tuart1),
        .rxd_i      (tuart1_rxd),
        .txd_o      (tuart1_txd),
        .swap_o     (tuart1_swap)
    );

    /* APB1 WWDG */
    wwdg_top wwdg (
        .pclk_i     (hclk_apb1_br),
        .preset_n_i (hrst_n_apb1_br),
        .psel_i     (apb_psel_wwdg),
        .penable_i  (apb_penable),
        .paddr_i    (apb_paddr),
        .pwrite_i   (apb_pwrite),
        .pstrb_i    (apb_pstrb),
        .pprot_i    (apb_pprot),
        .pwdata_i   (apb_pwdata),
        .pready_o   (apb_pready_wwdg),
        .pslverr_o  (apb_pslverr_wwdg),
        .prdata_o   (apb_prdata_wwdg),
        .rst_req_o  (wwdg_rst_req),
        .it_req_o   (wwdg_ewi_interrupt)
    );

    rst_gen_top rst_gen (
        .refclk_i          (refclk_i),
        .hsi_i             (hsi),
        .porst_n_i         (porst_n_i),
        .xrst_n_i          (xrst_n_i),
        .hsi_ready_i       (hsi_ready),
        .core_sysrst_req_i (core_sysrst_req),
        .gpioa_rst_req_i   (gpioa_rst_req),
        .gpiob_rst_req_i   (gpiob_rst_req),
        .uart1_rst_req_i   (uart1_rst_req),
        .uart2_rst_req_i   (uart2_rst_req),
        .tuart1_rst_req_i  (tuart1_rst_req),
        .wwdg_rst_req_i    (wwdg_rst_req),
        .refrst_n_o        (refrst_n),
        .porst_n_o         (porst_n),
        .sysrst_n_o        (sysrst_n),
        .flash_rst_n_o     (hrst_n_flash),
        .sram_rst_n_o      (hrst_n_sram),
        .gpioa_rst_n_o     (hrst_n_gpioa),
        .gpiob_rst_n_o     (hrst_n_gpiob),
        .fmc_rst_n_o       (hrst_n_fmc),
        .apb_rst_n_o       (hrst_n_apb1_br),
        .uart1_rst_n_o     (uart1_rst_n),
        .uart2_rst_n_o     (uart2_rst_n),
        .tuart1_rst_n_o    (tuart1_rst_n)
    );

    /* AHB bus matrix: three Cortex-M3 master ports and seven slave ports */
    bus_icc_top bus_icc (
        .hclk_i                      (hclk),
        .hreset_n_i                  (sysrst_n),
        .remap_i                     (4'b0000),

        /* Cortex-M3 instruction bus */
        .haddr_master_cm3_ibus_i     (haddr_master_cm3_ibus),
        .hwrite_master_cm3_ibus_i    (hwrite_master_cm3_ibus),
        .hsize_master_cm3_ibus_i     (hsize_master_cm3_ibus),
        .hburst_master_cm3_ibus_i    (hburst_master_cm3_ibus),
        .hprot_master_cm3_ibus_i     (hprot_master_cm3_ibus),
        .hmaster_master_cm3_ibus_i   (hmaster_master_cm3_ibus),
        .htrans_master_cm3_ibus_i    (htrans_master_cm3_ibus),
        .hmastlock_master_cm3_ibus_i (hmastlock_master_cm3_ibus),
        .hwdata_master_cm3_ibus_i    (hwdata_master_cm3_ibus),
        .hready_master_cm3_ibus_o    (hready_master_cm3_ibus),
        .hresp_master_cm3_ibus_o     (hresp_master_cm3_ibus[0]),
        .hrdata_master_cm3_ibus_o    (hrdata_master_cm3_ibus),

        /* Cortex-M3 data bus */
        .haddr_master_cm3_dbus_i     (haddr_master_cm3_dbus),
        .hwrite_master_cm3_dbus_i    (hwrite_master_cm3_dbus),
        .hsize_master_cm3_dbus_i     (hsize_master_cm3_dbus),
        .hburst_master_cm3_dbus_i    (hburst_master_cm3_dbus),
        .hprot_master_cm3_dbus_i     (hprot_master_cm3_dbus),
        .hmaster_master_cm3_dbus_i   ({2'b00, hmaster_master_cm3_dbus}),
        .htrans_master_cm3_dbus_i    (htrans_master_cm3_dbus),
        .hmastlock_master_cm3_dbus_i (hmastlock_master_cm3_dbus),
        .hwdata_master_cm3_dbus_i    (hwdata_master_cm3_dbus),
        .hready_master_cm3_dbus_o    (hready_master_cm3_dbus),
        .hresp_master_cm3_dbus_o     (hresp_master_cm3_dbus[0]),
        .hrdata_master_cm3_dbus_o    (hrdata_master_cm3_dbus),

        /* Cortex-M3 system bus */
        .haddr_master_cm3_sbus_i     (haddr_master_cm3_sbus),
        .hwrite_master_cm3_sbus_i    (hwrite_master_cm3_sbus),
        .hsize_master_cm3_sbus_i     (hsize_master_cm3_sbus),
        .hburst_master_cm3_sbus_i    (hburst_master_cm3_sbus),
        .hprot_master_cm3_sbus_i     (hprot_master_cm3_sbus),
        .hmaster_master_cm3_sbus_i   ({2'b00, hmaster_master_cm3_sbus}),
        .htrans_master_cm3_sbus_i    (htrans_master_cm3_sbus),
        .hmastlock_master_cm3_sbus_i (hmastlock_master_cm3_sbus),
        .hwdata_master_cm3_sbus_i    (hwdata_master_cm3_sbus),
        .hready_master_cm3_sbus_o    (hready_master_cm3_sbus),
        .hresp_master_cm3_sbus_o     (hresp_master_cm3_sbus[0]),
        .hrdata_master_cm3_sbus_o    (hrdata_master_cm3_sbus),

        /* AHB slave ports 01 to 07 */
        .hsel_rcc_o                  (hsel_rcc),
        .haddr_rcc_o                 (haddr_rcc),
        .hwrite_rcc_o                (hwrite_rcc),
        .hsize_rcc_o                 (hsize_rcc),
        .hmaster_rcc_o               (hmaster_rcc),
        .htrans_rcc_o                (htrans_rcc),
        .hburst_rcc_o                (hburst_rcc),
        .hprot_rcc_o                 (hprot_rcc),
        .hmastlock_rcc_o             (hmastlock_rcc),
        .hready_rcc_o                (hready_rcc),
        .hwdata_rcc_o                (hwdata_rcc),
        .hreadyout_rcc_i             (hreadyout_rcc),
        .hresp_rcc_i                 (hresp_rcc),
        .hrdata_rcc_i                (hrdata_rcc),
        .hsel_flash_o                (hsel_flash),
        .haddr_flash_o               (haddr_flash),
        .hwrite_flash_o              (hwrite_flash),
        .hsize_flash_o               (hsize_flash),
        .hmaster_flash_o             (hmaster_flash),
        .htrans_flash_o              (htrans_flash),
        .hburst_flash_o              (hburst_flash),
        .hprot_flash_o               (hprot_flash),
        .hmastlock_flash_o           (hmastlock_flash),
        .hready_flash_o              (hready_flash),
        .hwdata_flash_o              (hwdata_flash),
        .hreadyout_flash_i           (hreadyout_flash),
        .hresp_flash_i               (hresp_flash),
        .hrdata_flash_i              (hrdata_flash),
        .hsel_sram_o                 (hsel_sram),
        .haddr_sram_o                (haddr_sram),
        .hwrite_sram_o               (hwrite_sram),
        .hsize_sram_o                (hsize_sram),
        .hmaster_sram_o              (hmaster_sram),
        .htrans_sram_o               (htrans_sram),
        .hburst_sram_o               (hburst_sram),
        .hprot_sram_o                (hprot_sram),
        .hmastlock_sram_o            (hmastlock_sram),
        .hready_sram_o               (hready_sram),
        .hwdata_sram_o               (hwdata_sram),
        .hreadyout_sram_i            (hreadyout_sram),
        .hresp_sram_i                (hresp_sram),
        .hrdata_sram_i               (hrdata_sram),
        .hsel_gpioa_o                (hsel_gpioa),
        .haddr_gpioa_o               (haddr_gpioa),
        .hwrite_gpioa_o              (hwrite_gpioa),
        .hsize_gpioa_o               (hsize_gpioa),
        .hmaster_gpioa_o             (hmaster_gpioa),
        .htrans_gpioa_o              (htrans_gpioa),
        .hburst_gpioa_o              (hburst_gpioa),
        .hprot_gpioa_o               (hprot_gpioa),
        .hmastlock_gpioa_o           (hmastlock_gpioa),
        .hready_gpioa_o              (hready_gpioa),
        .hwdata_gpioa_o              (hwdata_gpioa),
        .hreadyout_gpioa_i           (hreadyout_gpioa),
        .hresp_gpioa_i               (hresp_gpioa),
        .hrdata_gpioa_i              (hrdata_gpioa),
        .hsel_gpiob_o                (hsel_gpiob),
        .haddr_gpiob_o               (haddr_gpiob),
        .hwrite_gpiob_o              (hwrite_gpiob),
        .hsize_gpiob_o               (hsize_gpiob),
        .hmaster_gpiob_o             (hmaster_gpiob),
        .htrans_gpiob_o              (htrans_gpiob),
        .hburst_gpiob_o              (hburst_gpiob),
        .hprot_gpiob_o               (hprot_gpiob),
        .hmastlock_gpiob_o           (hmastlock_gpiob),
        .hready_gpiob_o              (hready_gpiob),
        .hwdata_gpiob_o              (hwdata_gpiob),
        .hreadyout_gpiob_i           (hreadyout_gpiob),
        .hresp_gpiob_i               (hresp_gpiob),
        .hrdata_gpiob_i              (hrdata_gpiob),
        .hsel_fmc_o                  (hsel_fmc),
        .haddr_fmc_o                 (haddr_fmc),
        .hwrite_fmc_o                (hwrite_fmc),
        .hsize_fmc_o                 (hsize_fmc),
        .hmaster_fmc_o               (hmaster_fmc),
        .htrans_fmc_o                (htrans_fmc),
        .hburst_fmc_o                (hburst_fmc),
        .hprot_fmc_o                 (hprot_fmc),
        .hmastlock_fmc_o             (hmastlock_fmc),
        .hready_fmc_o                (hready_fmc),
        .hwdata_fmc_o                (hwdata_fmc),
        .hreadyout_fmc_i             (hreadyout_fmc),
        .hresp_fmc_i                 (hresp_fmc),
        .hrdata_fmc_i                (hrdata_fmc),
        .hsel_apb1_br_o              (hsel_apb1_br),
        .haddr_apb1_br_o             (haddr_apb1_br),
        .hwrite_apb1_br_o            (hwrite_apb1_br),
        .hsize_apb1_br_o             (hsize_apb1_br),
        .hmaster_apb1_br_o           (hmaster_apb1_br),
        .htrans_apb1_br_o            (htrans_apb1_br),
        .hburst_apb1_br_o            (hburst_apb1_br),
        .hprot_apb1_br_o             (hprot_apb1_br),
        .hmastlock_apb1_br_o         (hmastlock_apb1_br),
        .hready_apb1_br_o            (hready_apb1_br),
        .hwdata_apb1_br_o            (hwdata_apb1_br),
        .hreadyout_apb1_br_i         (hreadyout_apb1_br),
        .hresp_apb1_br_i             (hresp_apb1_br),
        .hrdata_apb1_br_i            (hrdata_apb1_br)
    );

    /* The bus matrix is AHB-Lite: HRESP is one bit and there is no
       exclusive response */
    assign hresp_master_cm3_ibus[1] = 1'b0;
    assign hresp_master_cm3_dbus[1] = 1'b0;
    assign hresp_master_cm3_sbus[1] = 1'b0;
    assign exresp_master_cm3_dbus = 1'b0;
    assign exresp_master_cm3_sbus = 1'b0;

endmodule
