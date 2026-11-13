`timescale 1ns / 1ps

module gpio_core (
    input logic        clk_i,
    input logic        rst_n_i,
/* Pad signal */
    input logic [15:0] open_drain_enabled_i,
/* GPIO signals */
    input logic [15:0] gpio_output_enabled_i,
    input logic [15:0] gpio_output_data_i,
    output logic [15:0] gpio_input_data_o,
/* AFIO signals */
    input logic [15:0] afio_enabled_i,
    input logic [15:0] afio_output_enabled_i,
    input logic [15:0] afio_output_data_i,
    output logic [15:0] afio_input_data_o,
/* Pin */
    inout logic [15:0] pin_io
);
    /* Output */
    logic [15:0] io_type;
    logic [15:0] io_output_enabled;
    logic [15:0] io_output_data;
    logic [15:0] io_output_drive_low;
    logic [15:0] io_output_drive_high;
    logic [15:0] io_input_data;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            /* Pick the output source */
            assign io_type[i] = afio_enabled_i[i];
            assign io_output_enabled[i] = io_type[i] ?
                afio_output_enabled_i[i] : gpio_output_enabled_i[i];
            assign io_output_data[i] = io_type[i] ?
                afio_output_data_i[i] : gpio_output_data_i[i];

            /* Generate pad control signals */
            assign io_output_drive_low[i] =
                io_output_enabled[i] & ~io_output_data[i];
            assign io_output_drive_high[i] =
                io_output_enabled[i] & ~open_drain_enabled_i[i] &
                io_output_data[i];

            /* Drive the pad */
            assign pin_io[i] =
                (io_output_drive_low[i]) ?
                (1'b0) : (io_output_drive_high[i] ? 1'b1 : 1'bz);
        end
    endgenerate

    /* Input */
    (* ASYNC_REG = "TRUE" *) logic [15:0] io_input_data_sync1;
    (* ASYNC_REG = "TRUE" *) logic [15:0] io_input_data_sync2;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            io_input_data_sync1 <= 16'b0;
            io_input_data_sync2 <= 16'b0;
        end else begin
            io_input_data_sync1 <= pin_io;
            io_input_data_sync2 <= io_input_data_sync1;
        end
    end

    assign io_input_data = io_input_data_sync2;
    assign gpio_input_data_o = io_input_data;
    assign afio_input_data_o = io_input_data;

endmodule
