`timescale 1ns / 1ps

module uart_baud_gen (
    input logic        clk_i,
    input logic        rst_n_i,
    input logic [5:0]  oversample_ratio_i,
    input logic [12:0] baud_divider_i,
    input logic        restart_i,
    input logic        enhance_sample_tick_en_i,
    output logic        standard_sample_tick_o,
    output logic        enhance_sample_tick_o,
    output logic        bit_tick_o,
    output logic [6:0]  sample_points_num_per_bit
);

    /* Calibrate the oversampling ratio */
    logic [5:0] sample_point_per_bit_limit;

    always_comb begin
        if (oversample_ratio_i < 6'd4) begin
            sample_point_per_bit_limit = 6'd4;
        end else if (oversample_ratio_i > 6'd32) begin
            sample_point_per_bit_limit = 6'd32;
        end else begin
            sample_point_per_bit_limit = oversample_ratio_i;
        end
    end

    /* Calibrate the baud divider */
    logic [12:0] clk_per_sample_point_limit;

    assign clk_per_sample_point_limit = baud_divider_i;

    /* Generate enhanced mode enable signal */
    logic enhance_sample_tick_en;

    assign enhance_sample_tick_en = enhance_sample_tick_en_i & (baud_divider_i > 13'h1);

    /* Generate ticks */
    logic [12:0] clk_cnt;
    logic [5:0]  sample_points_cnt;
    logic        standard_sample_tick;
    logic        enhance_sample_tick;
    logic        bit_tick;

    always_ff @ (posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            clk_cnt <= 13'h0;
            sample_points_cnt <= 6'h0;
            standard_sample_tick <= 1'b0;
            enhance_sample_tick <= 1'b0;
            bit_tick <= 1'b0;
        end else begin
            if (restart_i) begin
                clk_cnt <= 13'h0;
                sample_points_cnt <= 6'h0;
                standard_sample_tick <= 1'b0;
                enhance_sample_tick <= 1'b0;
                bit_tick <= 1'b0;
            end else if (baud_divider_i == 13'h0) begin
                clk_cnt <= 13'h0;
                sample_points_cnt <= 6'h0;
                standard_sample_tick <= 1'b0;
                enhance_sample_tick <= 1'b0;
                bit_tick <= 1'b0;
            end else if (clk_cnt >= clk_per_sample_point_limit - 13'h1) begin
                clk_cnt <= 13'h0;
                if (sample_points_cnt == sample_point_per_bit_limit - 6'd1) begin
                    sample_points_cnt <= 6'h0;
                end else begin
                    sample_points_cnt <= sample_points_cnt + 6'h1;
                end
                standard_sample_tick <= 1'b1;
                enhance_sample_tick <= 1'b0;
                if (sample_points_cnt == sample_point_per_bit_limit - 6'd1) begin
                    bit_tick <= 1'b1;
                end else begin
                    bit_tick <= 1'b0;
                end
            end else begin
                clk_cnt <= clk_cnt + 13'h1;
                sample_points_cnt <= sample_points_cnt;
                standard_sample_tick <= 1'b0;
                if (clk_cnt == ((clk_per_sample_point_limit - 13'h1) >> 1)) begin
                    enhance_sample_tick <= 1'b1;
                end else begin
                    enhance_sample_tick <= 1'b0;
                end
                bit_tick <= 1'b0;
            end
        end
    end

    /* Output ticks */
    assign standard_sample_tick_o = standard_sample_tick;
    assign enhance_sample_tick_o = enhance_sample_tick & enhance_sample_tick_en;
    assign bit_tick_o = bit_tick;

    /* Output sample points number per bit */
    assign sample_points_num_per_bit = enhance_sample_tick_en ? ({1'b0, sample_point_per_bit_limit} << 1) : {1'b0, sample_point_per_bit_limit};

endmodule

