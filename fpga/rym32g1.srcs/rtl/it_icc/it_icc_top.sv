`timescale 1ns / 1ps

module it_icc_top (
    input logic          wwdg_it_req_i,
    input logic          uart1_rx_it_req_i,
    input logic          uart1_tx_it_req_i,
    input logic          uart2_rx_it_req_i,
    input logic          uart2_tx_it_req_i,
    output logic [239:0] nvic_it_req_o
);
    logic [63:0] nvic_it_req;

    assign nvic_it_req = {
        50'b0,
        uart2_tx_it_req_i,
        uart2_rx_it_req_i,
        uart1_tx_it_req_i,
        uart1_rx_it_req_i,
        9'b0,
        wwdg_it_req_i};

    assign nvic_it_req_o = {176'b0, nvic_it_req};

endmodule
