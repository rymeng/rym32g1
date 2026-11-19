`timescale 1ns / 1ps

module wwdg_top (
    input  logic        pclk_i,
    input  logic        preset_n_i,
    input  logic        psel_i,
    input  logic        penable_i,
    input  logic [31:0] paddr_i,
    input  logic        pwrite_i,
    input  logic [3:0]  pstrb_i,
    input  logic [2:0]  pprot_i,
    input  logic [31:0] pwdata_i,
    output logic        pready_o,
    output logic        pslverr_o,
    output logic [31:0] prdata_o,
    output logic        rst_req_o,
    output logic        it_req_o
);
    /* APB transfer signals */
    logic apb_access;
    logic read_xfer_valid;
    logic write_xfer_valid;

    assign apb_access = psel_i & penable_i;
    assign read_xfer_valid = apb_access & ~pwrite_i;
    assign write_xfer_valid = apb_access & pwrite_i;

    /* Registers */
    logic [31:0] cr1;
    logic [31:0] cr2;
    logic [31:0] ier;
    logic [31:0] isr;
    logic [31:0] icr;

    /* Register write strobe */
    logic cr1_write_strobe;
    logic cr2_write_strobe;
    logic ier_write_strobe;
    logic icr_write_strobe;

    assign cr1_write_strobe = write_xfer_valid & (paddr_i[9:2] == 8'h00);
    assign cr2_write_strobe = write_xfer_valid & (paddr_i[9:2] == 8'h01);
    assign ier_write_strobe = write_xfer_valid & (paddr_i[9:2] == 8'h40);
    assign icr_write_strobe = write_xfer_valid & (paddr_i[9:2] == 8'h42);

    /* Bit field write strobe */
    logic       cr1_byte0_write_strobe;
    logic [6:0] cr1_counter_reload_val;
    logic       icr_early_wkup_clear_strobe;

    assign cr1_byte0_write_strobe = cr1_write_strobe & pstrb_i[0];
    assign cr1_counter_reload_val = pwdata_i[6:0];
    assign icr_early_wkup_clear_strobe = icr_write_strobe & pstrb_i[0] & pwdata_i[0];

    /* Counter interface & Flags */
    logic [6:0] cr_counter_interface;
    logic       isr_early_wkup_flag;

    /* Write logic */
    always_ff @(posedge pclk_i or negedge preset_n_i) begin
        if (!preset_n_i) begin
            cr1 <= 32'h0000_0000;
            cr2 <= 32'h0000_007F;
            ier <= 32'h0000_0000;
        end else begin
            if (cr1_byte0_write_strobe) begin
                cr1[7] <= cr1[7] | pwdata_i[7];
            end

            if (cr2_write_strobe) begin
                if (pstrb_i[1]) begin
                    cr2[13:11] <= pwdata_i[13:11];
                end

                if (pstrb_i[0]) begin
                    cr2[6:0] <= pwdata_i[6:0];
                end
            end

            if (ier_write_strobe & pstrb_i[0]) begin
                ier[0] <= pwdata_i[0];
            end
        end
    end

    assign isr = {31'b0, isr_early_wkup_flag};
    assign icr = {32'b0};

    /* Read logic */
    always_comb begin
        if (read_xfer_valid) begin
            case (paddr_i[9:2])
                8'h00: prdata_o = {cr1[31:8], cr1[7], cr_counter_interface};
                8'h01: prdata_o = cr2;
                8'h40: prdata_o = ier;
                8'h41: prdata_o = isr;
                8'h42: prdata_o = icr;
                default: prdata_o = 32'h0000_0000;
            endcase
        end else begin
            prdata_o = 32'h0000_0000;
        end
    end

    /* Output feed-back signals */
    always_comb begin
        pready_o = apb_access;
        pslverr_o = 1'b0;
    end

    /* Core instance */
    wwdg_core wwdg_core_inst (
        .clk_i                          (pclk_i),
        .rst_n_i                        (preset_n_i),
        .activate_i                     (cr1[7]),
        .div_i                          (cr2[13:11]),
        .win_high_th_i                  (cr2[6:0]),
        .counter_reload_strobe_i        (cr1_byte0_write_strobe),
        .counter_reload_val_i           (cr1_counter_reload_val),
        .early_wkup_flag_clear_strobe_i (icr_early_wkup_clear_strobe),
        .early_wk_it_req_en_i           (ier[0]),
        .counter_val_o                  (cr_counter_interface),
        .early_wkup_flag_o              (isr_early_wkup_flag),
        .rst_req_o                      (rst_req_o),
        .it_req_o                       (it_req_o)
    );

endmodule
