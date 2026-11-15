`timescale 1ns / 1ps

module bus_icc_arbiter (
    input  logic       hclk_i,
    input  logic       hreset_n_i,
    input  logic       hsel_granted_master_i,
    input  logic [1:0] htrans_granted_master_i,
    input  logic       xfer_req_valid_cm3_ibus_i,
    input  logic       xfer_req_valid_cm3_dbus_i,
    input  logic       xfer_req_valid_cm3_sbus_i,
    input  logic       xfer_seq_lock_active_i,
    input  logic       hready_slave_i,
    output logic [1:0] granted_master_code_o,
    output logic       granted_master_null_o
);
    import bus_icc_pkg::*;

    logic [1:0] granted_master_code;
    logic [1:0] granted_master_code_next;
    logic       granted_master_null;
    logic       granted_master_null_next;

    logic xfer_busy_cm3_ibus;
    logic xfer_busy_cm3_dbus;
    logic xfer_busy_cm3_sbus;

    assign xfer_busy_cm3_ibus = hsel_granted_master_i && (granted_master_code == CM3_IBUS_CODE) && (htrans_granted_master_i == HTRANS_BUSY);
    assign xfer_busy_cm3_dbus = hsel_granted_master_i && (granted_master_code == CM3_DBUS_CODE) && (htrans_granted_master_i == HTRANS_BUSY);
    assign xfer_busy_cm3_sbus = hsel_granted_master_i && (granted_master_code == CM3_SBUS_CODE) && (htrans_granted_master_i == HTRANS_BUSY);

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            granted_master_code <= CM3_IBUS_CODE;
            granted_master_null <= 1'b1;
        end else if (hready_slave_i) begin
            granted_master_code <= granted_master_code_next;
            granted_master_null <= granted_master_null_next;
        end
    end

    always_comb begin
        granted_master_code_next = granted_master_code;
        granted_master_null_next = 1'b0;

        if (xfer_seq_lock_active_i) begin
            granted_master_code_next = granted_master_code;
        end else begin
            if (xfer_req_valid_cm3_ibus_i || xfer_busy_cm3_ibus) begin
                granted_master_code_next = CM3_IBUS_CODE;
            end else if (xfer_req_valid_cm3_dbus_i || xfer_busy_cm3_dbus) begin
                granted_master_code_next = CM3_DBUS_CODE;
            end else if (xfer_req_valid_cm3_sbus_i || xfer_busy_cm3_sbus) begin
                granted_master_code_next = CM3_SBUS_CODE;
            end else if (hsel_granted_master_i) begin
                granted_master_code_next = granted_master_code;
            end else begin
                granted_master_null_next = 1'b1;
            end
        end
    end

    assign granted_master_code_o = granted_master_code;
    assign granted_master_null_o = granted_master_null;

endmodule
