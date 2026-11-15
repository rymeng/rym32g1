`timescale 1ns / 1ps

module bus_icc_default_slave (
    input  logic       hclk_i,
    input  logic       hreset_n_i,
    input  logic       hsel_i,
    input  logic       htrans_i,
    input  logic       hready_i,
    output logic       hreadyout_o,
    output logic [1:0] hresp_o
);
    import bus_icc_pkg::*;

    /* Generate address phase invalid signal */
    logic addr_invalid;

    assign addr_invalid = hsel_i && htrans_i && hready_i;

    /* Output HREADYOUT signals */
    logic       hreadyout;
    logic       hreadyout_next;

    always_comb begin
        if (hreadyout) begin
            hreadyout_next = !addr_invalid;
        end else begin
            hreadyout_next = 1'b1;
        end
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            hreadyout <= 1'b1;
        end else begin
            hreadyout <= hreadyout_next;
        end
    end

    assign hreadyout_o = hreadyout;

    /* Output HRESP signals */
    logic [1:0] hresp;
    logic [1:0] hresp_next;

    always_comb begin
        if (addr_invalid) begin
            hresp_next = HRESP_ERROR;
        end else begin
            hresp_next = HRESP_OKAY;
        end
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            hresp <= HRESP_OKAY;
        end else if (hreadyout) begin
            hresp <= hresp_next;
        end
    end

    assign hresp_o = hresp;

endmodule
