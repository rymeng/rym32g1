`timescale 1ns / 1ps

module rcc_top (
/* AHB slave device interface */
    input logic        hclk_i,
    input logic        hreset_n_i,
    input logic        hsel_i,
    input logic [31:0] haddr_i,
    input logic        hwrite_i,
    input logic [2:0]  hsize_i,
    input logic [3:0]  hmaster_i,
    input logic [1:0]  htrans_i,
    input logic [2:0]  hburst_i,
    input logic [3:0]  hprot_i,
    input logic        hmastlock_i,
    input logic        hready_i,
    input logic [31:0] hwdata_i,
    output logic         hreadyout_o,
    output logic         hresp_o,
    output logic  [31:0] hrdata_o,
/* Flash Model Main Bank */
    output logic        hclk_flash_o,
/* SRAM Model */
    output logic        hclk_sram_o,
/* GPIO A */
    output logic        hclk_gpioa_o,
    output logic        gpioa_reset_request_o,
/* GPIO B */
    output logic        hclk_gpiob_o,
    output logic        gpiob_reset_request_o,
/* FMC */
    output logic        hclk_fmc_o,
/* AHB to APB bridge */
    output logic        hclk_apb1_br_o,
/* UART 1 */
    output logic        uart1_reset_request_o,
/* UART 2 */
    output logic        uart2_reset_request_o,
/* TUART 1 */
    output logic        tuart1_reset_request_o
);
    /* Generate address phase valid flag */
    logic addr_valid;

    assign addr_valid = hsel_i & htrans_i[1] & hready_i;

    /* Generate transfer size valid flag */
    logic size_valid;

    assign size_valid = ~hsize_i[2];

    /* Generate transfer address valid (aligned) flag */
    logic addr_aligned;

    assign addr_aligned =
        (hsize_i == 3'b000) ? 1'b1 :
        (hsize_i == 3'b001) ? ~(haddr_i[0]) :
        (hsize_i == 3'b010) ? ~(|haddr_i[1:0]) : 1'b0;

    /* Generate read address phase occurrence flag */
    logic read_addr_phase;

    assign read_addr_phase =
        hsel_i & htrans_i[1] & size_valid & addr_aligned & ~hwrite_i;

    /* Generate transfer valid / error flags */
    logic xfer_valid;
    logic xfer_error;

    assign xfer_valid = addr_valid & size_valid & addr_aligned;
    assign xfer_error = addr_valid & ~xfer_valid;

    /* Generate read / write transfer flags */
    logic read_xfer_valid;
    logic write_xfer_valid;

    assign read_xfer_valid = xfer_valid & ~hwrite_i;
    assign write_xfer_valid = xfer_valid & hwrite_i;

    /* Generate byte lanes mask */
    logic [3:0] byte_mask;

    always_comb begin
        case (hsize_i)
            3'b000: begin
                byte_mask = 4'b0001 << haddr_i[1:0];
            end

            3'b001: begin
                byte_mask = 4'b0011 << haddr_i[1:0];
            end

            3'b010: begin
                byte_mask = 4'b1111;
            end

            default: begin
                byte_mask = 4'b0000;
            end
        endcase
    end

    /* Latch the index and byte mask at the end of address phase */
    logic       write_valid;
    logic [3:0] write_mask;
    logic [7:0] write_index;

    always_ff @ (posedge hclk_i) begin
        write_valid <= write_xfer_valid;

        if (write_xfer_valid) begin
            write_mask <= byte_mask;
            write_index <= haddr_i[9:2];
        end
    end

    /* Generate read-write collision flag */
    logic read_write_xfer_collision;

    assign read_write_xfer_collision =
        read_addr_phase & write_valid & (write_index == haddr_i[9:2]);

    /* Registers */
    logic [31:0] ahben1;
    logic [31:0] apben1;
    logic [31:0] ahbrst1;
    logic [31:0] apbrst1;

    assign gpioa_reset_request_o = ahbrst1[0];
    assign gpiob_reset_request_o = ahbrst1[1];
    assign uart1_reset_request_o = apbrst1[0];
    assign uart2_reset_request_o = apbrst1[1];
    assign tuart1_reset_request_o = apbrst1[2];

    /* Store the data at the end of data phase */
    always_ff @ (posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            ahben1 <= 32'h0000_0000;
            apben1 <= 32'h0000_0000;
            ahbrst1 <= 32'h0000_0000;
            apbrst1 <= 32'h0000_0000;
        end else begin
            if (write_valid) begin
                case (write_index)
                    8'h10: begin
                        if (write_mask[0]) begin
                            ahben1[7:0] <= hwdata_i[7:0];
                        end
                        if (write_mask[1]) begin
                            ahben1[15:8] <= hwdata_i[15:8];
                        end
                        if (write_mask[2]) begin
                            ahben1[23:16] <= hwdata_i[23:16];
                        end
                        if (write_mask[3]) begin
                            ahben1[31:24] <= hwdata_i[31:24];
                        end
                    end

                    8'h11: begin
                        if (write_mask[0]) begin
                            apben1[7:0] <= hwdata_i[7:0];
                        end
                        if (write_mask[1]) begin
                            apben1[15:8] <= hwdata_i[15:8];
                        end
                        if (write_mask[2]) begin
                            apben1[23:16] <= hwdata_i[23:16];
                        end
                        if (write_mask[3]) begin
                            apben1[31:24] <= hwdata_i[31:24];
                        end
                    end

                    8'h20: begin
                        if (write_mask[0]) begin
                            ahbrst1[7:0] <= hwdata_i[7:0];
                        end
                        if (write_mask[1]) begin
                            ahbrst1[15:8] <= hwdata_i[15:8];
                        end
                        if (write_mask[2]) begin
                            ahbrst1[23:16] <= hwdata_i[23:16];
                        end
                        if (write_mask[3]) begin
                            ahbrst1[31:24] <= hwdata_i[31:24];
                        end
                    end

                    8'h21: begin
                        if (write_mask[0]) begin
                            apbrst1[7:0] <= hwdata_i[7:0];
                        end
                        if (write_mask[1]) begin
                            apbrst1[15:8] <= hwdata_i[15:8];
                        end
                        if (write_mask[2]) begin
                            apbrst1[23:16] <= hwdata_i[23:16];
                        end
                        if (write_mask[3]) begin
                            apbrst1[31:24] <= hwdata_i[31:24];
                        end
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    /* Output data at the end of address phase */
    always_ff @ (posedge hclk_i) begin
        if (read_xfer_valid) begin
            case (haddr_i[9:2])
                8'h10: begin
                    hrdata_o <= {29'b0, ahben1[1:0]};
                end

                8'h11: begin
                    hrdata_o <= {20'b0, apben1[11], 8'b0, apben1[2:0]};
                end

                8'h20: begin
                    hrdata_o <= {29'b0, ahbrst1[1:0]};
                end

                8'h21: begin
                    hrdata_o <= {29'b0, apbrst1[2:0]};
                end

                default: begin
                    hrdata_o <= 32'h0000_0000;
                end
            endcase
        end
    end

    /* Control AHB slave response state */
    localparam RESP_OKAY = 3'b001;
    localparam RESP_ERR1 = 3'b010;
    localparam RESP_ERR2 = 3'b100;

    logic [2:0] resp_state;

    always_ff @ (posedge hclk_i) begin
        case (resp_state)
            RESP_OKAY: begin
                if (xfer_error) begin
                    resp_state <= RESP_ERR1;
                end
            end

            RESP_ERR1: begin
                resp_state <= RESP_ERR2;
            end

            RESP_ERR2: begin
                if (xfer_error) begin
                    resp_state <= RESP_ERR1;
                end else begin
                    resp_state <= RESP_OKAY;
                end
            end

            default: begin
                resp_state <= RESP_OKAY;
            end
        endcase
    end

    /* Output HRESP and HREADYOUT signals */
    always_comb begin
        case (resp_state)
            RESP_ERR1: begin
                hresp_o = 1'b1;
                hreadyout_o = 1'b0;
            end

            RESP_ERR2: begin
                hresp_o = 1'b1;
                hreadyout_o = 1'b1;
            end

            default: begin
                hresp_o = 1'b0;
                hreadyout_o = ~read_write_xfer_collision;
            end
        endcase
    end

    /* RCC sub-system */
    rcc_core rcc_core_inst (
        .hclk_master_i      (hclk_i),
        .hclk_flash_o     (hclk_flash_o),
        .hclk_sram_o     (hclk_sram_o),
        .hclk_gpioa_o     (hclk_gpioa_o),
        .hclk_gpiob_o     (hclk_gpiob_o),
        .hclk_fmc_o     (hclk_fmc_o),
        .hclk_apb1_br_o     (hclk_apb1_br_o)
    );

endmodule
