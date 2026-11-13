`timescale 1ns / 1ps

module uart_core (
    /* Clock and reset */
    input logic        clk_i,
    input logic        rst_n_i,
    /* Frame format */
    input logic [2:0]  data_length_cfg_i,
    input logic        parity_en_i,
    input logic        parity_type_i,
    input logic        stop_length_cfg_i,
    input logic        msb_first_mode_en_i,
    /* Baud rate */
    input logic [5:0]  oversample_ratio_i,
    input logic [12:0] baud_div_i,
    input logic        rx_both_edge_en_i,
    input logic        rx_resync_en_i,
    /* IDLE */
    input logic [2:0]  idle_length_cfg_i,
    input logic        rx_idle_type_i,    
    /* Multi-processor protocol communication */
    input logic [1:0]  match_mode_cfg_i,
    input logic        rx_match1_en_i,
    input logic        rx_match2_en_i,
    input logic [7:0]  rx_match1_data_i,
    input logic [7:0]  rx_match2_data_i,
    input logic        rx_mpc_idle_mode_i,
    input logic        rx_mpc_force_standby_i,
    input logic        rx_mpc_force_wakeup_i,
    /* LIN break detection */
    input logic        rx_lin_break_detect_en_i,
    /* TX sub-system control */
    input logic        tx_en_i,
    /* RX sub-system control */
    input logic        rx_en_i,
    /* Loop-back & single-wire mode control */
    input logic        loopback_i,
    input logic        rx_loopback_source_i,
    /* TXD control */
    input logic        tx_direction_i,
    input logic        tx_txd_inv_en_i,
    /* RXD control */
    input logic        rx_rxd_inv_en_i,
    /* CTS control */
    input logic        tx_cts_en_i,
    input logic        tx_cts_source_i,
    input logic        tx_cts_sample_mode1_en_i,
    /* RTS control */
    input logic        tx_rts_mode0_en_i,
    input logic        rx_rts_mode1_en_i,
    input logic [1:0]  rx_rts_mode1_waterline_i,
    input logic        rts_polarity_i,
    /* TXFIFO control */
    input logic        tx_txfifo_en_i,
    input logic [4:0]  tx_txfifo_waterline_i,
    input logic        tx_txfifo_flush_strobe_i,
    /* RXFIFO control */
    input logic        rx_rxfifo_en_i,
    input logic [4:0]  rx_rxfifo_waterline_i,
    input logic        rx_rxfifo_flush_strobe_i,
    /* TX write */
    input logic [7:0]  tx_data_i,
    input logic        tx_data_interface_lin_break_i,
    input logic        tx_data_interface_addr_frame_i,
    input logic        tx_write_strobe_i,
    /* RX read */
    input logic        rx_read_strobe_i,
    /* Clear */
    input logic        tx_txfifo_overflow_clear_strobe_i,
    input logic        rx_idle_clear_strobe_i,
    input logic        rx_overflow_clear_strobe_i,
    input logic        rx_rxfifo_underflow_clear_strobe_i,
    input logic        rx_parity_error_clear_strobe_i,
    input logic        rx_framing_error_clear_strobe_i,
    input logic        rx_lin_break_clear_strobe_i,
    input logic        rx_noise_clear_strobe_i,
    input logic        rx_match1_clear_strobe_i,
    input logic        rx_match2_clear_strobe_i,
    input logic        rx_edge_clear_strobe_i,
    /* Interrupt enables */
    input logic        tx_interrupt_en_i,
    input logic        tx_complete_interrupt_en_i,
    input logic        tx_overflow_interrupt_en_i,
    input logic        rx_interrupt_en_i,
    input logic        rx_idle_interrupt_en_i,
    input logic        rx_overflow_interrupt_en_i,
    input logic        rx_underflow_interrupt_en_i,
    input logic        rx_parity_error_interrupt_en_i,
    input logic        rx_framing_error_interrupt_en_i,
    input logic        rx_lin_break_interrupt_en_i,
    input logic        rx_noise_interrupt_en_i,
    input logic        rx_match1_interrupt_en_i,
    input logic        rx_match2_interrupt_en_i,
    input logic        rx_edge_interrupt_en_i,
    /* TXFIFO state (include TX buffer state) */
    output logic [4:0]  tx_txfifo_cnt_o,
    output logic        tx_overflow_flag_o,
    output logic        tx_txfifo_empty_flag_o,
    /* RXFIFO state */
    output logic [4:0]  rx_rxfifo_cnt_o,
    output logic        rx_rxfifo_underflow_flag_o,
    output logic        rx_rxfifo_empty_flag_o,
    /* RX interface */
    output logic [7:0]  rx_data_o,
    output logic        rx_data_interface_preframe_idle_o,
    output logic        rx_data_interface_preframe_empty_o,
    output logic        rx_data_interface_framing_error_o,
    output logic        rx_data_interface_parity_error_o,
    output logic        rx_data_interface_noise_o,
    output logic        rx_data_interface_addr_frame_o,
    /* RX multi-processor communication state */
    output logic        rx_standby_flag_o,
    /* Status flags */
    output logic        rx_active_flag_o,
    output logic        tx_ready_o,
    output logic        tx_transmit_complete_o,
    output logic        rx_ready_o,
    output logic        rx_idle_flag_o,
    output logic        rx_overflow_flag_o,
    output logic        rx_parity_error_flag_o,
    output logic        rx_framing_error_flag_o,
    output logic        rx_lin_break_flag_o,
    output logic        rx_noise_flag_o,
    output logic        rx_mpc_match1_flag_o,
    output logic        rx_mpc_match2_flag_o,
    output logic        rx_edge_flag_o,
    /* Interrupt requests */
    output logic        rx_irq_o,
    output logic        tx_irq_o,
    /* Pins */
    input logic        rxd_i,
    output logic        txd_o,
    input logic        cts_n_i,
    output logic        rts_n_o
);
    /* TX sub-system */
    logic       tx_txd;
    logic       tx_ready;
    logic       tx_transmit_complete;
    logic       tx_rts_mode0;
    logic       tx_cts;
    logic [4:0] tx_txfifo_cnt;
    logic       tx_overflow_flag;
    logic       tx_txfifo_empty_flag;

    uart_tx uart_tx_inst (
        .clk_i                              (clk_i),
        .rst_n_i                            (rst_n_i),
        .tx_en_i                            (tx_en_i),
        .tx_data_length_cfg_i               (data_length_cfg_i),
        .tx_parity_en_i                     (parity_en_i),
        .tx_parity_type_i                   (parity_type_i),
        .tx_stop_length_cfg_i               (stop_length_cfg_i),
        .tx_oversample_ratio_i              (oversample_ratio_i),
        .tx_baud_div_i                      (baud_div_i),
        .tx_write_strobe_i                  (tx_write_strobe_i),
        .tx_data_i                          (tx_data_i),
        .tx_data_interface_lin_break_i      (tx_data_interface_lin_break_i),
        .tx_data_interface_addr_frame_i     (tx_data_interface_addr_frame_i),
        .tx_txfifo_en_i                     (tx_txfifo_en_i),
        .tx_txfifo_flush_strobe_i           (tx_txfifo_flush_strobe_i),
        .tx_txfifo_waterline_i              (tx_txfifo_waterline_i),
        .tx_idle_length_cfg_i               (idle_length_cfg_i),
        .tx_cts_en_i                        (tx_cts_en_i),
        .tx_cts_i                           (tx_cts),
        .tx_cts_sample_mode1_en_i           (tx_cts_sample_mode1_en_i),
        .tx_match_mode_cfg_i                (match_mode_cfg_i),
        .tx_msb_first_mode_en_i             (msb_first_mode_en_i),
        .tx_txd_inv_en_i                    (tx_txd_inv_en_i),
        .tx_txfifo_overflow_clear_strobe_i  (tx_txfifo_overflow_clear_strobe_i),
        .tx_ready_o                         (tx_ready),
        .tx_transmit_complete_o             (tx_transmit_complete),
        .tx_txfifo_cnt_o                    (tx_txfifo_cnt),
        .tx_txfifo_empty_flag_o             (tx_txfifo_empty_flag),
        .tx_overflow_flag_o                 (tx_overflow_flag),
        .tx_txd_o                           (tx_txd),
        .tx_rts_mode0_o                     (tx_rts_mode0)
    );

    /* RX sub-system */
    logic        rxd;
    logic [7:0] rx_data;
    logic       rx_data_interface_preframe_idle;
    logic       rx_data_interface_framing_error;
    logic       rx_data_interface_parity_error;
    logic       rx_data_interface_noise;
    logic       rx_ready;
    logic       rx_idle_flag;
    logic       rx_overflow_flag;
    logic       rx_noise_flag;
    logic       rx_framing_error_flag;
    logic       rx_parity_error_flag;
    logic       rx_mpc_match1_flag;
    logic       rx_mpc_match2_flag;
    logic       rx_active_flag;
    logic       rx_edge_flag;
    logic       rx_lin_break_flag;
    logic       rx_rts_mode1;
    logic       rx_data_interface_addr_frame;
    logic       rx_standby_flag;
    logic [4:0] rx_rxfifo_cnt;
    logic       rx_rxfifo_underflow_flag;
    logic       rx_rxfifo_empty_flag;
    logic       rx_data_interface_preframe_empty;

    always_comb begin
        if (!loopback_i) begin
            rxd = rxd_i;
        end else if (rx_loopback_source_i) begin
            rxd = rxd_i;
        end else begin
            rxd = tx_txd;
        end
    end

    uart_rx uart_rx_inst (
        .clk_i                               (clk_i),
        .rst_n_i                             (rst_n_i),
        .rx_en_i                             (rx_en_i),
        .rx_data_length_cfg_i                (data_length_cfg_i),
        .rx_parity_en_i                      (parity_en_i),
        .rx_parity_type_i                    (parity_type_i),
        .rx_stop_length_cfg_i                (stop_length_cfg_i),
        .rx_oversample_ratio_i               (oversample_ratio_i),
        .rx_baud_div_i                       (baud_div_i),
        .rx_both_edge_en_i                   (rx_both_edge_en_i),
        .rx_resync_en_i                      (rx_resync_en_i),
        .rx_read_strobe_i                    (rx_read_strobe_i),
        .rx_rxfifo_en_i                      (rx_rxfifo_en_i),
        .rx_rxfifo_flush_strobe_i            (rx_rxfifo_flush_strobe_i),
        .rx_rxfifo_waterline_i               (rx_rxfifo_waterline_i),
        .rx_rxfifo_underflow_clear_strobe_i  (rx_rxfifo_underflow_clear_strobe_i),
        .rx_idle_type_i                      (rx_idle_type_i),
        .rx_idle_length_cfg_i                (idle_length_cfg_i),
        .rx_rts_mode1_en_i                   (rx_rts_mode1_en_i),
        .rx_rts_mode1_waterline_i            (rx_rts_mode1_waterline_i),
        .rx_mpc_idle_mode_i                  (rx_mpc_idle_mode_i),
        .rx_match_mode_cfg_i                 (match_mode_cfg_i),
        .rx_match1_en_i                      (rx_match1_en_i),
        .rx_match2_en_i                      (rx_match2_en_i),
        .rx_match1_data_i                    (rx_match1_data_i),
        .rx_match2_data_i                    (rx_match2_data_i),
        .rx_mpc_force_standby_i              (rx_mpc_force_standby_i),
        .rx_mpc_force_wakeup_i               (rx_mpc_force_wakeup_i),
        .rx_msb_first_mode_en_i              (msb_first_mode_en_i),
        .rx_rxd_inv_en_i                     (rx_rxd_inv_en_i),
        .rx_lin_break_detect_en_i            (rx_lin_break_detect_en_i),
        .rx_lin_break_clear_strobe_i         (rx_lin_break_clear_strobe_i),
        .rx_edge_clear_strobe_i              (rx_edge_clear_strobe_i),
        .rx_idle_clear_strobe_i              (rx_idle_clear_strobe_i),
        .rx_overflow_clear_strobe_i          (rx_overflow_clear_strobe_i),
        .rx_noise_clear_strobe_i             (rx_noise_clear_strobe_i),
        .rx_framing_error_clear_strobe_i     (rx_framing_error_clear_strobe_i),
        .rx_parity_error_clear_strobe_i      (rx_parity_error_clear_strobe_i),
        .rx_match1_clear_strobe_i            (rx_match1_clear_strobe_i),
        .rx_match2_clear_strobe_i            (rx_match2_clear_strobe_i),
        .rx_data_o                           (rx_data),
        .rx_data_interface_preframe_idle_o   (rx_data_interface_preframe_idle),
        .rx_data_interface_preframe_empty_o  (rx_data_interface_preframe_empty),
        .rx_data_interface_framing_error_o   (rx_data_interface_framing_error),
        .rx_data_interface_parity_error_o    (rx_data_interface_parity_error),
        .rx_data_interface_noise_o           (rx_data_interface_noise),
        .rx_data_interface_addr_frame_o      (rx_data_interface_addr_frame),
        .rx_ready_o                          (rx_ready),
        .rx_active_flag_o                    (rx_active_flag),
        .rx_edge_flag_o                      (rx_edge_flag),
        .rx_rxfifo_cnt_o                     (rx_rxfifo_cnt),
        .rx_rxfifo_empty_flag_o              (rx_rxfifo_empty_flag),
        .rx_idle_flag_o                      (rx_idle_flag),
        .rx_standby_flag_o                   (rx_standby_flag),
        .rx_mpc_match1_flag_o                (rx_mpc_match1_flag),
        .rx_mpc_match2_flag_o                (rx_mpc_match2_flag),
        .rx_overflow_flag_o                  (rx_overflow_flag),
        .rx_rxfifo_underflow_flag_o          (rx_rxfifo_underflow_flag),
        .rx_noise_flag_o                     (rx_noise_flag),
        .rx_framing_error_flag_o             (rx_framing_error_flag),
        .rx_parity_error_flag_o              (rx_parity_error_flag),
        .rx_lin_break_flag_o                 (rx_lin_break_flag),
        .rx_rxd_i                            (rxd),
        .rx_rts_mode1_o                      (rx_rts_mode1)
    );

    /* Select the clear-to-send source; CTSSRC has no effect in MATCHMODE=00 */
    assign tx_cts = (tx_cts_source_i & (match_mode_cfg_i != 2'b00)) ? !rx_standby_flag : !cts_n_i;

    /* Combine transmit and receive RTS requests */
    logic rts_assert;

    assign rts_assert = (tx_rts_mode0_en_i & tx_rts_mode0) | (rx_rts_mode1_en_i & rx_rts_mode1);
    assign rts_n_o = rts_polarity_i ? rts_assert : !rts_assert;

    /* Drive the transmit data output */
    assign txd_o = (loopback_i & rx_loopback_source_i & !tx_direction_i) ? 1'b1 : tx_txd;

    /* Aggregate receive interrupt requests */
    logic rx_irq;

    always_comb begin
        if (rx_interrupt_en_i & rx_ready) begin
            rx_irq = 1'b1;
        end else if (rx_idle_interrupt_en_i & rx_idle_flag) begin
            rx_irq = 1'b1;
        end else if (rx_overflow_interrupt_en_i & rx_overflow_flag) begin
            rx_irq = 1'b1;
        end else if (rx_underflow_interrupt_en_i & rx_rxfifo_underflow_flag) begin
            rx_irq = 1'b1;
        end else if (rx_parity_error_interrupt_en_i & rx_parity_error_flag) begin
            rx_irq = 1'b1;
        end else if (rx_framing_error_interrupt_en_i & rx_framing_error_flag) begin
            rx_irq = 1'b1;
        end else if (rx_lin_break_interrupt_en_i & rx_lin_break_flag) begin
            rx_irq = 1'b1;
        end else if (rx_noise_interrupt_en_i & rx_noise_flag) begin
            rx_irq = 1'b1;
        end else if (rx_match1_interrupt_en_i & rx_mpc_match1_flag) begin
            rx_irq = 1'b1;
        end else if (rx_match2_interrupt_en_i & rx_mpc_match2_flag) begin
            rx_irq = 1'b1;
        end else if (rx_edge_interrupt_en_i & rx_edge_flag) begin
            rx_irq = 1'b1;
        end else begin
            rx_irq = 1'b0;
        end
    end

    assign rx_irq_o = rx_irq;

    /* Aggregate transmit interrupt requests */
    logic tx_irq;

    always_comb begin
        if (tx_interrupt_en_i & tx_ready) begin
            tx_irq = 1'b1;
        end else if (tx_complete_interrupt_en_i & tx_transmit_complete) begin
            tx_irq = 1'b1;
        end else if (tx_overflow_interrupt_en_i & tx_overflow_flag) begin
            tx_irq = 1'b1;
        end else begin
            tx_irq = 1'b0;
        end
    end

    assign tx_irq_o = tx_irq;


    /* Output FIFO count and flag signals */
    assign tx_txfifo_cnt_o = tx_txfifo_cnt;
    assign tx_overflow_flag_o = tx_overflow_flag;
    assign tx_txfifo_empty_flag_o = tx_txfifo_empty_flag;
    assign rx_rxfifo_cnt_o = rx_rxfifo_cnt;
    assign rx_rxfifo_underflow_flag_o = rx_rxfifo_underflow_flag;
    assign rx_rxfifo_empty_flag_o = rx_rxfifo_empty_flag;
    assign rx_data_interface_preframe_empty_o = rx_data_interface_preframe_empty;

    /* Output receive data path */
    assign rx_data_o = rx_data;
    assign rx_data_interface_preframe_idle_o = rx_data_interface_preframe_idle;
    assign rx_data_interface_framing_error_o = rx_data_interface_framing_error;
    assign rx_data_interface_parity_error_o = rx_data_interface_parity_error;
    assign rx_data_interface_noise_o = rx_data_interface_noise;
    assign rx_data_interface_addr_frame_o = rx_data_interface_addr_frame;
    assign rx_standby_flag_o = rx_standby_flag;

    /* Output status flags */
    assign rx_lin_break_flag_o = rx_lin_break_flag;
    assign rx_edge_flag_o = rx_edge_flag;
    assign rx_active_flag_o = rx_active_flag;
    assign tx_ready_o = tx_ready;
    assign tx_transmit_complete_o = tx_transmit_complete;
    assign rx_ready_o = rx_ready;
    assign rx_idle_flag_o = rx_idle_flag;
    assign rx_overflow_flag_o = rx_overflow_flag;
    assign rx_noise_flag_o = rx_noise_flag;
    assign rx_framing_error_flag_o = rx_framing_error_flag;
    assign rx_parity_error_flag_o = rx_parity_error_flag;
    assign rx_mpc_match1_flag_o = rx_mpc_match1_flag;
    assign rx_mpc_match2_flag_o = rx_mpc_match2_flag;

endmodule
