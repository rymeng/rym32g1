`timescale 1ns / 1ps

module flash_model_top #(
    parameter ADDR_WIDTH         = 14,
    /* Default bank erase time: 15 ms @ 50 MHz */
    parameter BANK_ERASE_TICKS   = 32'd745904,
    /* Default sector erase time: 15 ms @ 50 MHz */
    parameter SECTOR_ERASE_TICKS = 32'd749744,
    /* Default page programming time: 80 us @ 50 MHz */
    parameter PROGRAM_TICKS      = 32'd3993
)(
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
    output logic [31:0] hrdata_o,
/* FMC access interface */
    input logic        bank_erase_req_i,
    input logic        sector_erase_req_i,
    input logic [5:0]  sector_erase_sector_idx_i,
    input logic        program_en_i,
    output logic        busy_o,
    output logic        ops_done_o,
    output logic        program_precheck_err_o,
    output logic        program_unaligned_o,
    output logic        program_pending_o
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

    /* Generate transfer valid / error flags */
    logic xfer_valid;
    logic xfer_error;

    assign xfer_valid = addr_valid & size_valid & addr_aligned;
    assign xfer_error = addr_valid & ~xfer_valid;

    /* Generate read / write transfer flags */
    logic read_xfer_valid;
    (* mark_debug = "true" *) logic write_xfer_valid;

    assign read_xfer_valid = xfer_valid & ~hwrite_i;
    assign write_xfer_valid = xfer_valid & hwrite_i & (hsize_i == 3'b010);

    /* Generate flash model read signals */
    logic read_strobe;
    logic [(ADDR_WIDTH - 1):0] read_word_idx;

    assign read_strobe = read_xfer_valid;
    assign read_word_idx = haddr_i[(ADDR_WIDTH + 1):2];

    /* Generate flash model program signals */
    (* mark_debug = "true" *) logic                      program_strobe;
    (* mark_debug = "true" *) logic [(ADDR_WIDTH + 1):3] program_page_idx;
    (* mark_debug = "true" *) logic                      program_word_idx;

    always_ff @ (posedge hclk_i) begin
        program_strobe <= write_xfer_valid;

        if (write_xfer_valid) begin
            program_page_idx <= haddr_i[(ADDR_WIDTH + 1):3];
            program_word_idx <= haddr_i[2];
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
                hreadyout_o = 1'b1;
            end
        endcase
    end

    /* Flash model core sub-system */
    flash_model_core #(
        .ADDR_WIDTH                (ADDR_WIDTH),
        .SECTOR_ERASE_TICKS        (SECTOR_ERASE_TICKS),
        .BANK_ERASE_TICKS          (BANK_ERASE_TICKS),
        .PROGRAM_TICKS             (PROGRAM_TICKS)
    ) flash_model_core_subsystem (
        .clk_i                     (hclk_i),
        .rst_n_i                   (hreset_n_i),
        .read_strobe_i             (read_strobe),
        .read_word_idx_i           (read_word_idx),
        .read_data_o               (hrdata_o),
        .bank_erase_req_i          (bank_erase_req_i),
        .sector_erase_req_i        (sector_erase_req_i),
        .sector_erase_sector_idx_i (sector_erase_sector_idx_i),
        .program_strobe_i          (program_strobe),
        .program_en_i              (program_en_i),
        .program_page_idx_i        (program_page_idx),
        .program_word_idx_i        (program_word_idx),
        .program_data_i            (hwdata_i),
        .busy_o                    (busy_o),
        .ops_done_o                (ops_done_o),
        .program_pending_o         (program_pending_o),
        .program_unaligned_o       (program_unaligned_o),
        .program_precheck_err_o    (program_precheck_err_o)
    );

endmodule
