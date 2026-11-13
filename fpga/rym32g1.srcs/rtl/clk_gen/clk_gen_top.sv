`timescale 1ns / 1ps

module clk_gen_top #(
    parameter int REFCLK_FREQ_HZ  = 50000000,
    parameter int CLK_OUT_FREQ_HZ = 10000000,
    parameter int VCO_FREQ_HZ     = 1000000000
) (
    input  logic refclk_i,
    input  logic rst_n_i,
    output logic clk_out_o,
    output logic clk_out_ready_o
);
    localparam int  CLK_IN_DIV       = 1;
    localparam real CLK_IN_PERIOD_NS = 1000000000.0 / REFCLK_FREQ_HZ;
    localparam real MULT             = VCO_FREQ_HZ * 1.0 / REFCLK_FREQ_HZ;
    localparam real CLK_OUT_DIV      = VCO_FREQ_HZ * 1.0 / CLK_OUT_FREQ_HZ;

    logic mmcm_rst;
    logic clk_out_mmcm;
    logic clk_out_fb;
    logic clk_out_fb_mmcm;

    assign mmcm_rst = !rst_n_i;

    MMCME2_BASE #(
        .BANDWIDTH          ("OPTIMIZED"),
        .CLKFBOUT_MULT_F    (MULT),
        .CLKFBOUT_PHASE     (0.000),
        .CLKIN1_PERIOD      (CLK_IN_PERIOD_NS),
        .CLKOUT0_DIVIDE_F   (CLK_OUT_DIV),
        .CLKOUT0_DUTY_CYCLE (0.500),
        .CLKOUT0_PHASE      (0.000),
        .DIVCLK_DIVIDE      (CLK_IN_DIV),
        .REF_JITTER1        (0.010),
        .STARTUP_WAIT       ("FALSE")
    ) mmcm_inst (
        .CLKOUT0   (clk_out_mmcm),
        .CLKOUT0B  (),
        .CLKOUT1   (),
        .CLKOUT1B  (),
        .CLKOUT2   (),
        .CLKOUT2B  (),
        .CLKOUT3   (),
        .CLKOUT3B  (),
        .CLKOUT4   (),
        .CLKOUT5   (),
        .CLKOUT6   (),
        .CLKFBOUT  (clk_out_fb_mmcm),
        .CLKFBOUTB (),
        .LOCKED    (clk_out_ready_o),
        .CLKIN1    (refclk_i),
        .PWRDWN    (1'b0),
        .RST       (mmcm_rst),
        .CLKFBIN   (clk_out_fb)
    );

    BUFG clk_out_bufg_inst (
        .I (clk_out_mmcm),
        .O (clk_out_o)
    );

    BUFG clk_out_fb_bufg_inst (
        .I (clk_out_fb_mmcm),
        .O (clk_out_fb)
    );

endmodule
