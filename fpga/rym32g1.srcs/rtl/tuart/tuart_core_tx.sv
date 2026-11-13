`timescale 1ns / 1ps

module tuart_core_tx (
    input logic         clk_i,
    input logic         rst_n_i,
    input logic         tx_en_i,
    input logic [7:0]   data_i,
    input logic         data_write_strobe_i,
    input logic [5:0]   osr_i,
    input logic [15:0]  div_i,
    input logic [2:0]   data_bits_i,
    input logic         parity_en_i,
    input logic         parity_type_i,
    input logic         stop_bits_i,
    input logic [31:0]  start_bit_noise_idx_i,
    input logic [255:0] data_bit_noise_idx_i,
    input logic [31:0]  parity_code_noise_idx_i,
    input logic [63:0]  stop_bit_noise_idx_i,
    input logic         noise_injection_en_i,
    input logic         parity_err_injection_en_i,
    input logic [1:0]   frame_err_injection_en_i,
    output logic         data_reg_empty_o,
    output logic         xfer_complete_o,
    output logic         txd_o
);
    /* FSM state */
    logic [4:0] state;

    localparam IDLE   = 5'b00001;
    localparam START  = 5'b00010;
    localparam DATA   = 5'b00100;
    localparam PARITY = 5'b01000;
    localparam STOP   = 5'b10000;

    /* Lock band rate parameter */
    logic  [5:0] osr;
    logic [15:0] div;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            osr <= 6'h08;
            div <= 16'h0001;
        end else if (!tx_en_i && state == IDLE) begin
            osr <= osr_i;
            div <= div_i;
        end
    end

    /* Generate tick */
    logic  [5:0] osr_calib;
    logic [15:0] div_calib;
    logic        sampling_tick;
    logic        bit_tick;

    tuart_baud_generator tuart_baud_generator_inst (
        .clk_i           (clk_i),
        .rst_n_i         (rst_n_i),
        .osr_i           (osr),
        .div_i           (div),
        .osr_calib_o     (osr_calib),
        .div_calib_o     (div_calib),
        .sampling_tick_o (sampling_tick),
        .bit_tick_o      (bit_tick)
    );

    /* Lock frame format parameters */
    logic [2:0] data_bits;
    logic       parity_en;
    logic       parity_type;
    logic       stop_bits;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            data_bits <= 3'b111;
            parity_en <= 1'b0;
            parity_type <= 1'b0;
            stop_bits <= 1'b0;
        end else begin
            if (!tx_en_i && state == IDLE) begin
                data_bits <= data_bits_i;
                parity_en <= parity_en_i;
                parity_type <= parity_type_i;
                stop_bits <= stop_bits_i;
            end
        end
    end

    /* Create frame */
    logic  [7:0] data_reg;
    logic [11:0] frame_reg;
    logic        parity_code;

    always_comb begin
        parity_code =
            ^(data_reg & (8'hFF >> (3'h7 - data_bits))) ^ (~parity_type);
    end

    always_comb begin
        case (data_bits)
            3'b000: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 7'b0, data_reg[0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 7'b0, data_reg[0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 7'b0, data_reg[0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 7'b0, data_reg[0], 1'b0};
                    end
                endcase
            end
            3'b001: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 6'b0, data_reg[1:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 6'b0, data_reg[1:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 6'b0, data_reg[1:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 6'b0, data_reg[1:0], 1'b0};
                    end
                endcase
            end
            3'b010: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 5'b0, data_reg[2:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 5'b0, data_reg[2:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 5'b0, data_reg[2:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 5'b0, data_reg[2:0], 1'b0};
                    end
                endcase
            end
            3'b011: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 4'b0, data_reg[3:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 4'b0, data_reg[3:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 4'b0, data_reg[3:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 4'b0, data_reg[3:0], 1'b0};
                    end
                endcase
            end
            3'b100: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 3'b0, data_reg[4:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 3'b0, data_reg[4:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 3'b0, data_reg[4:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 3'b0, data_reg[4:0], 1'b0};
                    end
                endcase
            end
            3'b101: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 2'b0, data_reg[5:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 2'b0, data_reg[5:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 2'b0, data_reg[5:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 2'b0, data_reg[5:0], 1'b0};
                    end
                endcase
            end
            3'b110: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, 1'b0, data_reg[6:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, 1'b0, data_reg[6:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, 1'b0, data_reg[6:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, 1'b0, data_reg[6:0], 1'b0};
                    end
                endcase
            end
            3'b111: begin
                case ({stop_bits, parity_en})
                    2'b00: begin
                        frame_reg =
                            {2'b01, 1'b0, data_reg[7:0], 1'b0};
                    end
                    2'b01: begin
                        frame_reg =
                            {2'b01, parity_code, data_reg[7:0], 1'b0};
                    end
                    2'b10: begin
                        frame_reg =
                            {2'b11, 1'b0, data_reg[7:0], 1'b0};
                    end
                    2'b11: begin
                        frame_reg =
                            {2'b11, parity_code, data_reg[7:0], 1'b0};
                    end
                endcase
            end
            default: begin
                frame_reg = {2'b01, 1'b0, 8'b0, 1'b0};
            end
        endcase
    end

    /* Create frame with error */
    logic [11:0] err_mask;
    logic [11:0] frame_with_err_reg;

    always_comb begin
        err_mask = 12'b0;
        if (parity_err_injection_en_i)
            err_mask[9] = 1'b1;
        if (frame_err_injection_en_i[0])
            err_mask[10] = 1'b1;
        if (frame_err_injection_en_i[1])
            err_mask[11] = 1'b1;
    end

    always_comb begin
        frame_with_err_reg = frame_reg ^ err_mask;
    end

    /* Create sampling point sequence */
    logic [383:0] sampling_point_seq_with_err_reg;

    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin
            assign sampling_point_seq_with_err_reg[32 * i +: 32] =
                {32{frame_with_err_reg[i]}};
        end
    endgenerate

    /* Create sampling point sequence with noise */
    logic [383:0] noise_mask;
    logic [383:0] sampling_point_seq_with_err_with_noise_reg;

    always_comb begin
        noise_mask = {
            stop_bit_noise_idx_i,
            parity_code_noise_idx_i,
            data_bit_noise_idx_i,
            start_bit_noise_idx_i
        };
    end

    always_comb begin
        if (noise_injection_en_i) begin
            sampling_point_seq_with_err_with_noise_reg =
                sampling_point_seq_with_err_reg ^ noise_mask;
        end else begin
            sampling_point_seq_with_err_with_noise_reg =
                sampling_point_seq_with_err_reg;
        end
    end

    /* FSM logic */
    logic [383:0] shift_reg;
    logic         data_reg_valid;
    logic   [4:0] sampling_point_cnt;
    logic   [2:0] data_bits_cnt;
    logic   [1:0] stop_bits_cnt;
    logic         txd;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
            data_reg <= 8'b0;
            shift_reg <= 384'b0;
            data_reg_valid <= 1'b0;
            sampling_point_cnt <= 5'b0;
            data_bits_cnt <= 3'b0;
            stop_bits_cnt <= 2'b0;
            txd <= 1'b1;
        end else begin
            if (data_write_strobe_i) begin
                data_reg <= data_i;
                data_reg_valid <= 1'b1;
            end

            case (state)
                IDLE: begin
                    if (tx_en_i && data_reg_valid) begin
                        state <= START;
                        shift_reg <= sampling_point_seq_with_err_with_noise_reg;
                        if (!data_write_strobe_i) begin
                            data_reg_valid <= 1'b0;
                        end
                        sampling_point_cnt <= 5'b0;
                        data_bits_cnt <= 3'b0;
                        stop_bits_cnt <= 2'b0;
                    end
                    txd <= 1'b1;
                end

                START: begin
                    if (sampling_tick) begin
                        if (sampling_point_cnt == osr_calib - 1) begin
                            state <= DATA;
                            sampling_point_cnt <= 5'b0;
                            data_bits_cnt <= 3'b0;
                        end else begin
                            sampling_point_cnt <= sampling_point_cnt + 1;
                        end
                        txd <= shift_reg[sampling_point_cnt];
                    end
                end

                DATA: begin
                    if (sampling_tick) begin
                        if (sampling_point_cnt == osr_calib - 1) begin
                            if (data_bits_cnt == data_bits) begin
                                if (parity_en)
                                    state <= PARITY;
                                else begin
                                    state <= STOP;
                                    stop_bits_cnt <= 2'b0;
                                end
                            end else begin
                                data_bits_cnt <= data_bits_cnt + 1;
                            end
                            sampling_point_cnt <= 5'b0;
                        end else begin
                            sampling_point_cnt <= sampling_point_cnt + 1;
                        end
                        txd <= shift_reg[
                            ((1 + data_bits_cnt) << 5) + sampling_point_cnt
                        ];
                    end
                end

                PARITY : begin
                    if (sampling_tick) begin
                        if (sampling_point_cnt == osr_calib - 1) begin
                            state <= STOP;
                            sampling_point_cnt <= 5'b0;
                            stop_bits_cnt <= 2'b0;
                        end else begin
                            sampling_point_cnt <= sampling_point_cnt + 1;
                        end
                        txd <= shift_reg[(9 << 5) + sampling_point_cnt];
                    end
                end

                STOP : begin
                    if (sampling_tick) begin
                        if (sampling_point_cnt == osr_calib - 1) begin
                            if (stop_bits_cnt == stop_bits) begin
                                if (tx_en_i && data_reg_valid) begin
                                    state <= START;
                                    shift_reg <= sampling_point_seq_with_err_with_noise_reg;
                                    if (!data_write_strobe_i) begin
                                        data_reg_valid <= 1'b0;
                                    end
                                    data_bits_cnt <= 3'b0;
                                    stop_bits_cnt <= 2'b0;
                                end else begin
                                    state <= IDLE;
                                end
                            end else begin
                                stop_bits_cnt <= stop_bits_cnt + 1;
                            end
                            sampling_point_cnt <= 5'b0;
                        end else begin
                            sampling_point_cnt <= sampling_point_cnt + 1;
                        end
                        txd <= shift_reg[
                            ((10 + stop_bits_cnt) << 5) + sampling_point_cnt
                        ];
                    end
                end

                default: begin
                    state <= IDLE;
                    txd <= 1'b1;
                end
            endcase
        end
    end

    /* Output data register empty flag */
    assign data_reg_empty_o = ~data_reg_valid;

    /* Output transfer complete flag */
    assign xfer_complete_o = ~data_reg_valid && (state == IDLE);

    /* Output TXD */
    assign txd_o = txd;

endmodule
