`timescale 1ns / 1ps

module pmu_core (
    input  logic clk_i,
    input  logic rst_n_i,
    input  logic debug_power_up_req_i,
    input  logic sleep_hold_ack_n_i,
    input  logic wkup_it_ctrl_en_ack_i,
    input  logic wkup_i,
    output logic debug_power_up_ack_o,
    output logic sleep_hold_req_n_o,
    output logic wkup_it_ctrl_en_req_o
);
    /* Reset synchronizer */
    (* ASYNC_REG = "TRUE" *) logic rst_n_sync1;
    (* ASYNC_REG = "TRUE" *) logic rst_n_sync2;
    logic rst_n;

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rst_n_sync1 <= 1'b0;
            rst_n_sync2 <= 1'b0;
        end else begin
            rst_n_sync1 <= 1'b1;
            rst_n_sync2 <= rst_n_sync1;
        end
    end

    assign rst_n = rst_n_sync2;

    /* Debug power-up handshake */
    (* ASYNC_REG = "TRUE" *) logic debug_power_up_req_sync1;
    (* ASYNC_REG = "TRUE" *) logic debug_power_up_req_sync2;

    always_ff @(posedge clk_i or negedge rst_n) begin
        if (!rst_n) begin
            debug_power_up_req_sync1 <= 1'b0;
            debug_power_up_req_sync2 <= 1'b0;
        end else begin
            debug_power_up_req_sync1 <= debug_power_up_req_i;
            debug_power_up_req_sync2 <= debug_power_up_req_sync1;
        end
    end

    assign debug_power_up_ack_o = debug_power_up_req_sync2;

    /* Phase 1 tie-offs */
    assign sleep_hold_req_n_o = 1'b1;
    assign wkup_it_ctrl_en_req_o = 1'b0;

endmodule
