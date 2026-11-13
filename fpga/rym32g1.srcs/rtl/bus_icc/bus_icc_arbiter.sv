`timescale 1ns / 1ps

module bus_icc_arbiter (
    input  logic       hclk_i,
    input  logic       hreset_n_i,
    input  logic       hsel_granted_master_i,
    input  logic [1:0] htrans_granted_master_i,
    input  logic       hmastlock_valid_granted_master_i,
    input  logic       xfer_req_valid_cm3_ibus_i,
    input  logic       xfer_req_valid_cm3_dbus_i,
    input  logic       xfer_req_valid_cm3_sbus_i,
    input  logic       hready_slave_i,
    output logic [1:0] granted_master_code_o,
    output logic       granted_master_null_o
);
    logic [1:0] granted_master_code;
    logic [1:0] granted_master_code_next;
    logic       granted_master_null;
    logic       granted_master_null_next;

    always_comb begin
        granted_master_code_next = granted_master_code;
        granted_master_null_next = 1'b0;

        if (hmastlock_valid_granted_master_i) begin
            granted_master_code_next = granted_master_code;
        end else if (xfer_req_valid_cm3_ibus_i || (hsel_granted_master_i && (granted_master_code == 2'b00) && (htrans_granted_master_i != 2'b00))) begin
            granted_master_code_next = 2'b00;
        end else if (xfer_req_valid_cm3_dbus_i || (hsel_granted_master_i && (granted_master_code == 2'b01) && (htrans_granted_master_i != 2'b00))) begin
            granted_master_code_next = 2'b01;
        end else if (xfer_req_valid_cm3_sbus_i || (hsel_granted_master_i && (granted_master_code == 2'b10) && (htrans_granted_master_i != 2'b00))) begin
            granted_master_code_next = 2'b10;
        end else if (hsel_granted_master_i) begin
            granted_master_code_next = granted_master_code;
        end else begin
            granted_master_null_next = 1'b1;
        end
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            granted_master_code <= 2'b00;
            granted_master_null <= 1'b1;
        end else if (hready_slave_i) begin
            granted_master_code <= granted_master_code_next;
            granted_master_null <= granted_master_null_next;
        end
    end

    assign granted_master_code_o = granted_master_code;
    assign granted_master_null_o = granted_master_null;

endmodule
