`timescale 1ns / 1ps

module rst_gen_top #(
    parameter int REFCLK_READY_LIMIT = 1024,
    parameter int SYSRST_HOLD_LIMIT = 16
) (
    input  logic refclk_i,
    input  logic hsi_i,
    input  logic porst_n_i,
    input  logic xrst_n_i,
    input  logic hsi_ready_i,
    input  logic core_sysrst_req_i,
    input  logic gpioa_rst_req_i,
    input  logic gpiob_rst_req_i,
    input  logic uart1_rst_req_i,
    input  logic uart2_rst_req_i,
    input  logic tuart1_rst_req_i,
    input  logic wwdg_rst_req_i,
    output logic refrst_n_o,
    output logic porst_n_o,
    output logic sysrst_n_o,
    output logic flash_rst_n_o,
    output logic sram_rst_n_o,
    output logic gpioa_rst_n_o,
    output logic gpiob_rst_n_o,
    output logic fmc_rst_n_o,
    output logic apb_rst_n_o,
    output logic uart1_rst_n_o,
    output logic uart2_rst_n_o,
    output logic tuart1_rst_n_o
);
    /* Generate REFRSTn signal */
    (* ASYNC_REG = "TRUE" *) logic refrst_n_sync1;
    (* ASYNC_REG = "TRUE" *) logic refrst_n_sync2;

    always_ff @(posedge refclk_i or negedge porst_n_i) begin
        if (!porst_n_i) begin
            refrst_n_sync1 <= 1'b0;
            refrst_n_sync2 <= 1'b0;
        end else begin
            refrst_n_sync1 <= 1'b1;
            refrst_n_sync2 <= refrst_n_sync1;
        end
    end

    assign refrst_n_o = refrst_n_sync2;

    /* Synchronize HSI ready signal */
    (* ASYNC_REG = "TRUE" *) logic hsi_ready_sync1;
    (* ASYNC_REG = "TRUE" *) logic hsi_ready_sync2;

    always_ff @(posedge refclk_i or negedge refrst_n_o) begin
        if (!refrst_n_o) begin
            hsi_ready_sync1 <= 1'b0;
            hsi_ready_sync2 <= 1'b0;
        end else begin
            hsi_ready_sync1 <= hsi_ready_i;
            hsi_ready_sync2 <= hsi_ready_sync1;
        end
    end

    /* Generate PORSTn signal */
    logic [$clog2(REFCLK_READY_LIMIT + 1) - 1:0] refclk_ready_counter;
    logic                                        porst_n;

    always_ff @(posedge refclk_i or negedge refrst_n_o) begin
        if (!refrst_n_o) begin
            refclk_ready_counter <= '0;
            porst_n <= 1'b0;
        end else if (!hsi_ready_sync2) begin
            refclk_ready_counter <= '0;
            porst_n <= 1'b0;
        end else if (refclk_ready_counter < REFCLK_READY_LIMIT) begin
            refclk_ready_counter <= refclk_ready_counter + 1'b1;
            porst_n <= 1'b0;
        end else begin
            porst_n <= 1'b1;
        end
    end

    /* Synchronize & Output PORSTn signal */
    (* ASYNC_REG = "TRUE" *) logic porst_n_sync1;
    (* ASYNC_REG = "TRUE" *) logic porst_n_sync2;

    always_ff @(posedge hsi_i or negedge porst_n) begin
        if (!porst_n) begin
            porst_n_sync1 <= 1'b0;
            porst_n_sync2 <= 1'b0;
        end else begin
            porst_n_sync1 <= 1'b1;
            porst_n_sync2 <= porst_n_sync1;
        end
    end

    assign porst_n_o = porst_n_sync2;

    /* Generate XRSTn signal */
    (* ASYNC_REG = "TRUE" *) logic xrst_n_sync1;
    (* ASYNC_REG = "TRUE" *) logic xrst_n_sync2;

    logic xrst_n;

    always_ff @(posedge hsi_i or negedge porst_n_o) begin
        if (!porst_n_o) begin
            xrst_n_sync1 <= 1'b0;
            xrst_n_sync2 <= 1'b0;
        end else begin
            xrst_n_sync1 <= xrst_n_i;
            xrst_n_sync2 <= xrst_n_sync1;
        end
    end

    assign xrst_n = xrst_n_sync2;

    /* Stretch system reset (level) request signals */
    logic                                       core_sysrst_req_previous;
    logic                                       core_sysrst_req_rising_edge;
    logic                                       wwdg_rst_req_previous;
    logic                                       wwdg_rst_req_rising_edge;
    logic [$clog2(SYSRST_HOLD_LIMIT + 1) - 1:0] sysrst_hold_counter;

    assign core_sysrst_req_rising_edge = core_sysrst_req_i && !core_sysrst_req_previous;
    assign wwdg_rst_req_rising_edge = wwdg_rst_req_i && !wwdg_rst_req_previous;

    always_ff @(posedge hsi_i or negedge porst_n_o) begin
        if (!porst_n_o) begin
            core_sysrst_req_previous <= 1'b0;
            wwdg_rst_req_previous <= 1'b0;
            sysrst_hold_counter <= '0;
        end else begin
            core_sysrst_req_previous <= core_sysrst_req_i;
            wwdg_rst_req_previous <= wwdg_rst_req_i;

            if (core_sysrst_req_rising_edge || wwdg_rst_req_rising_edge) begin
                sysrst_hold_counter <= SYSRST_HOLD_LIMIT;
            end else if (sysrst_hold_counter != 0) begin
                sysrst_hold_counter <= sysrst_hold_counter - 1'b1;
            end
        end
    end

    /* Generate SYSRST request signal */
    logic sysrst_req;

    assign sysrst_req = !xrst_n || core_sysrst_req_i || wwdg_rst_req_i || (sysrst_hold_counter != 0);

    /* Synchronize & Output SYSRSTn signal */
    (* ASYNC_REG = "TRUE" *) logic sysrst_n_sync1;
    (* ASYNC_REG = "TRUE" *) logic sysrst_n_sync2;

    always_ff @(posedge hsi_i or negedge porst_n_o) begin
        if (!porst_n_o) begin
            sysrst_n_sync1 <= 1'b0;
            sysrst_n_sync2 <= 1'b0;
        end else if (sysrst_req) begin
            sysrst_n_sync1 <= 1'b0;
            sysrst_n_sync2 <= 1'b0;
        end else begin
            sysrst_n_sync1 <= 1'b1;
            sysrst_n_sync2 <= sysrst_n_sync1;
        end
    end

    assign sysrst_n_o = sysrst_n_sync2;

    /* Output system device reset signals */
    assign flash_rst_n_o = sysrst_n_o;
    assign sram_rst_n_o = sysrst_n_o;
    assign fmc_rst_n_o = sysrst_n_o;
    assign apb_rst_n_o = sysrst_n_o;

    /* Output normal device reset signals */
    logic gpioa_rst_n;
    logic gpiob_rst_n;
    logic uart1_rst_n;
    logic uart2_rst_n;
    logic tuart1_rst_n;

    always_ff @(posedge hsi_i or negedge sysrst_n_o) begin
        if (!sysrst_n_o) begin
            gpioa_rst_n <= 1'b0;
            gpiob_rst_n <= 1'b0;
            uart1_rst_n <= 1'b0;
            uart2_rst_n <= 1'b0;
            tuart1_rst_n <= 1'b0;
        end else begin
            gpioa_rst_n <= !gpioa_rst_req_i;
            gpiob_rst_n <= !gpiob_rst_req_i;
            uart1_rst_n <= !uart1_rst_req_i;
            uart2_rst_n <= !uart2_rst_req_i;
            tuart1_rst_n <= !tuart1_rst_req_i;
        end
    end

    assign gpioa_rst_n_o = gpioa_rst_n;
    assign gpiob_rst_n_o = gpiob_rst_n;
    assign uart1_rst_n_o = uart1_rst_n;
    assign uart2_rst_n_o = uart2_rst_n;
    assign tuart1_rst_n_o = tuart1_rst_n;

endmodule
