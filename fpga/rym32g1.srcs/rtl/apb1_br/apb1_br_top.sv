`timescale 1ns / 1ps

module apb1_br_top #(
    parameter [31:0] APB_BASE_ADDR   = 32'h4000_0000,
    parameter [31:0] APB_LIMIT_ADDR  = 32'h4001_FFFF,
    parameter [31:0] APB_SLAVE_SIZE  = 32'h0000_0400,
    parameter [31:0] APB_WWDG_BASE   = 32'h4000_0000,
    parameter [31:0] APB_UART1_BASE  = 32'h4000_1000,
    parameter [31:0] APB_UART2_BASE  = 32'h4001_1400,
    parameter [31:0] APB_TUART1_BASE = 32'h4001_1800
) (
    /* AHB slave interface */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    input  logic        hsel_i,
    input  logic [31:0] haddr_i,
    input  logic        hwrite_i,
    input  logic [2:0]  hsize_i,
    input  logic [3:0]  hmaster_i,
    input  logic [1:0]  htrans_i,
    input  logic [2:0]  hburst_i,
    input  logic [3:0]  hprot_i,
    input  logic        hmastlock_i,
    input  logic        hready_i,
    input  logic [31:0] hwdata_i,
    /* APB master interface */
    input  logic        pclken_i,
    output logic        hreadyout_o,
    output logic        hresp_o,
    output logic [31:0] hrdata_o,
    output logic        penable_o,
    output logic [31:0] paddr_o,
    output logic        pwrite_o,
    output logic [3:0]  pstrb_o,
    output logic [2:0]  pprot_o,
    output logic [31:0] pwdata_o,
    /* UART1 */
    output logic        psel_uart1_o,
    input  logic        pready_uart1_i,
    input  logic        pslverr_uart1_i,
    input  logic [31:0] prdata_uart1_i,
    /* UART2 */
    output logic        psel_uart2_o,
    input  logic        pready_uart2_i,
    input  logic        pslverr_uart2_i,
    input  logic [31:0] prdata_uart2_i,
    /* TUART1 */
    output logic        psel_tuart1_o,
    input  logic        pready_tuart1_i,
    input  logic        pslverr_tuart1_i,
    input  logic [31:0] prdata_tuart1_i,
    /* WWDG */
    output logic        psel_wwdg_o,
    input  logic        pready_wwdg_i,
    input  logic        pslverr_wwdg_i,
    input  logic [31:0] prdata_wwdg_i
);
    /* Generate address phase valid signal */
    logic addr_valid;

    assign addr_valid = hsel_i && htrans_i[1] && hready_i;

    /* Generate address in APB range signal */
    logic addr_in_range;

    always_comb begin
        if ((haddr_i >= APB_BASE_ADDR) && (haddr_i <= APB_LIMIT_ADDR)) begin
            addr_in_range = 1'b1;
        end else begin
            addr_in_range = 1'b0;
        end
    end

    /* Generate address aligned signal */
    logic addr_aligned;

    always_comb begin
        if (hsize_i == 3'b000) begin
            addr_aligned = 1'b1;
        end else if (hsize_i == 3'b001) begin
            addr_aligned = !haddr_i[0];
        end else if (hsize_i == 3'b010) begin
            addr_aligned = (haddr_i[1:0] == 2'b00);
        end else begin
            addr_aligned = 1'b0;
        end
    end

    /* Generate transfer size valid signal */
    logic size_valid;

    assign size_valid = !hsize_i[2];

    /* Generate transfer valid / error signal */
    logic xfer_valid;
    logic xfer_error;

    assign xfer_valid = addr_valid && size_valid && addr_aligned && addr_in_range;
    assign xfer_error = addr_valid && !(size_valid && addr_aligned && addr_in_range);

    /* Generate PSTRB signal */
    logic [3:0] pstrb;
    logic [3:0] pstrb_next;

    always_comb begin
        case (hsize_i)
            3'b000: pstrb_next = 4'b0001 << haddr_i[1:0];
            3'b001: pstrb_next = 4'b0011 << haddr_i[1:0];
            3'b010: pstrb_next = 4'b1111;
            default: pstrb_next = 4'b0000;
        endcase
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            pstrb <= 4'b0000;
        end else begin
            if (xfer_valid) begin
                pstrb <= hwrite_i ? pstrb_next : 4'b0000;
            end
        end
    end

    /* Generate PADDR & PWRITE & PPROT signal */
    logic [31:0] paddr;
    logic        pwrite;
    logic [2:0]  pprot;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            paddr <= 32'h0000_0000;
            pwrite <= 1'b0;
            pprot <= 3'b000;
        end else begin
            if (xfer_valid) begin
                paddr <= haddr_i;
                pwrite <= hwrite_i;
                pprot <= 3'b000;
            end
        end
    end

    /* Generate slave selected state signal */
    logic uart1_selected;
    logic uart2_selected;
    logic tuart1_selected;
    logic wwdg_selected;
    logic none_selected;

    always_comb begin
        uart1_selected = 1'b0;
        uart2_selected = 1'b0;
        tuart1_selected = 1'b0;
        wwdg_selected = 1'b0;
        none_selected = 1'b0;

        if ((paddr >= APB_UART1_BASE) && (paddr < APB_UART1_BASE + APB_SLAVE_SIZE)) begin
            uart1_selected = 1'b1;
        end else if ((paddr >= APB_UART2_BASE) && (paddr < APB_UART2_BASE + APB_SLAVE_SIZE)) begin
            uart2_selected = 1'b1;
        end else if ((paddr >= APB_TUART1_BASE) && (paddr < APB_TUART1_BASE + APB_SLAVE_SIZE)) begin
            tuart1_selected = 1'b1;
        end else if ((paddr >= APB_WWDG_BASE) && (paddr < APB_WWDG_BASE + APB_SLAVE_SIZE)) begin
            wwdg_selected = 1'b1;
        end else begin
            none_selected = 1'b1;
        end
    end

    /* Select APB slave response signal */
    logic [31:0] prdata;
    logic        pready;
    logic        pslverr;

    always_comb begin
        prdata = 32'h0000_0000;
        pready = 1'b1;
        pslverr = 1'b1;

        if (uart1_selected) begin
            prdata = prdata_uart1_i;
            pready = pready_uart1_i;
            pslverr = pslverr_uart1_i;
        end else if (uart2_selected) begin
            prdata = prdata_uart2_i;
            pready = pready_uart2_i;
            pslverr = pslverr_uart2_i;
        end else if (tuart1_selected) begin
            prdata = prdata_tuart1_i;
            pready = pready_tuart1_i;
            pslverr = pslverr_tuart1_i;
        end else if (wwdg_selected) begin
            prdata = prdata_wwdg_i;
            pready = pready_wwdg_i;
            pslverr = pslverr_wwdg_i;
        end
    end

    /* FSM */
    localparam [6:0] IDLE   = 7'b0000001;
    localparam [6:0] WAIT   = 7'b0000010;
    localparam [6:0] SETUP  = 7'b0000100;
    localparam [6:0] ACCESS = 7'b0001000;
    localparam [6:0] OK     = 7'b0010000;
    localparam [6:0] ERR1   = 7'b0100000;
    localparam [6:0] ERR2   = 7'b1000000;

    logic [6:0] state;
    logic [6:0] state_next;

    logic [31:0] hrdata;
    logic        hreadyout;
    logic        hresp;
    logic        penable;
    logic        psel_uart1;
    logic        psel_uart2;
    logic        psel_tuart1;
    logic        psel_wwdg;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    always_comb begin
        case (state)
            IDLE: begin
                if (xfer_error) begin
                    state_next = ERR1;
                end else if (xfer_valid && pclken_i) begin
                    state_next = SETUP;
                end else if (xfer_valid) begin
                    state_next = WAIT;
                end else begin
                    state_next = IDLE;
                end
            end

            WAIT: begin
                if (pclken_i) begin
                    state_next = SETUP;
                end else begin
                    state_next = WAIT;
                end
            end

            SETUP: begin
                if (pclken_i) begin
                    state_next = ACCESS;
                end else begin
                    state_next = SETUP;
                end
            end

            ACCESS: begin
                if (pready && pclken_i) begin
                    if (pslverr) begin
                        state_next = ERR1;
                    end else begin
                        state_next = OK;
                    end
                end else begin
                    state_next = ACCESS;
                end
            end

            OK: begin
                if (xfer_valid && pclken_i) begin
                    state_next = SETUP;
                end else if (xfer_valid) begin
                    state_next = WAIT;
                end else begin
                    state_next = IDLE;
                end
            end

            ERR1: begin
                state_next = ERR2;
            end

            ERR2: begin
                if (xfer_error) begin
                    state_next = ERR1;
                end else if (xfer_valid && pclken_i) begin
                    state_next = SETUP;
                end else if (xfer_valid) begin
                    state_next = WAIT;
                end else begin
                    state_next = IDLE;
                end
            end

            default: begin
                state_next = IDLE;
            end
        endcase
    end

    always_comb begin
        case (state)
            IDLE: begin
                hreadyout = 1'b1;
                hresp = 1'b0;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end

            WAIT: begin
                hreadyout = 1'b0;
                hresp = 1'b0;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end

            SETUP: begin
                hreadyout = 1'b0;
                hresp = 1'b0;
                penable = 1'b0;
                psel_uart1 = uart1_selected;
                psel_uart2 = uart2_selected;
                psel_tuart1 = tuart1_selected;
                psel_wwdg = wwdg_selected;
            end

            ACCESS: begin
                hreadyout = 1'b0;
                hresp = 1'b0;
                penable = 1'b1;
                psel_uart1 = uart1_selected;
                psel_uart2 = uart2_selected;
                psel_tuart1 = tuart1_selected;
                psel_wwdg = wwdg_selected;
            end

            OK: begin
                hreadyout = 1'b1;
                hresp = 1'b0;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end

            ERR1: begin
                hreadyout = 1'b0;
                hresp = 1'b1;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end

            ERR2: begin
                hreadyout = 1'b1;
                hresp = 1'b1;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end

            default: begin
                hreadyout = 1'b1;
                hresp = 1'b0;
                penable = 1'b0;
                psel_uart1 = 1'b0;
                psel_uart2 = 1'b0;
                psel_tuart1 = 1'b0;
                psel_wwdg = 1'b0;
            end
        endcase
    end

    /* Generate HRDATA signal */
    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            hrdata <= 32'h0000_0000;
        end else begin
            if (state_next == OK) begin
                hrdata <= prdata;
            end
        end
    end

    /* Output signals as APB master device */
    assign psel_uart1_o = psel_uart1;
    assign psel_uart2_o = psel_uart2;
    assign psel_tuart1_o = psel_tuart1;
    assign psel_wwdg_o = psel_wwdg;
    assign paddr_o = paddr;
    assign pwrite_o = pwrite;
    assign pwdata_o = hwdata_i;
    assign penable_o = penable;
    assign pstrb_o = pstrb;
    assign pprot_o = pprot;

    /* Output signals as AHB slave device */
    assign hrdata_o = hrdata;
    assign hreadyout_o = hreadyout;
    assign hresp_o = hresp;

endmodule
