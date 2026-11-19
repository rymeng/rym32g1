`timescale 1ns / 1ps

module wwdg_core (
    input  logic       clk_i,
    input  logic       rst_n_i,
    input  logic       activate_i,
    input  logic [2:0] div_i,
    input  logic [6:0] win_high_th_i,
    input  logic       counter_reload_strobe_i,
    input  logic [6:0] counter_reload_val_i,
    input  logic       early_wkup_flag_clear_strobe_i,
    input  logic       early_wk_it_req_en_i,
    output logic [6:0] counter_val_o,
    output logic early_wkup_flag_o,
    output logic rst_req_o,
    output logic it_req_o
);
    /* WWDG Counter */
    logic [6:0] counter;

    /* Flag */
    logic early_wkup_flag;

    /* Reset request signal */
    logic rst_req;

    /* Prescaler */
    logic [18:0] prescaler_counter;
    logic [18:0] prescaler_limit;
    logic counter_clk;

    assign prescaler_limit = (20'd4096 << div_i) - 1'b1;
    assign counter_clk = (prescaler_counter == prescaler_limit);

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            prescaler_counter <= '0;
        end else begin
            if (counter_clk) begin
                prescaler_counter <= '0;
            end else begin
                prescaler_counter <= prescaler_counter + 1'b1;
            end
        end
    end

    /* Counter condition */
    logic counter_early_wkup_condition;
    logic counter_timeout_condition;

    assign counter_early_wkup_condition = counter_clk & (counter == 7'h41);
    assign counter_timeout_condition = counter_clk & (counter == 7'h40);

    /* Reset event */
    logic refresh_error_rst_event;
    logic reload_val_error_rst_event;
    logic timeout_rst_event;
    logic rst_event;

    assign refresh_error_rst_event = activate_i & counter_reload_strobe_i & (counter > win_high_th_i);
    assign reload_val_error_rst_event = activate_i & counter_reload_strobe_i & ~counter_reload_val_i[6];
    assign timeout_rst_event = activate_i & counter_timeout_condition;
    assign rst_event = refresh_error_rst_event | reload_val_error_rst_event | timeout_rst_event;

    /* Early wake-up event */
    logic early_wkup_event;

    assign early_wkup_event = counter_early_wkup_condition | (counter_reload_strobe_i & (counter_reload_val_i == 7'h40));

    /* Count logic */
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            counter <= 7'h7F;
            early_wkup_flag <= 1'b0;
            rst_req <= 1'b0;
        end else begin
            if (counter_reload_strobe_i) begin
                counter <= counter_reload_val_i;
            end else if (counter_clk) begin
                if (counter == 7'h00) begin
                    counter <= 7'h7F;
                end else begin
                    counter <= counter - 1'b1;
                end
            end

            if (early_wkup_event) begin
                early_wkup_flag <= 1'b1;
            end else if (early_wkup_flag_clear_strobe_i) begin
                early_wkup_flag <= 1'b0;
            end

            if (rst_event) begin
                rst_req <= 1'b1;
            end
        end
    end

    /* Output counter */
    assign counter_val_o = counter;

    /* Output flag */
    assign early_wkup_flag_o = early_wkup_flag;

    /* Output interrupt request signal */
    assign it_req_o = early_wk_it_req_en_i & early_wkup_flag;

    /* Output reset request signal */
    assign rst_req_o = rst_req;

endmodule
