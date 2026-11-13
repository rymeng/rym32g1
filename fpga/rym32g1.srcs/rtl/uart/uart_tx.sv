`timescale 1ns / 1ps

module uart_tx (
    input logic        clk_i,
    input logic        rst_n_i,
    /* TX module enable signals */
    input logic        tx_en_i,
    /* TX frame format control signals */
    input logic [2:0]  tx_data_length_cfg_i,
    input logic        tx_parity_en_i,
    input logic        tx_parity_type_i,
    input logic        tx_stop_length_cfg_i,
    /* TX baud rate control signals */
    input logic [5:0]  tx_oversample_ratio_i,
    input logic [12:0] tx_baud_div_i,
    /* TX data signals */
    input logic        tx_write_strobe_i,
    input logic [7:0]  tx_data_i,
    input logic        tx_data_interface_lin_break_i,
    input logic        tx_data_interface_addr_frame_i,
    /* TX FIFO control signals */
    input logic        tx_txfifo_en_i,
    input logic        tx_txfifo_flush_strobe_i,
    input logic [4:0]  tx_txfifo_waterline_i,
    /* TX IDLE control signals */
    input logic [2:0]  tx_idle_length_cfg_i,
    /* TX hardware flow control signals */
    input logic        tx_cts_en_i,
    input logic        tx_cts_i,
    input logic        tx_cts_sample_mode1_en_i,
    /* TX multi-processor communication control signals */
    input logic [1:0]  tx_match_mode_cfg_i,
    /* TX enhanced physical layer control signals */
    input logic        tx_msb_first_mode_en_i,
    input logic        tx_txd_inv_en_i,
    /* TX state flag clear signals */
    input logic        tx_txfifo_overflow_clear_strobe_i,
    /* TX common state signals */
    output logic         tx_ready_o,
    output logic         tx_transmit_complete_o,
    /* TX FIFO state signals */
    output logic [4:0]  tx_txfifo_cnt_o,
    output logic        tx_txfifo_empty_flag_o,
    /* TX error state signals */
    output logic        tx_overflow_flag_o,
    /* TX IO signals */
    output logic        tx_txd_o,
    output logic         tx_rts_mode0_o
);

    /* Multi-processor communication protocol type code */
    localparam [1:0] MPC_PROTOCOL_NULL       = 2'b00;
    localparam [1:0] MPC_PROTOCOL_IDLE       = 2'b01;
    localparam [1:0] MPC_PROTOCOL_ADDR_BIT   = 2'b10;
    localparam [1:0] MPC_PROTOCOL_FIRST_LAST = 2'b11;

    /* Decode the multi-processor communication protocol from MATCHMODE */
    logic mpc_addr_bit_protocol;
    logic mpc_idle_protocol;

    assign mpc_addr_bit_protocol = (tx_match_mode_cfg_i == MPC_PROTOCOL_ADDR_BIT);
    assign mpc_idle_protocol = (tx_match_mode_cfg_i == MPC_PROTOCOL_IDLE);

    /* FSM state code */
    localparam [3:0] IDLE             = 4'b0001;
    localparam [3:0] TX_PREFRAME_IDLE = 4'b0010;
    localparam [3:0] TX_LIN_BREAK     = 4'b0100;
    localparam [3:0] TX_DATA_FRAME    = 4'b1000;

    /* State registers */
    logic [3:0] state;
    logic [3:0] state_next;

    /* Assembler */
    logic [12:0] assembler;
    logic [4:0]  assembler_length;
    logic [4:0]  assembler_bit_cnt;
    logic        assembler_pending;

    /* Pre-frame IDLE counter */
    logic [11:0] frame_preframe_idle_bit_cnt;

    /* TXD signal */
    logic txd;

    /* Generate tick signals */
    logic  restart_baud_gen;
    logic bit_tick;

    uart_baud_gen uart_baud_gen_inst (
        .clk_i                    (clk_i),
        .rst_n_i                  (rst_n_i),
        .oversample_ratio_i       (tx_oversample_ratio_i),
        .baud_divider_i           (tx_baud_div_i),
        .restart_i                (restart_baud_gen),
        .enhance_sample_tick_en_i (1'b0),
        .standard_sample_tick_o   (),
        .enhance_sample_tick_o    (),
        .bit_tick_o               (bit_tick),
        .sample_points_num_per_bit()
    );

    /* TX Buffer */
    logic       txbuf_cnt;
    logic [7:0] txbuf_data;
    logic       txbuf_lin_break_flag;
    logic       txbuf_addr_frame_flag;

    /* TXFIFO */
    logic [4:0] txfifo_cnt;
    logic [3:0] txfifo_reading_pointer;
    logic [3:0] txfifo_writing_pointer;
    logic [7:0] txfifo_data            [0:15];
    logic       txfifo_lin_break_flag  [0:15];
    logic       txfifo_addr_frame_flag [0:15];

    /* TX B/F state */
    logic [7:0] tx_data;
    logic       tx_lin_break;
    logic       tx_addr_frame;
    logic       tx_preframe_idle;
    logic       tx_empty;
    logic       tx_pending;
    logic       tx_full;

    always_comb begin
        if (tx_txfifo_en_i) begin
            tx_data = txfifo_data[txfifo_reading_pointer];
            tx_lin_break = txfifo_lin_break_flag[txfifo_reading_pointer];
            tx_addr_frame = txfifo_addr_frame_flag[txfifo_reading_pointer];
            tx_empty = (txfifo_cnt == 5'd0) ? 1'b1 : 1'b0;
            tx_pending = (txfifo_cnt > 5'd0) ? 1'b1 : 1'b0;
            tx_full = (txfifo_cnt >= 5'd16) ? 1'b1 : 1'b0;
        end else begin
            tx_data = txbuf_data;
            tx_lin_break = txbuf_lin_break_flag;
            tx_addr_frame = txbuf_addr_frame_flag;
            tx_empty = (txbuf_cnt == 1'b0) ? 1'b1 : 1'b0;
            tx_pending = (txbuf_cnt > 1'b0) ? 1'b1 : 1'b0;
            tx_full = (txbuf_cnt == 1'b1) ? 1'b1 : 1'b0;
        end

        tx_preframe_idle = mpc_idle_protocol & tx_addr_frame & !tx_lin_break;
    end

    /* Generate frame format signals */
    logic [3:0]  data_length;
    logic [7:0]  data_mask;
    logic [4:0]  frame_length;

    assign data_length = {1'b0, tx_data_length_cfg_i} + 4'd1;
    assign data_mask = 8'hFF >> (4'd8 - data_length);
    assign frame_length = 5'd2 + {1'b0, data_length} + mpc_addr_bit_protocol + tx_parity_en_i + tx_stop_length_cfg_i;

    /* Generate IDLE format signal */
    logic [11:0] preframe_idle_length;

    assign preframe_idle_length = ({7'b0, frame_length} << tx_idle_length_cfg_i) + 12'd2;

    /* Generate LIN break format signal */
    logic [4:0]  lin_break_length;

    assign lin_break_length = 5'd13;

    /* Reorder the data bits when MSB first is selected */
    logic [7:0] data_rev;
    logic  [7:0] data_ordered;

    assign data_rev = {tx_data[0], tx_data[1], tx_data[2], tx_data[3], tx_data[4], tx_data[5], tx_data[6], tx_data[7]};

    always_comb begin
        if (tx_msb_first_mode_en_i) begin
            data_ordered = data_rev >> (4'd8 - data_length);
        end else begin
            data_ordered = tx_data;
        end
    end

    /* Compute the parity code */
    logic parity_code;

    assign parity_code = ^(tx_data & data_mask) ^ (mpc_addr_bit_protocol & tx_addr_frame) ^ tx_parity_type_i;

    /* Generate frame */
    logic [12:0] frame_raw;

    always_comb begin
        frame_raw = 13'b0;
        frame_raw[0] = 1'b0;
        frame_raw[8:1] = data_ordered & data_mask;
        if (mpc_addr_bit_protocol) begin
            frame_raw[1 + data_length] = tx_addr_frame;
        end
        if (tx_parity_en_i) begin
            frame_raw[1 + data_length + mpc_addr_bit_protocol] = parity_code;
        end
        frame_raw[1 + data_length + mpc_addr_bit_protocol + tx_parity_en_i] = 1'b1;
        if (tx_stop_length_cfg_i) begin
            frame_raw[2 + data_length + mpc_addr_bit_protocol + tx_parity_en_i] = 1'b1;
        end
    end

    /* Get the CTS raw signal */
    logic cts_raw;

    assign cts_raw = tx_cts_i;

    /* Generate the CTS latched (in IDLE state) signal */
    logic cts_latched;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            cts_latched <= 1'b1;
        end else begin
            if (state == IDLE) begin
                cts_latched <= cts_raw;
            end
        end
    end

    /* Output CTS */
    logic cts;

    always_comb begin
        if (!tx_cts_en_i) begin
            cts = 1'b1;
        end else if (tx_cts_sample_mode1_en_i) begin
            cts = cts_latched;
        end else begin
            cts = cts_raw;
        end
    end

    /* Generate TX buffer / RXFIFO operation signals */
    /* Get TX buffer / RXFIFO state */
    logic  load;
    logic overflow;

    always_comb begin
        load = 1'b0;

        case (state)
            IDLE: begin
                if (tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                    load = 1'b1;
                end
            end

            TX_PREFRAME_IDLE: begin
                if (bit_tick & (frame_preframe_idle_bit_cnt == 12'd1) & tx_en_i & cts & tx_pending) begin
                    load = 1'b1;
                end
            end

            TX_LIN_BREAK: begin
                if (bit_tick & (assembler_bit_cnt == assembler_length - 5'd1) & tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                    load = 1'b1;
                end
            end

            TX_DATA_FRAME: begin
                if (bit_tick & (assembler_bit_cnt == assembler_length - 5'd1) & tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                    load = 1'b1;
                end
            end
        endcase
    end

    assign overflow = tx_write_strobe_i & tx_full & !load;

    /* Store TX buffer */
    /* Refresh TX buffer counter */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            txbuf_cnt <= 1'b0;
            txbuf_data <= 8'h00;
            txbuf_lin_break_flag <= 1'b0;
            txbuf_addr_frame_flag <= 1'b0;
        end else begin
            if (!tx_txfifo_en_i) begin
                if (tx_write_strobe_i) begin
                    txbuf_data <= tx_data_i;
                    txbuf_lin_break_flag <= tx_data_interface_lin_break_i;
                    txbuf_addr_frame_flag <= tx_data_interface_addr_frame_i;
                    txbuf_cnt <= 1'b1;
                end else if (load) begin
                    txbuf_cnt <= 1'b0;
                end
            end else begin
                txbuf_cnt <= 1'b0;
            end
        end
    end

    /* Refresh TXFIFO counter & pointer */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            txfifo_writing_pointer <= 4'd0;
            txfifo_reading_pointer <= 4'd0;
            txfifo_cnt <= 5'd0;
        end else begin
            if (tx_txfifo_flush_strobe_i) begin
                txfifo_writing_pointer <= 4'd0;
                txfifo_reading_pointer <= 4'd0;
                txfifo_cnt <= 5'd0;
            end else if (tx_txfifo_en_i) begin
                if (tx_write_strobe_i & !overflow) begin
                    txfifo_writing_pointer <= txfifo_writing_pointer + 4'd1;
                end

                if (load) begin
                    txfifo_reading_pointer <= txfifo_reading_pointer + 4'd1;
                end

                txfifo_cnt <= txfifo_cnt + (tx_write_strobe_i & !overflow) - load;
            end else begin
                txfifo_cnt <= 5'd0;
            end
        end
    end

    /* Store TXFIFO */
    logic [3:0] txfifo_writing_pointer_calib;

    assign txfifo_writing_pointer_calib = overflow ? (txfifo_writing_pointer - 4'd1) : txfifo_writing_pointer;

    always_ff @ (posedge clk_i) begin
        if (tx_txfifo_en_i & tx_write_strobe_i) begin
            txfifo_data[txfifo_writing_pointer_calib] <= tx_data_i;
            txfifo_lin_break_flag[txfifo_writing_pointer_calib] <= tx_data_interface_lin_break_i;
            txfifo_addr_frame_flag[txfifo_writing_pointer_calib] <= tx_data_interface_addr_frame_i;
        end
    end

    /* Generate & clear TXFIFO overflow flag */
    logic  txfifo_overflow_flag;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            txfifo_overflow_flag <= 1'b0;
        end else begin
            if (tx_txfifo_en_i & !tx_txfifo_flush_strobe_i) begin
                if (tx_txfifo_overflow_clear_strobe_i) begin
                    txfifo_overflow_flag <= 1'b0;
                end

                if (overflow) begin
                    txfifo_overflow_flag <= 1'b1;
                end
            end
        end
    end

    /* FSM */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    always_comb begin
        state_next = state;

        case (state)
            IDLE: begin
                if (tx_en_i & cts & tx_pending) begin
                    if (tx_preframe_idle) begin
                        state_next = TX_PREFRAME_IDLE;
                    end else if (tx_lin_break) begin
                        state_next = TX_LIN_BREAK;
                    end else begin
                        state_next = TX_DATA_FRAME;
                    end
                end
            end

            TX_PREFRAME_IDLE: begin
                if (tx_txfifo_flush_strobe_i & tx_txfifo_en_i) begin
                    state_next = IDLE;
                end else if (bit_tick & (frame_preframe_idle_bit_cnt == 12'd1)) begin
                    if (tx_en_i & cts & tx_pending) begin
                        state_next = TX_DATA_FRAME;
                    end else begin
                        state_next = IDLE;
                    end
                end
            end

            TX_LIN_BREAK: begin
                if (bit_tick & (assembler_bit_cnt == assembler_length - 5'd1)) begin
                    if (tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                        state_next = tx_lin_break ? TX_LIN_BREAK : TX_DATA_FRAME;
                    end else begin
                        state_next = IDLE;
                    end
                end
            end

            TX_DATA_FRAME: begin
                if (bit_tick & (assembler_bit_cnt == assembler_length - 5'd1)) begin
                    if (tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                        state_next = tx_lin_break ? TX_LIN_BREAK : TX_DATA_FRAME;
                    end else begin
                        state_next = IDLE;
                    end
                end
            end
        endcase
    end

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            assembler <= 13'h000;
            assembler_length <= 5'd0;
            assembler_bit_cnt <= 5'd0;
            frame_preframe_idle_bit_cnt <= 12'd0;
            assembler_pending <= 1'b0;
            restart_baud_gen <= 1'b0;
            txd <= 1'b1;
        end else begin
            restart_baud_gen <= 1'b0;

            case (state)
                IDLE: begin
                    if (tx_en_i & cts & tx_pending) begin
                        if (tx_preframe_idle) begin
                            frame_preframe_idle_bit_cnt <= preframe_idle_length;
                        end else if (tx_lin_break) begin
                            assembler_length <= lin_break_length;
                            assembler_bit_cnt <= 5'd0;
                            assembler_pending <= 1'b1;
                            restart_baud_gen <= 1'b1;
                        end else begin
                            assembler <= frame_raw;
                            assembler_length <= frame_length;
                            assembler_bit_cnt <= 5'd0;
                            assembler_pending <= 1'b1;
                            restart_baud_gen <= 1'b1;
                        end
                    end
                    txd <= 1'b1;
                end

                TX_PREFRAME_IDLE: begin
                    txd <= 1'b1;
                    if (tx_txfifo_en_i & tx_txfifo_flush_strobe_i) begin
                        frame_preframe_idle_bit_cnt <= 12'd0;
                    end else if (bit_tick) begin
                        frame_preframe_idle_bit_cnt <= frame_preframe_idle_bit_cnt - 12'd1;
                        if ((frame_preframe_idle_bit_cnt == 12'd1) & tx_en_i & cts & tx_pending) begin
                            assembler <= frame_raw;
                            assembler_length <= frame_length;
                            assembler_bit_cnt <= 5'd0;
                            assembler_pending <= 1'b1;
                            restart_baud_gen <= 1'b1;
                        end
                    end
                end

                TX_LIN_BREAK: begin
                    if (assembler_pending) begin
                        assembler_pending <= 1'b0;
                        txd <= 1'b0;
                    end else if (bit_tick) begin
                        if (assembler_bit_cnt == assembler_length - 5'd1) begin
                            if (tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                                if (tx_lin_break) begin
                                    assembler <= 13'h000;
                                    assembler_length <= lin_break_length;
                                end else begin
                                    assembler <= frame_raw;
                                    assembler_length <= frame_length;
                                end
                                assembler_bit_cnt <= 5'd0;
                                txd <= 1'b0;
                            end else begin
                                txd <= 1'b1;
                            end
                        end else begin
                            assembler_bit_cnt <= assembler_bit_cnt + 5'd1;
                            txd <= 1'b0;
                        end
                    end
                end

                TX_DATA_FRAME: begin
                    if (assembler_pending) begin
                        assembler_pending <= 1'b0;
                        txd <= assembler[0];
                    end else if (bit_tick) begin
                        if (assembler_bit_cnt == assembler_length - 5'd1) begin
                            if (tx_en_i & cts & tx_pending & !tx_preframe_idle) begin
                                if (tx_lin_break) begin
                                    assembler <= 13'h000;
                                    assembler_length <= lin_break_length;
                                end else begin
                                    assembler <= frame_raw;
                                    assembler_length <= frame_length;
                                end
                                assembler_bit_cnt <= 5'd0;
                                txd <= 1'b0;
                            end else begin
                                txd <= 1'b1;
                            end
                        end else begin
                            assembler_bit_cnt <= assembler_bit_cnt + 5'd1;
                            txd <= assembler[assembler_bit_cnt + 5'd1];
                        end
                    end
                end

                default: begin
                    txd <= 1'b1;
                end
            endcase
        end
    end

    /* Output TX common flags */
    always_comb begin
        if (tx_txfifo_en_i) begin
            tx_ready_o = (txfifo_cnt <= tx_txfifo_waterline_i);
        end else begin
            tx_ready_o = !txbuf_cnt;
        end
    end

    always_comb begin
        if (state == IDLE) begin
            if (tx_empty) begin
                tx_transmit_complete_o = 1'b1;
            end else begin
                tx_transmit_complete_o = 1'b0;
            end
        end else begin
            tx_transmit_complete_o = 1'b0;
        end
    end

    /* Output TXFIFO state */
    assign tx_txfifo_empty_flag_o = tx_empty;
    assign tx_txfifo_cnt_o = txfifo_cnt;

    /* Output error state */
    assign tx_overflow_flag_o = txfifo_overflow_flag;

    /* Output TXD */
    assign tx_txd_o = txd ^ tx_txd_inv_en_i;

    /* Output RTS (mode 0) */
    always_comb begin
        if (state == IDLE) begin
            if (tx_en_i & tx_pending) begin
                tx_rts_mode0_o = 1'b1;
            end else begin
                tx_rts_mode0_o = 1'b0;
            end
        end else begin
            tx_rts_mode0_o = 1'b1;
        end
    end

endmodule

