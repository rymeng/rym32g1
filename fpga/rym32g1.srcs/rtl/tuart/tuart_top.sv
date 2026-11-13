`timescale 1ns / 1ps

module tuart_top (
/* APB slave device interface */
    input logic        pclk_i,
    input logic        preset_n_i,
    input logic        psel_i,
    input logic        penable_i,
    input logic [31:0] paddr_i,
    input logic        pwrite_i,
    input logic [3:0]  pstrb_i,
    input logic [2:0]  pprot_i,
    input logic [31:0] pwdata_i,
    output logic         pready_o,
    output logic         pslverr_o,
    output logic  [31:0] prdata_o,
/* AFIO signals */
    input logic        rxd_i,
    output logic        txd_o,
    output logic        swap_o
);
    /* Generate access phase flag */
    logic apb_access;

    assign apb_access = psel_i & penable_i;

    /* Generate read / write transfer valid flags */
    logic read_xfer_valid;
    logic write_xfer_valid;

    assign read_xfer_valid = apb_access & ~pwrite_i;
    assign write_xfer_valid = apb_access & pwrite_i;

    /* Registers */
    logic [31:0] brr;
    logic [31:0] cr1;
    logic [31:0] cr2;
    logic [31:0] nicr1;
    logic [31:0] nicr2;
    logic [31:0] nicr3;
    logic [31:0] nicr4;
    logic [31:0] nicr5;
    logic [31:0] nicr6;
    logic [31:0] nicr7;
    logic [31:0] nicr8;
    logic [31:0] nicr9;
    logic [31:0] nicr10;
    logic [31:0] nicr11;
    logic [31:0] nicr12;
    logic [31:0] tdr;
    logic [31:0] sr1;

    /* Store the data at the end of access phase */
    /* Generate TDR register write strobe at the end of access phase */
    logic tdr_write_strobe;

    always_ff @ (posedge pclk_i or negedge preset_n_i) begin
        if (!preset_n_i) begin
            brr <= 32'h0008_0001;
            cr1 <= 32'h0000_0007;
            cr2 <= 32'h0000_0000;
            nicr1 <= 32'h0000_0000;
            nicr2 <= 32'h0000_0000;
            nicr3 <= 32'h0000_0000;
            nicr4 <= 32'h0000_0000;
            nicr5 <= 32'h0000_0000;
            nicr6 <= 32'h0000_0000;
            nicr7 <= 32'h0000_0000;
            nicr8 <= 32'h0000_0000;
            nicr9 <= 32'h0000_0000;
            nicr10 <= 32'h0000_0000;
            nicr11 <= 32'h0000_0000;
            nicr12 <= 32'h0000_0000;
            tdr <= 32'h0000_0000;
            tdr_write_strobe <= 1'b0;
        end else begin
            tdr_write_strobe <= 1'b0;
            if (write_xfer_valid) begin
                case (paddr_i[9:2])
                    8'h00: begin
                        if (cr2[1:0] == 2'b00) begin
                            if (pstrb_i[0]) begin
                                brr[7:0] <= pwdata_i[7:0];
                            end
                            if (pstrb_i[1]) begin
                                brr[15:8] <= pwdata_i[15:8];
                            end
                            if (pstrb_i[2]) begin
                                brr[23:16] <= pwdata_i[23:16];
                            end
                            if (pstrb_i[3]) begin
                                brr[31:24] <= pwdata_i[31:24];
                            end
                        end else begin
                            brr <= brr;
                        end
                    end

                    8'h01: begin
                        if (cr2[1:0] == 2'b00) begin
                            if (pstrb_i[0]) begin
                                cr1[7:0] <= pwdata_i[7:0];
                            end
                            if (pstrb_i[1]) begin
                                cr1[15:8] <= pwdata_i[15:8];
                            end
                            if (pstrb_i[2]) begin
                                cr1[23:16] <= pwdata_i[23:16];
                            end
                            if (pstrb_i[3]) begin
                                cr1[31:24] <= pwdata_i[31:24];
                            end
                        end
                    end

                    8'h02: begin
                        if (pstrb_i[0]) begin
                            cr2[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            cr2[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            cr2[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            cr2[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h08: begin
                        if (pstrb_i[0]) begin
                            nicr1[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr1[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr1[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr1[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h09: begin
                        if (pstrb_i[0]) begin
                            nicr2[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr2[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr2[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr2[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0A: begin
                        if (pstrb_i[0]) begin
                            nicr3[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr3[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr3[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr3[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0B: begin
                        if (pstrb_i[0]) begin
                            nicr4[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr4[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr4[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr4[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0C: begin
                        if (pstrb_i[0]) begin
                            nicr5[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr5[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr5[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr5[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0D: begin
                        if (pstrb_i[0]) begin
                            nicr6[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr6[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr6[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr6[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0E: begin
                        if (pstrb_i[0]) begin
                            nicr7[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr7[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr7[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr7[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h0F: begin
                        if (pstrb_i[0]) begin
                            nicr8[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr8[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr8[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr8[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h10: begin
                        if (pstrb_i[0]) begin
                            nicr9[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr9[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr9[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr9[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h11: begin
                        if (pstrb_i[0]) begin
                            nicr10[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr10[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr10[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr10[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h12: begin
                        if (pstrb_i[0]) begin
                            nicr11[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr11[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr11[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr11[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h13: begin
                        if (pstrb_i[0]) begin
                            nicr12[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            nicr12[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            nicr12[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            nicr12[31:24] <= pwdata_i[31:24];
                        end
                    end

                    8'h18: begin
                        if (pstrb_i[0]) begin
                            tdr[7:0] <= pwdata_i[7:0];
                        end
                        if (pstrb_i[1]) begin
                            tdr[15:8] <= pwdata_i[15:8];
                        end
                        if (pstrb_i[2]) begin
                            tdr[23:16] <= pwdata_i[23:16];
                        end
                        if (pstrb_i[3]) begin
                            tdr[31:24] <= pwdata_i[31:24];
                        end
                        tdr_write_strobe <= 1'b1;
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    /* Output data during access phase */
    always_comb begin
        if (read_xfer_valid) begin
            case (paddr_i[9:2])
                8'h00: begin
                    prdata_o = {10'b0, brr[21:0]};
                end

                8'h01: begin
                    prdata_o = {16'b0, cr1[5:0]};
                end

                8'h02: begin
                    prdata_o = {30'b0, cr2[1:0]};
                end

                8'h08: begin
                    prdata_o = nicr1;
                end

                8'h09: begin
                    prdata_o = nicr2;
                end

                8'h0A: begin
                    prdata_o = nicr3;
                end

                8'h0B: begin
                    prdata_o = nicr4;
                end

                8'h0C: begin
                    prdata_o = nicr5;
                end

                8'h0D: begin
                    prdata_o = nicr6;
                end

                8'h0E: begin
                    prdata_o = nicr7;
                end

                8'h0F: begin
                    prdata_o = nicr8;
                end

                8'h10: begin
                    prdata_o = nicr9;
                end

                8'h11: begin
                    prdata_o = nicr10;
                end

                8'h12: begin
                    prdata_o = nicr11;
                end

                8'h13: begin
                    prdata_o = nicr12;
                end

                8'h18: begin
                    prdata_o = tdr;
                end

                8'h20: begin
                    prdata_o = sr1;
                end

                default: begin
                    prdata_o = 32'h0000_0000;
                end
            endcase
        end else begin
            prdata_o = 32'h0000_0000;
        end
    end

    /* Output ready and error response signals */
    always_comb begin
        pready_o  = apb_access;
        pslverr_o = 1'b0;
    end

    /* TUART TX sub-system */
    logic [255:0] nicr9_2;
    logic  [63:0] nicr12_11;
    logic         txrdy;
    logic         txc;

    assign nicr9_2 = {nicr9, nicr8, nicr7, nicr6, nicr5, nicr4, nicr3, nicr2};
    assign nicr12_11 = {nicr12, nicr11};

    tuart_core_tx tuart_core_tx_inst (
        .clk_i                     (pclk_i),
        .rst_n_i                   (preset_n_i),
        .tx_en_i                   (cr2[0]),
        .data_i                    (tdr[7:0]),
        .data_write_strobe_i       (tdr_write_strobe),
        .osr_i                     (brr[21:16]),
        .div_i                     (brr[15:0]),
        .data_bits_i               (cr1[2:0]),
        .parity_en_i               (cr1[3]),
        .parity_type_i             (cr1[4]),
        .stop_bits_i               (cr1[5]),
        .start_bit_noise_idx_i     (nicr1),
        .data_bit_noise_idx_i      (nicr9_2),
        .parity_code_noise_idx_i   (nicr10),
        .stop_bit_noise_idx_i      (nicr12_11),
        .noise_injection_en_i      (tdr[11]),
        .parity_err_injection_en_i (tdr[8]),
        .frame_err_injection_en_i  ({tdr[10], tdr[9]}),
        .data_reg_empty_o          (txrdy),
        .xfer_complete_o           (txc),
        .txd_o                     (txd_o)
    );

    always_comb begin
        sr1[31:2] = 30'b0;
        sr1[1] = txc;
        sr1[0] = txrdy;
    end

    /* IO controller sub-system */
    assign swap_o = 1'b0;

endmodule
