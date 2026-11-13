`timescale 1ns / 1ps

module pmu_top (
    input  logic always_on_clk_i,
    input  logic always_on_rst_n_i,
    input  logic debug_power_up_req_i,
    input  logic sleep_hold_ack_n_i,
    input  logic wkup_it_ctrl_en_ack_i,
    input  logic wkup_i,
    output logic debug_power_up_ack_o,
    output logic sleep_hold_req_n_o,
    output logic wkup_it_ctrl_en_req_o
);
    pmu_core pmu_core_inst (
        .clk_i                 (always_on_clk_i),
        .rst_n_i               (always_on_rst_n_i),
        .debug_power_up_req_i  (debug_power_up_req_i),
        .sleep_hold_ack_n_i    (sleep_hold_ack_n_i),
        .wkup_it_ctrl_en_ack_i (wkup_it_ctrl_en_ack_i),
        .wkup_i                (wkup_i),
        .debug_power_up_ack_o  (debug_power_up_ack_o),
        .sleep_hold_req_n_o    (sleep_hold_req_n_o),
        .wkup_it_ctrl_en_req_o (wkup_it_ctrl_en_req_o)
    );

endmodule
