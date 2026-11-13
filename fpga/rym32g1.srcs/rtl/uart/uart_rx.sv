`timescale 1ns / 1ps

module uart_rx (
    input logic        clk_i,
    input logic        rst_n_i,
    /* RX module enable signals */
    input logic        rx_en_i,
    /* RX frame format control signals */
    input logic [2:0]  rx_data_length_cfg_i,
    input logic        rx_parity_en_i,
    input logic        rx_parity_type_i,
    input logic        rx_stop_length_cfg_i,
    /* RX baud rate control signals */
    input logic [5:0]  rx_oversample_ratio_i,
    input logic [12:0] rx_baud_div_i,
    input logic        rx_both_edge_en_i,
    input logic        rx_resync_en_i,
    /* RX data signals */
    input logic        rx_read_strobe_i,
    /* RX FIFO control signals */
    input logic        rx_rxfifo_en_i,
    input logic        rx_rxfifo_flush_strobe_i,
    input logic [4:0]  rx_rxfifo_waterline_i,
    input logic        rx_rxfifo_underflow_clear_strobe_i,
    /* RX IDLE detection control signals */
    input logic        rx_idle_type_i,
    input logic [2:0]  rx_idle_length_cfg_i,
    /* RX hardware flow control signals */
    input logic        rx_rts_mode1_en_i,
    input logic [1:0]  rx_rts_mode1_waterline_i,
    /* RX multi-processor communication control signals */
    input logic        rx_mpc_idle_mode_i,
    input logic [1:0]  rx_match_mode_cfg_i,
    input logic        rx_match1_en_i,
    input logic        rx_match2_en_i,
    input logic [7:0]  rx_match1_data_i,
    input logic [7:0]  rx_match2_data_i,
    input logic        rx_mpc_force_standby_i,
    input logic        rx_mpc_force_wakeup_i,
    /* RX enhanced physical layer control signals */
    input logic        rx_msb_first_mode_en_i,
    input logic        rx_rxd_inv_en_i,
    /* RX LIN signals */
    input logic        rx_lin_break_detect_en_i,
    input logic        rx_lin_break_clear_strobe_i,
    /* RX state flag clear signals */
    input logic        rx_edge_clear_strobe_i,
    input logic        rx_idle_clear_strobe_i,
    input logic        rx_overflow_clear_strobe_i,
    input logic        rx_noise_clear_strobe_i,
    input logic        rx_framing_error_clear_strobe_i,
    input logic        rx_parity_error_clear_strobe_i,
    input logic        rx_match1_clear_strobe_i,
    input logic        rx_match2_clear_strobe_i,
    /* RX data signals */
    output logic [7:0]  rx_data_o,
    output logic        rx_data_interface_preframe_idle_o,
    output logic        rx_data_interface_preframe_empty_o,
    output logic        rx_data_interface_framing_error_o,
    output logic        rx_data_interface_parity_error_o,
    output logic        rx_data_interface_noise_o,
    output logic        rx_data_interface_addr_frame_o,
    /* RX common state signals */
    output logic         rx_ready_o,
    output logic        rx_active_flag_o,
    output logic        rx_edge_flag_o,
    /* RX FIFO state signals */
    output logic [4:0]  rx_rxfifo_cnt_o,
    output logic        rx_rxfifo_empty_flag_o,
    /* RX IDLE state signals */
    output logic        rx_idle_flag_o,
    /* RX multi-processor communication state signals */
    output logic         rx_standby_flag_o,
    output logic        rx_mpc_match1_flag_o,
    output logic        rx_mpc_match2_flag_o,
    /* RX error state signals */
    output logic        rx_overflow_flag_o,
    output logic        rx_rxfifo_underflow_flag_o,
    output logic        rx_noise_flag_o,
    output logic        rx_framing_error_flag_o,
    output logic        rx_parity_error_flag_o,
    /* RX LIN state signals */
    output logic        rx_lin_break_flag_o,
    /* RX IO signals */
    input logic        rx_rxd_i,
    output logic        rx_rts_mode1_o
);

    /* Multi-processor communication protocol type code */
    localparam [1:0] MPC_PROTOCOL_NULL       = 2'b00;
    localparam [1:0] MPC_PROTOCOL_IDLE       = 2'b01;
    localparam [1:0] MPC_PROTOCOL_ADDR_BIT   = 2'b10;
    localparam [1:0] MPC_PROTOCOL_FIRST_LAST = 2'b11;

    /* Multi-processor communication state code */
    localparam [1:0] MPC_STANDBY             = 2'b01;
    localparam [1:0] MPC_WKUP                = 2'b10;

    /* FSM state code */
    localparam [2:0] IDLE                    = 3'b001;
    localparam [2:0] START                   = 3'b010;
    localparam [2:0] RX_FRAME                = 3'b100;

    /* State regsiters */
    logic [2:0] state;
    logic [2:0] state_next;
    logic [1:0] mpc_state;
    logic [1:0] mpc_state_next;

    /* Sample points shift registers */
    logic [2:0] sample_points_history_3bits_shifter;

    /* Frame receiver registers */
    logic [2:0]  frame_sample_points_vote_3bits_assembler;
    logic [6:0]  frame_sample_points_cnt;
    logic        frame_sample_points_record1;
    logic        frame_sample_points_record0;
    logic        frame_sample_points_inconsistent_record;
    logic        frame_sample_points_inconsistent_raw;
    logic [3:0]  frame_bit_cnt;
    logic [7:0]  frame_data_bits_assembler;
    logic        frame_parity_bit_assembler;
    logic        frame_addr_bit_assembler;

    /* LIN break detection registers */
    logic [6:0]  lin_break_sample_points_cnt;
    logic [17:0] lin_break_bit_cnt;

    /* IDLE detection registers */
    logic [6:0]  idle_sample_points_cnt;
    logic [17:0] idle_bit_cnt;
    logic        idle_detection_block;

    /* Pre-frame IDLE detected signal */
    logic frame_preframe_idle_detected;

    /* Multi-processor communication address frame detected signal */
    logic frame_mpc_addr_detected;
    logic mpc_wkup;

    /* Flags */
    logic rx_edge_flag;
    logic rx_active_flag;
    logic idle_flag;
    logic lin_break_flag;
    logic mpc_match1_flag;
    logic mpc_match2_flag;
    logic overflow_flag;
    logic parity_error_flag;
    logic framing_error_flag;
    logic noise_flag;

    /* Generate RXD signal & edge detection signal */
    logic rxd;
    logic rxd_falling_edge;
    logic rxd_rising_edge;

    assign rxd = rx_rxd_i ^ rx_rxd_inv_en_i;
    assign rxd_falling_edge = (sample_points_history_3bits_shifter == 3'b111) & !rxd;
    assign rxd_rising_edge = (sample_points_history_3bits_shifter == 3'b000) & rxd;

    /* Generate tick signals */
    /* Get sample points total number per bit */
    logic       standard_sample_tick;
    logic       enhance_sample_tick;
    logic       sample_tick;
    logic [6:0] sample_points_num_per_bit;

    uart_baud_gen uart_baud_gen_inst (
        .clk_i                        (clk_i),
        .rst_n_i                      (rst_n_i),
        .oversample_ratio_i           (rx_oversample_ratio_i),
        .baud_divider_i               (rx_baud_div_i),
        .restart_i                    (1'b0),
        .enhance_sample_tick_en_i     (rx_both_edge_en_i),
        .standard_sample_tick_o       (standard_sample_tick),
        .enhance_sample_tick_o        (enhance_sample_tick),
        .bit_tick_o                   (),
        .sample_points_num_per_bit    (sample_points_num_per_bit)
    );

    assign sample_tick = standard_sample_tick | enhance_sample_tick;

    /* Generate & Clear RX edge flag */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_edge_flag <= 1'b0;
        end else begin
            if (rx_edge_clear_strobe_i) begin
                rx_edge_flag <= 1'b0;
            end

            if (rx_en_i) begin
                if (sample_tick) begin
                    if (rx_rxd_inv_en_i) begin
                        if (rxd_rising_edge) begin
                            rx_edge_flag <= 1'b1;
                        end
                    end else begin
                        if (rxd_falling_edge) begin
                            rx_edge_flag <= 1'b1;
                        end
                    end
                end
            end
        end
    end

    /* Refresh sample points shifter */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            sample_points_history_3bits_shifter <= 3'b111;
        end else begin
            if (rx_en_i) begin
                if (sample_tick) begin
                    sample_points_history_3bits_shifter <= {sample_points_history_3bits_shifter[1:0], rxd};
                end else begin
                    sample_points_history_3bits_shifter <= sample_points_history_3bits_shifter;
                end
            end else begin
                sample_points_history_3bits_shifter <= 3'b111;
            end
        end
    end

    /* Generate sample points (vote) location */
    /* Get vote result */
    logic [6:0] sample_points_vote_start_idx;
    logic [2:0] sample_points_vote_one_cnt;
    logic       vote_result_val;

    assign sample_points_vote_start_idx = (sample_points_num_per_bit == 7'd4) ? 7'd0 : ((sample_points_num_per_bit >> 1) - 7'd1);
    assign sample_points_vote_one_cnt = frame_sample_points_vote_3bits_assembler[0] + frame_sample_points_vote_3bits_assembler[1] + frame_sample_points_vote_3bits_assembler[2];
    assign vote_result_val = (sample_points_vote_one_cnt >= 3'd2);

    /* Generate sample points inconsistent signal */
    always_comb begin
        if (frame_sample_points_record1 & frame_sample_points_record0) begin
            frame_sample_points_inconsistent_raw = 1'b1;
        end else begin
            frame_sample_points_inconsistent_raw = 1'b0;
        end
    end

    /* Generate resync event signal */
    logic resync_event;

    assign resync_event = rx_resync_en_i & rxd_falling_edge & (frame_sample_points_cnt < sample_points_vote_start_idx);

    /* RX Buffer */
    logic       rxbuf_cnt;
    logic [7:0] rxbuf_data;
    logic       rxbuf_preframe_idle;
    logic       rxbuf_framing_error;
    logic       rxbuf_parity_error;
    logic       rxbuf_noise;
    logic       rxbuf_addr_frame;

    /* RX FIFO */
    logic [4:0] rxfifo_cnt;
    logic [3:0] rxfifo_writing_pointer;
    logic [3:0] rxfifo_reading_pointer;
    logic [7:0] rxfifo_data           [0:15];
    logic       rxfifo_preframe_idle  [0:15];
    logic       rxfifo_framing_error  [0:15];
    logic       rxfifo_parity_error   [0:15];
    logic       rxfifo_noise          [0:15];
    logic       rxfifo_preframe_empty [0:15];
    logic       rxfifo_addr_frame     [0:15];

    /* RX B/F state */
    logic [7:0] rx_data;
    logic       rx_preframe_idle;
    logic       rx_framing_error;
    logic       rx_parity_error;
    logic       rx_noise;
    logic       rx_addr_frame;
    logic       rx_empty;
    logic       rx_pending;
    logic       rx_full;

    always_comb begin
        if (rx_rxfifo_en_i) begin
            rx_data = rxfifo_data[rxfifo_reading_pointer];
            rx_preframe_idle = rxfifo_preframe_idle[rxfifo_reading_pointer];
            rx_framing_error = rxfifo_framing_error[rxfifo_reading_pointer];
            rx_parity_error = rxfifo_parity_error[rxfifo_reading_pointer];
            rx_noise = rxfifo_noise[rxfifo_reading_pointer];
            rx_addr_frame = rxfifo_addr_frame[rxfifo_reading_pointer];
            rx_empty = (rxfifo_cnt == 5'd0) ? 1'b1 : 1'b0;
            rx_pending = (rxfifo_cnt > 5'd0) ? 1'b1 : 1'b0;
            rx_full = (rxfifo_cnt == 5'd16) ? 1'b1 : 1'b0;
        end else begin
            rx_data = rxbuf_data;
            rx_preframe_idle = rxbuf_preframe_idle;
            rx_framing_error = rxbuf_framing_error;
            rx_parity_error = rxbuf_parity_error;
            rx_noise = rxbuf_noise;
            rx_addr_frame = rxbuf_addr_frame;
            rx_empty = (rxbuf_cnt == 1'b0) ? 1'b1 : 1'b0;
            rx_pending = (rxbuf_cnt > 1'b0) ? 1'b1 : 1'b0;
            rx_full = (rxbuf_cnt == 1'b1) ? 1'b1 : 1'b0;
        end
    end

    /* Generate frame format signals */
    logic mpc_addr_bit_protocol;

    assign mpc_addr_bit_protocol = (rx_match_mode_cfg_i == MPC_PROTOCOL_ADDR_BIT);
    logic [3:0] data_length;
    logic [7:0] data_mask;
    logic [4:0] stop_bit_idx;
    logic [4:0] frame_length;

    assign data_length = {1'b0, rx_data_length_cfg_i} + 4'd1;
    assign data_mask = 8'hFF >> (4'd8 - data_length);
    assign stop_bit_idx = 5'd1 + {1'b0, data_length} + mpc_addr_bit_protocol + rx_parity_en_i;
    assign frame_length = 5'd2 + {1'b0, data_length} + mpc_addr_bit_protocol + rx_parity_en_i + rx_stop_length_cfg_i;

    /* Generate frame start / end signals */
    logic frame_start;
    logic frame_end;

    always_comb begin
        if (state == START) begin
            if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                if (vote_result_val == 1'b0) begin
                    frame_start = 1'b1;
                end else begin
                    frame_start = 1'b0;
                end
            end else begin
                frame_start = 1'b0;
            end
        end else begin
            frame_start = 1'b0;
        end
    end

    always_comb begin
        if (sample_tick) begin
            if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                if (state == RX_FRAME) begin
                    if (frame_bit_cnt == stop_bit_idx) begin
                        frame_end = 1'b1;
                    end else begin
                        frame_end = 1'b0;
                    end
                end else begin
                    frame_end = 1'b0;
                end
            end else begin
                frame_end = 1'b0;
            end
        end else begin
            frame_end = 1'b0;
        end
    end

    /* Generate RX buffer / RXFIFO operation signals */
    /* Get RX buffer / RXFIFO state */
    logic store;
    logic pop;
    logic overflow;
    logic underflow;

    assign pop = rx_read_strobe_i & !rx_empty;
    assign store = rx_en_i & !rx_lin_break_detect_en_i & (mpc_state_next == MPC_WKUP) & frame_end & (!rx_full | pop);
    assign overflow = rx_en_i & !rx_lin_break_detect_en_i & (mpc_state_next == MPC_WKUP) & frame_end & rx_full & !pop;
    assign underflow = rx_read_strobe_i & rx_empty;

    /* Generate & Clear underflow flag */
    logic underflow_flag;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            underflow_flag <= 1'b0;
        end else begin
            if (rx_rxfifo_underflow_clear_strobe_i) begin
                underflow_flag <= 1'b0;
            end

            if (underflow) begin
                underflow_flag <= 1'b1;
            end
        end
    end

    /* Generate parity state signals */
    logic parity_target;
    logic parity_pass;

    assign parity_target = ^(frame_data_bits_assembler & data_mask) ^ (mpc_addr_bit_protocol & frame_addr_bit_assembler) ^ rx_parity_type_i;
    assign parity_pass = !rx_parity_en_i | (frame_parity_bit_assembler == parity_target);

    /* Detect IDLE */
    logic [11:0] idle_length;
    logic         idle_raw;
    logic         idle_event;

    assign idle_length = {7'b0, frame_length} << rx_idle_length_cfg_i;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            idle_sample_points_cnt <= 7'd0;
            idle_bit_cnt <= 18'd0;
        end else begin
            if (!rx_en_i) begin
                idle_sample_points_cnt <= 7'd0;
                idle_bit_cnt <= 18'd0;
            end

            if (rx_en_i) begin
                if (sample_tick) begin
                    case (state)
                        IDLE: begin
                            if (rxd) begin
                                if (idle_sample_points_cnt == sample_points_num_per_bit - 7'd1) begin
                                    idle_sample_points_cnt <= 7'd0;
                                    idle_bit_cnt <= idle_bit_cnt + 18'h1;
                                end else begin
                                    idle_sample_points_cnt <= idle_sample_points_cnt + 7'd1;
                                end
                            end else begin
                                idle_sample_points_cnt <= 7'd0;
                                idle_bit_cnt <= 18'd0;
                            end
                        end

                        START: begin
                            idle_sample_points_cnt <= 7'd0;
                            idle_bit_cnt <= 18'd0;
                        end

                        RX_FRAME: begin
                            if ((frame_bit_cnt >= 4'd1) && !rx_idle_type_i) begin
                                if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                                    if (vote_result_val == 1'b1) begin
                                        idle_bit_cnt <= idle_bit_cnt + 18'd1;
                                    end else begin
                                        idle_bit_cnt <= 18'd0;
                                    end
                                end
                                idle_sample_points_cnt <= 7'd0;
                            end else begin
                                idle_sample_points_cnt <= 7'd0;
                                idle_bit_cnt <= 18'd0;
                            end
                        end

                        default: begin
                            idle_sample_points_cnt <= 7'd0;
                            idle_bit_cnt <= 18'd0;
                        end
                    endcase
                end
            end

            if (mpc_wkup) begin
                idle_bit_cnt <= 18'd0;
                idle_sample_points_cnt <= 7'd0;
            end
        end
    end

    always_comb begin
        if (state == IDLE) begin
            if (rx_en_i & (idle_bit_cnt >= idle_length)) begin
                idle_raw = 1'b1;
            end else begin
                idle_raw = 1'b0;
            end
        end else begin
            idle_raw = 1'b0;
        end
    end

    always_comb begin
        if (mpc_state == MPC_STANDBY) begin
            if (idle_raw & !idle_detection_block) begin
                if ((rx_match_mode_cfg_i == MPC_PROTOCOL_IDLE) & rx_mpc_idle_mode_i) begin
                    idle_event = 1'b1;
                end else begin
                    idle_event = 1'b0;
                end
            end else begin
                idle_event = 1'b0;
            end
        end else begin
            if (idle_raw & !idle_detection_block) begin
                idle_event = 1'b1;
            end else begin
                idle_event = 1'b0;
            end
        end
    end

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            idle_flag <= 1'b0;
            idle_detection_block <= 1'b0;
        end else begin
            if (rx_idle_clear_strobe_i) begin
                idle_flag <= 1'b0;
            end

            if (frame_start) begin
                idle_detection_block <= 1'b0;
            end

            if (idle_event) begin
                idle_flag <= 1'b1;
                idle_detection_block <= 1'b1;
            end

            if (mpc_wkup) begin
                idle_detection_block <= 1'b0;
            end
        end
    end

    /* Detect LIN break */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            lin_break_sample_points_cnt <= 7'd0;
            lin_break_bit_cnt <= 18'd0;
            lin_break_flag <= 1'b0;
        end else begin
            if (rx_lin_break_clear_strobe_i) begin
                lin_break_flag <= 1'b0;
            end

            if (!rx_en_i) begin
                lin_break_sample_points_cnt <= 7'd0;
                lin_break_bit_cnt <= 18'd0;
            end else begin
                if (sample_tick) begin
                    if (rxd) begin
                        lin_break_sample_points_cnt <= 7'd0;
                        lin_break_bit_cnt <= 18'd0;
                    end else begin
                        if (lin_break_sample_points_cnt == sample_points_num_per_bit - 7'd1) begin
                            lin_break_sample_points_cnt <= 7'd0;
                            lin_break_bit_cnt <= lin_break_bit_cnt + 18'h1;
                        end else begin
                            lin_break_sample_points_cnt <= lin_break_sample_points_cnt + 7'd1;
                        end
                    end

                    if (rx_lin_break_detect_en_i && (state == IDLE) && (lin_break_bit_cnt >= 18'd13)) begin
                        lin_break_flag <= 1'b1;
                    end
                end
            end
        end
    end

    /* Generate match raw result signals */
    logic match1_raw;
    logic match2_raw;

    assign match1_raw = rx_match1_en_i & ((frame_data_bits_assembler[7:0] & data_mask) == (rx_match1_data_i[7:0] & data_mask));
    assign match2_raw = rx_match2_en_i & ((frame_data_bits_assembler[7:0] & data_mask) == (rx_match2_data_i[7:0] & data_mask));

    /* Generate multi-processor communication degenerate signal */
    logic mpc_degenerate;

    always_comb begin
        case (rx_match_mode_cfg_i)
            MPC_PROTOCOL_NULL: begin
                mpc_degenerate = 1'b1;
            end

            MPC_PROTOCOL_IDLE: begin
                mpc_degenerate = !(rx_match1_en_i | rx_match2_en_i);
            end

            MPC_PROTOCOL_ADDR_BIT: begin
                mpc_degenerate = !(rx_match1_en_i | rx_match2_en_i);
            end

            MPC_PROTOCOL_FIRST_LAST: begin
                mpc_degenerate = !(rx_match1_en_i & rx_match2_en_i);
            end
        endcase
    end

    /* Generate multi-processor communication address frame detected signals */
    always_comb begin
        case (rx_match_mode_cfg_i)
            MPC_PROTOCOL_IDLE: begin
                if (frame_preframe_idle_detected) begin
                    frame_mpc_addr_detected = 1'b1;
                end else begin
                    frame_mpc_addr_detected = 1'b0;
                end
            end

            MPC_PROTOCOL_ADDR_BIT: begin
                if (frame_addr_bit_assembler) begin
                    frame_mpc_addr_detected = 1'b1;
                end else begin
                    frame_mpc_addr_detected = 1'b0;
                end
            end

            MPC_PROTOCOL_NULL: begin
                frame_mpc_addr_detected = 1'b0;
            end

            MPC_PROTOCOL_FIRST_LAST: begin
                frame_mpc_addr_detected = 1'b0;
            end
        endcase
    end

    /* Generate multi-processor communication signals */
    logic  mpc_match1;
    logic  mpc_match2;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            mpc_state <= MPC_STANDBY;
        end else begin
            mpc_state <= mpc_state_next;
        end
    end

    always_comb begin
        mpc_state_next = mpc_state;

        if (rx_mpc_force_standby_i) begin
            mpc_state_next = MPC_STANDBY;
        end else if (rx_mpc_force_wakeup_i) begin
            mpc_state_next = MPC_WKUP;
        end else if (!rx_en_i) begin
            if (rx_match_mode_cfg_i == MPC_PROTOCOL_NULL) begin
                mpc_state_next = MPC_WKUP;
            end else begin
                mpc_state_next = MPC_STANDBY;
            end
        end else begin
            case (mpc_state)
                MPC_STANDBY: begin
                    if ((rx_match_mode_cfg_i == MPC_PROTOCOL_NULL) | mpc_degenerate) begin
                        mpc_state_next = MPC_WKUP;
                    end else if ((rx_match_mode_cfg_i == MPC_PROTOCOL_IDLE) & idle_raw) begin
                        mpc_state_next = MPC_WKUP;
                    end else if (frame_end) begin
                        case (rx_match_mode_cfg_i)
                            MPC_PROTOCOL_IDLE: begin
                                if (frame_mpc_addr_detected) begin
                                    if (match1_raw | match2_raw) begin
                                        mpc_state_next = MPC_WKUP;
                                    end
                                end
                            end

                            MPC_PROTOCOL_ADDR_BIT: begin
                                if (frame_mpc_addr_detected) begin
                                    if (match1_raw | match2_raw) begin
                                        mpc_state_next = MPC_WKUP;
                                    end
                                end
                            end

                            MPC_PROTOCOL_FIRST_LAST: begin
                                if (match1_raw) begin
                                    mpc_state_next = MPC_WKUP;
                                end
                            end
                        endcase
                    end
                end

                MPC_WKUP: begin
                    if ((rx_match_mode_cfg_i == MPC_PROTOCOL_NULL) | mpc_degenerate) begin
                        mpc_state_next = MPC_WKUP;
                    end else if (frame_end) begin
                        case (rx_match_mode_cfg_i)
                            MPC_PROTOCOL_IDLE: begin
                                if (frame_mpc_addr_detected) begin
                                    if (!(match1_raw | match2_raw)) begin
                                        mpc_state_next = MPC_STANDBY;
                                    end
                                end
                            end

                            MPC_PROTOCOL_ADDR_BIT: begin
                                if (frame_mpc_addr_detected) begin
                                    if (!(match1_raw | match2_raw)) begin
                                        mpc_state_next = MPC_STANDBY;
                                    end
                                end
                            end

                            MPC_PROTOCOL_FIRST_LAST: begin
                                if (!match1_raw & match2_raw) begin
                                    mpc_state_next = MPC_STANDBY;
                                end
                            end
                        endcase
                    end
                end

                default: begin
                    mpc_state_next = MPC_STANDBY;
                end
            endcase
        end
    end

    always_comb begin
        mpc_match1 = 1'b0;
        mpc_match2 = 1'b0;

        if (frame_end) begin
            if ((rx_match_mode_cfg_i == MPC_PROTOCOL_NULL) | mpc_degenerate) begin
                mpc_match1 = match1_raw;
                mpc_match2 = match2_raw;
            end else begin
                case (rx_match_mode_cfg_i)
                    MPC_PROTOCOL_IDLE: begin
                        if (frame_mpc_addr_detected) begin
                            mpc_match1 = match1_raw;
                            mpc_match2 = match2_raw;
                        end
                    end

                    MPC_PROTOCOL_ADDR_BIT: begin
                        if (frame_mpc_addr_detected) begin
                            mpc_match1 = match1_raw;
                            mpc_match2 = match2_raw;
                        end
                    end

                    MPC_PROTOCOL_FIRST_LAST: begin
                        mpc_match1 = match1_raw;
                        mpc_match2 = match2_raw & !match1_raw;
                    end
                endcase
            end
        end
    end

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            mpc_match1_flag <= 1'b0;
            mpc_match2_flag <= 1'b0;
        end else begin
            if (rx_match1_clear_strobe_i) begin
                mpc_match1_flag <= 1'b0;
            end

            if (rx_match2_clear_strobe_i) begin
                mpc_match2_flag <= 1'b0;
            end

            if (store) begin
                mpc_match1_flag <= mpc_match1;
                mpc_match2_flag <= mpc_match2;
            end
        end
    end

    always_comb begin
        if ((mpc_state == MPC_STANDBY) & (mpc_state_next == MPC_WKUP)) begin
            mpc_wkup = 1'b1;
        end else begin
            mpc_wkup = 1'b0;
        end
    end

    /* Store RX buffer */
    /* Refresh RX buffer counter */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rxbuf_cnt <= 1'b0;
            rxbuf_data <= 8'h00;
            rxbuf_preframe_idle <= 1'b0;
            rxbuf_framing_error <= 1'b0;
            rxbuf_parity_error <= 1'b0;
            rxbuf_noise <= 1'b0;
            rxbuf_addr_frame <= 1'b0;
        end else begin
            if (rx_rxfifo_flush_strobe_i) begin
                rxbuf_cnt <= 1'b0;
            end else if (!rx_rxfifo_en_i) begin
                if (store) begin
                    rxbuf_data <= frame_data_bits_assembler;
                    rxbuf_preframe_idle <= frame_preframe_idle_detected;
                    rxbuf_framing_error <= (vote_result_val == 1'b0);
                    rxbuf_parity_error <= (parity_pass == 1'b0);
                    rxbuf_noise <= frame_sample_points_inconsistent_record | frame_sample_points_inconsistent_raw;
                    rxbuf_addr_frame <= frame_mpc_addr_detected;
                    rxbuf_cnt <= 1'b1;
                end else if (pop) begin
                    rxbuf_cnt <= 1'b0;
                end
            end else begin
                rxbuf_cnt <= 1'b0;
            end
        end
    end

    /* Store RXFIFO */
    always_ff @ (posedge clk_i) begin
        if (rx_rxfifo_en_i & store) begin
            rxfifo_data[rxfifo_writing_pointer] <= frame_data_bits_assembler;
            rxfifo_preframe_idle[rxfifo_writing_pointer] <= frame_preframe_idle_detected;
            rxfifo_framing_error[rxfifo_writing_pointer] <= (vote_result_val == 1'b0);
            rxfifo_parity_error[rxfifo_writing_pointer] <= (parity_pass == 1'b0);
            rxfifo_noise[rxfifo_writing_pointer] <= frame_sample_points_inconsistent_record | frame_sample_points_inconsistent_raw;
            rxfifo_preframe_empty[rxfifo_writing_pointer] <= (rxfifo_cnt == 5'd0);
            rxfifo_addr_frame[rxfifo_writing_pointer] <= frame_mpc_addr_detected;
        end
    end

    /* Refresh RXFIFO counter & pointer */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rxfifo_writing_pointer <= 4'd0;
            rxfifo_reading_pointer <= 4'd0;
            rxfifo_cnt <= 5'd0;
        end else begin
            if (rx_rxfifo_flush_strobe_i) begin
                rxfifo_writing_pointer <= 4'd0;
                rxfifo_reading_pointer <= 4'd0;
                rxfifo_cnt <= 5'd0;
            end else if (rx_rxfifo_en_i) begin
                if (store) begin
                    rxfifo_writing_pointer <= rxfifo_writing_pointer + 4'd1;
                end

                if (pop) begin
                    rxfifo_reading_pointer <= rxfifo_reading_pointer + 4'd1;
                end

                rxfifo_cnt <= rxfifo_cnt + store - pop;
            end else begin
                rxfifo_cnt <= 5'd0;
            end
        end
    end

    /* Generate RTS (mode 1) request signal */
    logic  [4:0] rts_mode1_depth;
    logic  [4:0] rts_mode1_occupied_cnt;
    logic  [4:0] rts_mode1_free_cnt;
    logic        rts_mode1_req;

    always_comb begin
        if (rx_rxfifo_en_i) begin
            rts_mode1_depth = 5'd16;
            rts_mode1_occupied_cnt = rxfifo_cnt + {4'b0, (state != IDLE)};
        end else begin
            rts_mode1_depth = 5'd1;
            rts_mode1_occupied_cnt = {4'b0, rxbuf_cnt} + {4'b0, (state != IDLE)};
        end

        if (rts_mode1_occupied_cnt >= rts_mode1_depth) begin
            rts_mode1_free_cnt = 5'd0;
        end else begin
            rts_mode1_free_cnt = rts_mode1_depth - rts_mode1_occupied_cnt;
        end

        if (rx_rts_mode1_waterline_i == 2'b00) begin
            if (rts_mode1_occupied_cnt >= rts_mode1_depth) begin
                rts_mode1_req = 1'b1;
            end else begin
                rts_mode1_req = 1'b0;
            end
        end else begin
            if (rts_mode1_free_cnt < {3'b0, rx_rts_mode1_waterline_i}) begin
                rts_mode1_req = 1'b1;
            end else begin
                rts_mode1_req = 1'b0;
            end
        end
    end

    /* Generate & Clear error flags */
    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            overflow_flag <= 1'b0;
            parity_error_flag <= 1'b0;
            framing_error_flag <= 1'b0;
            noise_flag <= 1'b0;
        end else begin
            if (rx_overflow_clear_strobe_i) begin
                overflow_flag <= 1'b0;
            end

            if (rx_parity_error_clear_strobe_i) begin
                parity_error_flag <= 1'b0;
            end

            if (rx_framing_error_clear_strobe_i) begin
                framing_error_flag <= 1'b0;
            end

            if (rx_noise_clear_strobe_i) begin
                noise_flag <= 1'b0;
            end

            if (store) begin
                noise_flag <= frame_sample_points_inconsistent_record | frame_sample_points_inconsistent_raw;
                framing_error_flag <= (vote_result_val == 1'b0) ? 1'b1 : 1'b0;
                parity_error_flag <= (parity_pass == 1'b0) ? 1'b1 : 1'b0;
            end else if (overflow) begin
                overflow_flag <= 1'b1;
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

        if (!rx_en_i) begin
            state_next = IDLE;
        end else begin
            if (sample_tick) begin
                case (state)
                    IDLE: begin
                        if (rxd_falling_edge) begin
                            state_next = START;
                        end else begin
                            state_next = state;
                        end
                    end

                    START: begin
                        if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                            if (!rxd_falling_edge) begin
                                if (vote_result_val == 1'b0) begin
                                    state_next = RX_FRAME;
                                end else begin
                                    state_next = IDLE;
                                end
                            end else begin
                                state_next = state;
                            end
                        end else begin
                            state_next = state;
                        end
                    end

                    RX_FRAME: begin
                        if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                            if (frame_bit_cnt == stop_bit_idx) begin
                                if ((vote_result_val == 1'b1) && !rxd) begin
                                    state_next = START;
                                end else begin
                                    state_next = IDLE;
                                end
                            end else begin
                                state_next = state;
                            end
                        end else begin
                            state_next = state;
                        end
                    end
                endcase
            end else begin
                state_next = state;
            end
        end
    end

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin

            /* RX common state */
            rx_active_flag <= 1'b0;

            /* Sample state */
            frame_sample_points_cnt <= 6'd0;
            frame_sample_points_vote_3bits_assembler <= 3'b0;
            frame_sample_points_record1 <= 1'b0;
            frame_sample_points_record0 <= 1'b0;
            frame_sample_points_inconsistent_record <= 1'b0;

            /* Bit state */
            frame_bit_cnt <= 4'd0;

            /* data assembler */
            frame_data_bits_assembler <= 8'h00;
            frame_parity_bit_assembler <= 1'b0;
            frame_addr_bit_assembler <= 1'b0;

            /* Data interface state */
            frame_preframe_idle_detected <= 1'b0;
        end else begin
            if (!rx_en_i) begin
                rx_active_flag <= 1'b0;
                frame_sample_points_cnt <= 6'd0;
                frame_bit_cnt <= 4'd0;
            end

            case (state)
                IDLE: begin
                    if (sample_tick) begin
                        if (rxd_falling_edge) begin
                            frame_sample_points_cnt <= 6'd0;
                            frame_sample_points_vote_3bits_assembler <= 3'b0;
                            frame_sample_points_inconsistent_record <= 1'b0;
                            frame_sample_points_record1 <= 1'b0;
                            frame_sample_points_record0 <= 1'b0;
                            frame_bit_cnt <= 4'd0;
                            frame_data_bits_assembler <= 8'h00;
                            frame_parity_bit_assembler <= 1'b0;
                            frame_addr_bit_assembler <= 1'b0;
                            frame_preframe_idle_detected <= (idle_bit_cnt >= idle_length) ? 1'b1 : 1'b0;
                        end
                    end

                    if (idle_raw) begin
                        rx_active_flag <= 1'b0;
                    end
                end

                START: begin
                    if (sample_tick) begin
                        if (rxd_falling_edge && (frame_sample_points_cnt != 6'd0)) begin
                            frame_sample_points_cnt <= 6'd0;
                            frame_sample_points_vote_3bits_assembler <= 3'b0;
                        end else begin
                            if ((frame_sample_points_cnt != 6'd0) && (frame_sample_points_cnt != sample_points_num_per_bit - 6'd1)) begin
                                if (rxd) begin
                                    frame_sample_points_record1 <= 1'b1;
                                end else begin
                                    frame_sample_points_record0 <= 1'b1;
                                end
                            end

                            if (frame_sample_points_cnt == sample_points_vote_start_idx) begin
                                frame_sample_points_vote_3bits_assembler[0] <= rxd;
                            end else if (frame_sample_points_cnt == sample_points_vote_start_idx + 6'd1) begin
                                frame_sample_points_vote_3bits_assembler[1] <= rxd;
                            end else if (frame_sample_points_cnt == sample_points_vote_start_idx + 6'd2) begin
                                frame_sample_points_vote_3bits_assembler[2] <= rxd;
                            end

                            if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                                if (frame_sample_points_inconsistent_raw) begin
                                    frame_sample_points_inconsistent_record <= 1'b1;
                                end

                                frame_sample_points_record1 <= 1'b0;
                                frame_sample_points_record0 <= 1'b0;

                                if (vote_result_val == 1'b0) begin
                                    rx_active_flag <= 1'b1;
                                    frame_sample_points_cnt <= 6'd0;
                                    frame_bit_cnt <= 4'd1;
                                end else begin
                                    rx_active_flag <= 1'b0;
                                end
                            end else begin
                                frame_sample_points_cnt <= frame_sample_points_cnt + 6'd1;
                            end
                        end
                    end
                end

                RX_FRAME: begin
                    if (sample_tick) begin
                        if (resync_event) begin
                            frame_sample_points_cnt <= 6'd0;
                            frame_sample_points_vote_3bits_assembler <= 3'b0;
                        end else begin
                            if ((frame_sample_points_cnt != 6'd0) && (frame_sample_points_cnt != sample_points_num_per_bit - 6'd1)) begin
                                if (rxd) begin
                                    frame_sample_points_record1 <= 1'b1;
                                end else begin
                                    frame_sample_points_record0 <= 1'b1;
                                end
                            end

                            if (frame_sample_points_cnt == sample_points_vote_start_idx) begin
                                frame_sample_points_vote_3bits_assembler[0] <= rxd;
                            end else if (frame_sample_points_cnt == sample_points_vote_start_idx + 6'd1) begin
                                frame_sample_points_vote_3bits_assembler[1] <= rxd;
                            end else if (frame_sample_points_cnt == sample_points_vote_start_idx + 6'd2) begin
                                frame_sample_points_vote_3bits_assembler[2] <= rxd;
                            end

                            if (frame_sample_points_cnt == sample_points_num_per_bit - 6'd1) begin
                                frame_sample_points_cnt <= 6'd0;

                                if (frame_sample_points_inconsistent_raw) begin
                                    frame_sample_points_inconsistent_record <= 1'b1;
                                end

                                frame_sample_points_record1 <= 1'b0;
                                frame_sample_points_record0 <= 1'b0;

                                if (frame_bit_cnt <= data_length) begin
                                    if (rx_msb_first_mode_en_i) begin
                                        frame_data_bits_assembler[data_length - frame_bit_cnt] <= vote_result_val;
                                    end else begin
                                        frame_data_bits_assembler[frame_bit_cnt - 4'd1] <= vote_result_val;
                                    end
                                end else if (mpc_addr_bit_protocol && (frame_bit_cnt == data_length + 4'd1)) begin
                                    frame_addr_bit_assembler <= vote_result_val;
                                end else if (rx_parity_en_i && (frame_bit_cnt == data_length + 4'd1 + mpc_addr_bit_protocol)) begin
                                    frame_parity_bit_assembler <= vote_result_val;
                                end

                                if (frame_bit_cnt == stop_bit_idx) begin
                                    if ((vote_result_val == 1'b1) && !rxd) begin
                                        frame_sample_points_vote_3bits_assembler <= 3'b0;
                                        frame_sample_points_inconsistent_record <= 1'b0;
                                        frame_bit_cnt <= 4'd0;
                                        frame_data_bits_assembler <= 8'h00;
                                        frame_parity_bit_assembler <= 1'b0;
                                        frame_preframe_idle_detected <= 1'b0;
                                    end
                                end else begin
                                    frame_bit_cnt <= frame_bit_cnt + 4'd1;
                                end
                            end else begin
                                frame_sample_points_cnt <= frame_sample_points_cnt + 6'd1;
                            end
                        end
                    end
                end
            endcase
        end
    end

    /* Output RX common state */
    always_comb begin
        if (rx_rxfifo_en_i) begin
            rx_ready_o = (rxfifo_cnt >= rx_rxfifo_waterline_i);
        end else begin
            rx_ready_o = rxbuf_cnt;
        end
    end

    assign rx_edge_flag_o = rx_edge_flag;
    assign rx_active_flag_o = rx_active_flag;

    /* Output data interface state */
    assign rx_data_o = rx_empty ? 8'h00 : rx_data;
    assign rx_data_interface_preframe_idle_o = rx_empty ? 1'b0 : rx_preframe_idle;
    assign rx_data_interface_preframe_empty_o = rx_empty ? 1'b1 : (rx_rxfifo_en_i ? rxfifo_preframe_empty[rxfifo_reading_pointer] : 1'b0);
    assign rx_data_interface_framing_error_o = rx_empty ? 1'b0 : rx_framing_error;
    assign rx_data_interface_parity_error_o = rx_empty ? 1'b0 : rx_parity_error;
    assign rx_data_interface_noise_o = rx_empty ? 1'b0 : rx_noise;
    assign rx_data_interface_addr_frame_o = rx_empty ? 1'b0 : rx_addr_frame;

    /* Output RXFIFO state */
    assign rx_rxfifo_empty_flag_o = rx_empty;
    assign rx_rxfifo_cnt_o = rx_rxfifo_en_i ? rxfifo_cnt : 5'd0;
    assign rx_rxfifo_underflow_flag_o = underflow_flag;

    /* Output multi-processor communication state */
    always_comb begin
        if (mpc_state == MPC_STANDBY) begin
            rx_standby_flag_o = 1'b1;
        end else begin
            rx_standby_flag_o = 1'b0;
        end
    end

    assign rx_mpc_match1_flag_o = mpc_match1_flag;
    assign rx_mpc_match2_flag_o = mpc_match2_flag;

    /* Output IDLE state */
    assign rx_idle_flag_o = idle_flag;

    /* Output LIN break state */
    assign rx_lin_break_flag_o = lin_break_flag;

    /* Output error state */
    assign rx_overflow_flag_o = overflow_flag;
    assign rx_noise_flag_o = noise_flag;
    assign rx_framing_error_flag_o = framing_error_flag;
    assign rx_parity_error_flag_o = parity_error_flag;

    /* Output RTS (mode 1) */
    assign rx_rts_mode1_o = rx_rts_mode1_en_i & !rts_mode1_req;

endmodule

