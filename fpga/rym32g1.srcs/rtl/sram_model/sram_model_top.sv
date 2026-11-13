`timescale 1ns / 1ps

module sram_model_top #(
    parameter ADDR_WIDTH = 8
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
    output logic  [31:0] hrdata_o
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
    logic                      write_valid;
    logic [3:0]                write_mask;
    logic [(ADDR_WIDTH + 1):2] write_index;

    always_ff @ (posedge hclk_i) begin
        write_valid <= write_xfer_valid;

        if (write_xfer_valid) begin
            write_mask <= byte_mask;
            write_index <= haddr_i[(ADDR_WIDTH + 1):2];
        end
    end

    /* Generate read-write collision flag */
    logic read_write_xfer_collision;

    assign read_write_xfer_collision =
        read_addr_phase & write_valid &
        (write_index == haddr_i[(ADDR_WIDTH + 1):2]);

    /* Memory unit block depth */
    localparam ADDR_LIMIT = 1 << ADDR_WIDTH;

    /* Memory unit */
    (* ram_style = "block", ram_decomp = "power" *) logic [31:0] unit [0:(ADDR_LIMIT - 1)];

    /* Store the data at the end of data phase */
    always_ff @ (posedge hclk_i) begin
        if (write_valid) begin
            if (write_mask[0]) begin
                unit[write_index][7:0] <= hwdata_i[7:0];
            end
            if (write_mask[1]) begin
                unit[write_index][15:8] <= hwdata_i[15:8];
            end
            if (write_mask[2]) begin
                unit[write_index][23:16] <= hwdata_i[23:16];
            end
            if (write_mask[3]) begin
                unit[write_index][31:24] <= hwdata_i[31:24];
            end
        end
    end

    /* Output data at the end of address phase */
    always_ff @ (posedge hclk_i) begin
        if (read_xfer_valid) begin
            hrdata_o <= unit[haddr_i[(ADDR_WIDTH + 1):2]];
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

endmodule
