`timescale 1ns / 1ps

module uart_top (
    input  logic        pclk_i,
    input  logic        preset_n_i,
    input  logic        psel_i,
    input  logic        penable_i,
    input  logic [31:0] paddr_i,
    input  logic        pwrite_i,
    input  logic [3:0]  pstrb_i,
    input  logic [2:0]  pprot_i,
    input  logic [31:0] pwdata_i,
    output logic        pready_o,
    output logic        pslverr_o,
    output logic [31:0] prdata_o,
    input  logic        rxd_i,
    output logic        txd_o,
    output logic        swap_o,
    input  logic        cts_n_i,
    output logic        rts_n_o,
    output logic        rx_irq_o,
    output logic        tx_irq_o
);

    logic apb_access;
    logic read_xfer_valid;
    logic write_xfer_valid;

    assign apb_access       = psel_i && penable_i;
    assign read_xfer_valid  = apb_access && !pwrite_i;
    assign write_xfer_valid = apb_access && pwrite_i;

    logic [31:0] cr1;      // [5] stop, [4] parity_type, [3] parity_en, [2:0] data_len
    logic [31:0] cr2;      // [1] rx_en, [0] tx_en
    logic [31:0] fifocr1;  // [21:17] rx_waterline, [16] rx_fifo_en, [5:1] tx_waterline, [0] tx_fifo_en
    logic [31:0] idlcr;    // [3:1] idle_th, [0] idle_type
    logic [31:0] hfccr;    // [10] cts_smp_mode, [9] cts_src, [8] cts_en, [4:3] rts1_waterline, [2] rts0_en, [1] rts_pol, [0] rts1_en
    logic [31:0] lincr;    // [0] brk_det_en
    logic [31:0] mpccr;    // [4] idle_mode, [3:2] match_mode, [1] match2_en, [0] match1_en
    logic [31:0] phycr;    // [24] msb_first, [17] resync_en, [16] des_en, [12] rxd_src, [11] rxd_pol, [10] txd_dir, [9] txd_pol, [8] swap, [0] loopback
    logic [31:0] brr;      // [16:4] div_mantissa
    logic [31:0] osrr;     // [5:0] oversample_ratio
    logic [31:0] mdr1;     // [7:0] match1_data
    logic [31:0] mdr2;     // [23:16] match2_data
    logic [31:0] ier;      // [26] rx_edge, [25] match2, [24] match1, [23] noise, [22] brk, [21] fe, [20] pe, [19] rxfifo_ud, [18] rx_ov, [17] idle, [16] rxrdy, [2] txfifo_ov, [1] txc, [0] txrdy
    logic [31:0] sr;
    logic [31:0] rdr;
    logic [31:0] isr;
    logic [31:0] icr;

    logic cr1_write_strobe;
    logic cr2_write_strobe;
    logic fifocr1_write_strobe;
    logic fifocr2_write_strobe;
    logic idlcr_write_strobe;
    logic hfccr_write_strobe;
    logic lincr_write_strobe;
    logic mpccr_write_strobe;
    logic phycr_write_strobe;
    logic brr_write_strobe;
    logic osrr_write_strobe;
    logic tdr_write_strobe;
    logic rdr_read_strobe;
    logic mdr1_write_strobe;
    logic mdr2_write_strobe;
    logic ier_write_strobe;
    logic icr_write_strobe;

    assign cr1_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h00);
    assign cr2_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h01);
    assign fifocr1_write_strobe = write_xfer_valid && (paddr_i[9:2] == 8'h02);
    assign fifocr2_write_strobe = write_xfer_valid && (paddr_i[9:2] == 8'h03);
    assign idlcr_write_strobe   = write_xfer_valid && (paddr_i[9:2] == 8'h05);
    assign hfccr_write_strobe   = write_xfer_valid && (paddr_i[9:2] == 8'h06);
    assign lincr_write_strobe   = write_xfer_valid && (paddr_i[9:2] == 8'h07);
    assign mpccr_write_strobe   = write_xfer_valid && (paddr_i[9:2] == 8'h08);
    assign phycr_write_strobe   = write_xfer_valid && (paddr_i[9:2] == 8'h09);
    assign brr_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h10);
    assign osrr_write_strobe    = write_xfer_valid && (paddr_i[9:2] == 8'h11);
    assign tdr_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h30);
    assign rdr_read_strobe      = read_xfer_valid  && (paddr_i[9:2] == 8'h31);
    assign mdr1_write_strobe    = write_xfer_valid && (paddr_i[9:2] == 8'h32);
    assign mdr2_write_strobe    = write_xfer_valid && (paddr_i[9:2] == 8'h33);
    assign ier_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h40);
    assign icr_write_strobe     = write_xfer_valid && (paddr_i[9:2] == 8'h42);

    logic cr1_byte0_write_strobe;
    logic cr2_byte0_write_strobe;
    logic fifocr1_byte0_write_strobe;
    logic fifocr1_byte2_write_strobe;
    logic hfccr_byte0_write_strobe;
    logic hfccr_byte1_write_strobe;
    logic idlcr_byte0_write_strobe;
    logic lincr_byte0_write_strobe;
    logic mpccr_byte0_write_strobe;
    logic phycr_byte0_write_strobe;
    logic phycr_byte1_write_strobe;
    logic phycr_byte2_write_strobe;
    logic phycr_byte3_write_strobe;
    logic brr_byte0_write_strobe;
    logic brr_byte1_write_strobe;
    logic brr_byte2_write_strobe;
    logic osrr_byte0_write_strobe;
    logic tdr_byte0_write_strobe;
    logic mdr1_byte0_write_strobe;
    logic mdr2_byte2_write_strobe;
    logic ier_byte0_write_strobe;
    logic ier_byte2_write_strobe;
    logic ier_byte3_write_strobe;

    assign cr1_byte0_write_strobe     = cr1_write_strobe     && pstrb_i[0];
    assign cr2_byte0_write_strobe     = cr2_write_strobe     && pstrb_i[0];
    assign fifocr1_byte0_write_strobe = fifocr1_write_strobe && pstrb_i[0];
    assign fifocr1_byte2_write_strobe = fifocr1_write_strobe && pstrb_i[2];
    assign hfccr_byte0_write_strobe   = hfccr_write_strobe   && pstrb_i[0];
    assign hfccr_byte1_write_strobe   = hfccr_write_strobe   && pstrb_i[1];
    assign idlcr_byte0_write_strobe   = idlcr_write_strobe   && pstrb_i[0];
    assign lincr_byte0_write_strobe   = lincr_write_strobe   && pstrb_i[0];
    assign mpccr_byte0_write_strobe   = mpccr_write_strobe   && pstrb_i[0];
    assign phycr_byte0_write_strobe   = phycr_write_strobe   && pstrb_i[0];
    assign phycr_byte1_write_strobe   = phycr_write_strobe   && pstrb_i[1];
    assign phycr_byte2_write_strobe   = phycr_write_strobe   && pstrb_i[2];
    assign phycr_byte3_write_strobe   = phycr_write_strobe   && pstrb_i[3];
    assign brr_byte0_write_strobe     = brr_write_strobe     && pstrb_i[0];
    assign brr_byte1_write_strobe     = brr_write_strobe     && pstrb_i[1];
    assign brr_byte2_write_strobe     = brr_write_strobe     && pstrb_i[2];
    assign osrr_byte0_write_strobe    = osrr_write_strobe    && pstrb_i[0];
    assign tdr_byte0_write_strobe     = tdr_write_strobe     && pstrb_i[0];
    assign mdr1_byte0_write_strobe    = mdr1_write_strobe    && pstrb_i[0];
    assign mdr2_byte2_write_strobe    = mdr2_write_strobe    && pstrb_i[2];
    assign ier_byte0_write_strobe     = ier_write_strobe     && pstrb_i[0];
    assign ier_byte2_write_strobe     = ier_write_strobe     && pstrb_i[2];
    assign ier_byte3_write_strobe     = ier_write_strobe     && pstrb_i[3];

    logic fifocr2_txfifoflush_strobe;
    logic fifocr2_rxfifoflush_strobe;
    logic mpccr_fstby_strobe;
    logic mpccr_fwk_strobe;
    logic icr_txfifoov_clear_strobe;
    logic icr_idle_clear_strobe;
    logic icr_rxov_clear_strobe;
    logic icr_rxfifoud_clear_strobe;
    logic icr_pe_clear_strobe;
    logic icr_fe_clear_strobe;
    logic icr_brk_clear_strobe;
    logic icr_noise_clear_strobe;
    logic icr_match1_clear_strobe;
    logic icr_match2_clear_strobe;
    logic icr_rxse_clear_strobe;

    assign fifocr2_txfifoflush_strobe = fifocr2_write_strobe && pstrb_i[0] && pwdata_i[0];
    assign fifocr2_rxfifoflush_strobe = fifocr2_write_strobe && pstrb_i[0] && pwdata_i[1];
    assign mpccr_fstby_strobe         = mpccr_write_strobe && pstrb_i[2] && pwdata_i[16];
    assign mpccr_fwk_strobe           = mpccr_write_strobe && pstrb_i[2] && pwdata_i[17];
    assign icr_txfifoov_clear_strobe  = icr_write_strobe && pstrb_i[0] && pwdata_i[2];
    assign icr_idle_clear_strobe      = icr_write_strobe && pstrb_i[2] && pwdata_i[17];
    assign icr_rxov_clear_strobe      = icr_write_strobe && pstrb_i[2] && pwdata_i[18];
    assign icr_rxfifoud_clear_strobe  = icr_write_strobe && pstrb_i[2] && pwdata_i[19];
    assign icr_pe_clear_strobe        = icr_write_strobe && pstrb_i[2] && pwdata_i[20];
    assign icr_fe_clear_strobe        = icr_write_strobe && pstrb_i[2] && pwdata_i[21];
    assign icr_brk_clear_strobe       = icr_write_strobe && pstrb_i[2] && pwdata_i[22];
    assign icr_noise_clear_strobe     = icr_write_strobe && pstrb_i[2] && pwdata_i[23];
    assign icr_match1_clear_strobe    = icr_write_strobe && pstrb_i[3] && pwdata_i[24];
    assign icr_match2_clear_strobe    = icr_write_strobe && pstrb_i[3] && pwdata_i[25];
    assign icr_rxse_clear_strobe      = icr_write_strobe && pstrb_i[3] && pwdata_i[26];

    always_ff @(posedge pclk_i or negedge preset_n_i) begin
        if (!preset_n_i) begin
            cr1     <= 32'h0000_0007;
            cr2     <= '0;
            fifocr1 <= 32'h0020_0000;
            idlcr   <= '0;
            hfccr   <= '0;
            lincr   <= '0;
            mpccr   <= '0;
            phycr   <= '0;
            brr     <= 32'h0000_0040;
            osrr    <= 32'h0000_0010;
            mdr1    <= '0;
            mdr2    <= '0;
            ier     <= '0;
        end else begin
            if (cr1_byte0_write_strobe)     cr1[5:0]     <= pwdata_i[5:0];
            if (cr2_byte0_write_strobe)     cr2[1:0]     <= pwdata_i[1:0];
            if (fifocr1_byte0_write_strobe) fifocr1[5:0] <= pwdata_i[5:0];
            if (fifocr1_byte2_write_strobe) fifocr1[21:16] <= pwdata_i[21:16];
            if (idlcr_byte0_write_strobe)   idlcr[3:0]   <= pwdata_i[3:0];
            if (hfccr_byte0_write_strobe)   hfccr[4:0]   <= pwdata_i[4:0];
            if (hfccr_byte1_write_strobe)   hfccr[10:8]  <= pwdata_i[10:8];
            if (lincr_byte0_write_strobe)   lincr[0]     <= pwdata_i[0];
            if (mpccr_byte0_write_strobe)   mpccr[4:0]   <= pwdata_i[4:0];
            if (phycr_byte0_write_strobe)   phycr[0]     <= pwdata_i[0];
            if (phycr_byte1_write_strobe)   phycr[12:8]  <= pwdata_i[12:8];
            if (phycr_byte2_write_strobe)   phycr[17:16] <= pwdata_i[17:16];
            if (phycr_byte3_write_strobe)   phycr[24]    <= pwdata_i[24];
            if (brr_byte0_write_strobe)     brr[7:4]     <= pwdata_i[7:4];
            if (brr_byte1_write_strobe)     brr[15:8]    <= pwdata_i[15:8];
            if (brr_byte2_write_strobe)     brr[16]      <= pwdata_i[16];
            if (osrr_byte0_write_strobe)    osrr[5:0]    <= pwdata_i[5:0];
            if (mdr1_byte0_write_strobe)    mdr1[7:0]    <= pwdata_i[7:0];
            if (mdr2_byte2_write_strobe)    mdr2[23:16]  <= pwdata_i[23:16];
            if (ier_byte0_write_strobe)     ier[2:0]     <= pwdata_i[2:0];
            if (ier_byte2_write_strobe)     ier[23:16]   <= pwdata_i[23:16];
            if (ier_byte3_write_strobe)     ier[26:24]   <= pwdata_i[26:24];
        end
    end

    logic [4:0] tx_fifo_cnt_interface;
    logic       tx_overflow_flag;
    logic       tx_fifo_empty_flag;
    logic [4:0] rx_fifo_cnt_interface;
    logic       rx_fifo_underflow_flag;
    logic       rx_fifo_empty_flag;
    logic [7:0] rx_data_interface;
    logic       rx_data_preframe_idle_flag;
    logic       rx_data_preframe_empty_flag;
    logic       rx_data_framing_error_flag;
    logic       rx_data_parity_error_flag;
    logic       rx_data_noise_flag;
    logic       rx_addr_frame_flag;
    logic       rx_standby_flag;
    logic       rx_active_flag;
    logic       tx_ready_flag;
    logic       tx_complete_flag;
    logic       rx_ready_flag;
    logic       rx_idle_flag;
    logic       rx_overflow_flag;
    logic       rx_framing_error_flag;
    logic       rx_parity_error_flag;
    logic       rx_noise_flag;
    logic       rx_lin_break_flag;
    logic       rx_match1_flag;
    logic       rx_match2_flag;
    logic       rx_edge_flag;

    assign sr  = {8'b0, rx_standby_flag, rx_active_flag, rx_fifo_empty_flag, rx_fifo_cnt_interface,
                  10'b0, tx_fifo_empty_flag, tx_fifo_cnt_interface};
    assign rdr = {18'b0, rx_addr_frame_flag, rx_data_noise_flag, rx_data_parity_error_flag,
                  rx_data_framing_error_flag, rx_data_preframe_empty_flag, rx_data_preframe_idle_flag,
                  rx_data_interface};
    assign isr = {5'b0, rx_edge_flag, rx_match2_flag, rx_match1_flag, rx_noise_flag, rx_lin_break_flag,
                  rx_framing_error_flag, rx_parity_error_flag, rx_fifo_underflow_flag, rx_overflow_flag,
                  rx_idle_flag, rx_ready_flag, 13'b0, tx_overflow_flag, tx_complete_flag, tx_ready_flag};
    assign icr = '0;

    always_comb begin
        if (read_xfer_valid) begin
            case (paddr_i[9:2])
                8'h00: prdata_o = cr1;
                8'h01: prdata_o = cr2;
                8'h02: prdata_o = fifocr1;
                8'h03: prdata_o = '0;
                8'h05: prdata_o = idlcr;
                8'h06: prdata_o = hfccr;
                8'h07: prdata_o = lincr;
                8'h08: prdata_o = mpccr;
                8'h09: prdata_o = phycr;
                8'h10: prdata_o = brr;
                8'h11: prdata_o = osrr;
                8'h20: prdata_o = sr;
                8'h30: prdata_o = '0;
                8'h31: prdata_o = rdr;
                8'h32: prdata_o = mdr1;
                8'h33: prdata_o = mdr2;
                8'h40: prdata_o = ier;
                8'h41: prdata_o = isr;
                8'h42: prdata_o = icr;
                default: prdata_o = '0;
            endcase
        end else begin
            prdata_o = '0;
        end
    end

    always_comb begin
        pready_o  = apb_access;
        pslverr_o = 1'b0;
    end

    assign swap_o = phycr[8];

    uart_core uart_core_inst (
        .clk_i                               (pclk_i),
        .rst_n_i                             (preset_n_i),
        .data_length_cfg_i                   (cr1[2:0]),
        .parity_en_i                         (cr1[3]),
        .parity_type_i                       (cr1[4]),
        .stop_length_cfg_i                   (cr1[5]),
        .msb_first_mode_en_i                 (phycr[24]),
        .oversample_ratio_i                  (osrr[5:0]),
        .baud_div_i                          (brr[16:4]),
        .rx_both_edge_en_i                   (phycr[16]),
        .rx_resync_en_i                      (phycr[17]),
        .idle_length_cfg_i                   (idlcr[3:1]),
        .rx_idle_type_i                      (idlcr[0]),
        .match_mode_cfg_i                    (mpccr[3:2]),
        .rx_match1_en_i                      (mpccr[0]),
        .rx_match2_en_i                      (mpccr[1]),
        .rx_match1_data_i                    (mdr1[7:0]),
        .rx_match2_data_i                    (mdr2[23:16]),
        .rx_mpc_idle_mode_i                  (mpccr[4]),
        .rx_mpc_force_standby_i              (mpccr_fstby_strobe),
        .rx_mpc_force_wakeup_i               (mpccr_fwk_strobe),
        .rx_lin_break_detect_en_i            (lincr[0]),
        .tx_en_i                             (cr2[0]),
        .rx_en_i                             (cr2[1]),
        .loopback_i                          (phycr[0]),
        .rx_loopback_source_i                (phycr[12]),
        .tx_direction_i                      (phycr[10]),
        .tx_txd_inv_en_i                     (phycr[9]),
        .rx_rxd_inv_en_i                     (phycr[11]),
        .tx_cts_en_i                         (hfccr[8]),
        .tx_cts_source_i                     (hfccr[9]),
        .tx_cts_sample_mode1_en_i            (hfccr[10]),
        .tx_rts_mode0_en_i                   (hfccr[2]),
        .rx_rts_mode1_en_i                   (hfccr[0]),
        .rx_rts_mode1_waterline_i            (hfccr[4:3]),
        .rts_polarity_i                      (hfccr[1]),
        .tx_txfifo_en_i                      (fifocr1[0]),
        .tx_txfifo_waterline_i               (fifocr1[5:1]),
        .tx_txfifo_flush_strobe_i            (fifocr2_txfifoflush_strobe),
        .rx_rxfifo_en_i                      (fifocr1[16]),
        .rx_rxfifo_waterline_i               (fifocr1[21:17]),
        .rx_rxfifo_flush_strobe_i            (fifocr2_rxfifoflush_strobe),
        .tx_data_i                           (pwdata_i[7:0]),
        .tx_data_interface_lin_break_i       (pstrb_i[1] && pwdata_i[9]),
        .tx_data_interface_addr_frame_i      (pstrb_i[1] && pwdata_i[10]),
        .tx_write_strobe_i                   (tdr_byte0_write_strobe),
        .rx_read_strobe_i                    (rdr_read_strobe),
        .tx_txfifo_overflow_clear_strobe_i   (icr_txfifoov_clear_strobe),
        .rx_idle_clear_strobe_i              (icr_idle_clear_strobe),
        .rx_overflow_clear_strobe_i          (icr_rxov_clear_strobe),
        .rx_rxfifo_underflow_clear_strobe_i  (icr_rxfifoud_clear_strobe),
        .rx_parity_error_clear_strobe_i      (icr_pe_clear_strobe),
        .rx_framing_error_clear_strobe_i     (icr_fe_clear_strobe),
        .rx_lin_break_clear_strobe_i         (icr_brk_clear_strobe),
        .rx_noise_clear_strobe_i             (icr_noise_clear_strobe),
        .rx_match1_clear_strobe_i            (icr_match1_clear_strobe),
        .rx_match2_clear_strobe_i            (icr_match2_clear_strobe),
        .rx_edge_clear_strobe_i              (icr_rxse_clear_strobe),
        .tx_interrupt_en_i                   (ier[0]),
        .tx_complete_interrupt_en_i          (ier[1]),
        .tx_overflow_interrupt_en_i          (ier[2]),
        .rx_interrupt_en_i                   (ier[16]),
        .rx_idle_interrupt_en_i              (ier[17]),
        .rx_overflow_interrupt_en_i          (ier[18]),
        .rx_underflow_interrupt_en_i         (ier[19]),
        .rx_parity_error_interrupt_en_i      (ier[20]),
        .rx_framing_error_interrupt_en_i     (ier[21]),
        .rx_lin_break_interrupt_en_i         (ier[22]),
        .rx_noise_interrupt_en_i             (ier[23]),
        .rx_match1_interrupt_en_i            (ier[24]),
        .rx_match2_interrupt_en_i            (ier[25]),
        .rx_edge_interrupt_en_i              (ier[26]),
        .tx_txfifo_cnt_o                     (tx_fifo_cnt_interface),
        .tx_overflow_flag_o                  (tx_overflow_flag),
        .tx_txfifo_empty_flag_o              (tx_fifo_empty_flag),
        .rx_rxfifo_cnt_o                     (rx_fifo_cnt_interface),
        .rx_rxfifo_underflow_flag_o          (rx_fifo_underflow_flag),
        .rx_rxfifo_empty_flag_o              (rx_fifo_empty_flag),
        .rx_data_o                           (rx_data_interface),
        .rx_data_interface_preframe_idle_o   (rx_data_preframe_idle_flag),
        .rx_data_interface_preframe_empty_o  (rx_data_preframe_empty_flag),
        .rx_data_interface_framing_error_o   (rx_data_framing_error_flag),
        .rx_data_interface_parity_error_o    (rx_data_parity_error_flag),
        .rx_data_interface_noise_o           (rx_data_noise_flag),
        .rx_data_interface_addr_frame_o      (rx_addr_frame_flag),
        .rx_standby_flag_o                   (rx_standby_flag),
        .rx_active_flag_o                    (rx_active_flag),
        .tx_ready_o                          (tx_ready_flag),
        .tx_transmit_complete_o              (tx_complete_flag),
        .rx_ready_o                          (rx_ready_flag),
        .rx_idle_flag_o                      (rx_idle_flag),
        .rx_overflow_flag_o                  (rx_overflow_flag),
        .rx_parity_error_flag_o              (rx_parity_error_flag),
        .rx_framing_error_flag_o             (rx_framing_error_flag),
        .rx_lin_break_flag_o                 (rx_lin_break_flag),
        .rx_noise_flag_o                     (rx_noise_flag),
        .rx_mpc_match1_flag_o                (rx_match1_flag),
        .rx_mpc_match2_flag_o                (rx_match2_flag),
        .rx_edge_flag_o                      (rx_edge_flag),
        .rx_irq_o                            (rx_irq_o),
        .tx_irq_o                            (tx_irq_o),
        .rxd_i                               (rxd_i),
        .txd_o                               (txd_o),
        .cts_n_i                             (cts_n_i),
        .rts_n_o                             (rts_n_o)
    );

endmodule
