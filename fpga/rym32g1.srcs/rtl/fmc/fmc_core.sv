`timescale 1ns / 1ps

module fmc_core (
    input logic        hclk_i,
    input logic        hreset_n_i,
/* FMC register interface */
    input logic [3:0]  fmc_latency_i,
    input logic        fmc_keyr_write_strobe_i,
    input logic [31:0] fmc_key_i,
    input logic        fmc_lock_strobe_i,
    input logic        fmc_bank_erase_en_i,
    input logic        fmc_sector_erase_en_i,
    input logic [15:0] fmc_sector_erase_sector_idx_i,
    input logic        fmc_start_erase_i,
    input logic        fmc_start_pending_i,
    input logic        fmc_program_en_i,
    output logic        fmc_locked_o,
    output logic        fmc_busy_o,
    output logic        fmc_ops_done_pulse_o,
    output logic        fmc_program_precheck_err_pulse_o,
    output logic        fmc_program_unaligned_pulse_o,
    output logic        fmc_start_erase_clear_pulse_o,
/* Flash model interface */
    input logic        flash_model_busy_i,
    input logic        flash_model_ops_done_i,
    input logic        flash_model_program_precheck_err_i,
    input logic        flash_model_program_unaligned_i,
    output logic        flash_model_bank_erase_req_o,
    output logic        flash_model_sector_erase_req_o,
    output logic [5:0]  flash_model_sector_erase_sector_idx_o,
    output logic        flash_model_program_en_o
);
    /* Unlock logic */
    logic locked;
    logic unlock_step;

    always_ff @ (posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            locked <= 1'b1;
            unlock_step <= 1'b0;
        end else begin
            if (fmc_lock_strobe_i) begin
                locked <= 1'b1;
                unlock_step <= 1'b0;
            end else if (fmc_keyr_write_strobe_i) begin
                if (fmc_key_i == 32'h5555_AAAA) begin
                    unlock_step <= 1'b1;
                end else if ((fmc_key_i == 32'h3333_CCCC) & unlock_step) begin
                    locked <= 1'b0;
                    unlock_step <= 1'b0;
                end else begin
                    unlock_step <= 1'b0;
                end
            end
        end
    end

    assign fmc_locked_o = locked;

    /* Generate erase request logic */
    logic bank_erase_req;
    logic sector_erase_req;
    logic erase_pending;
    logic  erase_active;

    /* Erase requests test erase_active and the flash busy flag instead of
       fmc_busy, avoiding a combinational loop with erase_pending */
    assign bank_erase_req =
        (!locked) & (!erase_active) & (!flash_model_busy_i) &
        (fmc_start_erase_i) & (fmc_bank_erase_en_i);
    assign sector_erase_req =
        (!locked) & (!erase_active) & (!flash_model_busy_i) &
        (fmc_start_erase_i) & (~fmc_bank_erase_en_i) & (fmc_sector_erase_en_i);

    /* Pending flag: raised on the START write data phase, and kept while
       START is set but erase_active is not yet latched, so a host polling
       SR.BUSY right after writing START always sees the erase as busy */
    assign erase_pending =
        (!locked) &
        (fmc_start_erase_i | fmc_start_pending_i) &
        (fmc_bank_erase_en_i | fmc_sector_erase_en_i);

    always_ff @ (posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            erase_active <= 1'b0;
        end else begin
            if (bank_erase_req | sector_erase_req) begin
                erase_active <= 1'b1;
            end

            if (flash_model_ops_done_i) begin
                erase_active <= 1'b0;
            end
        end
    end

    /* Output the flash model control signals */
    assign flash_model_sector_erase_req_o = sector_erase_req;
    assign flash_model_sector_erase_sector_idx_o = fmc_sector_erase_sector_idx_i[15:10];
    assign flash_model_bank_erase_req_o = bank_erase_req;
    assign flash_model_program_en_o = (~locked) & (fmc_program_en_i);

    /* Output FMC status signals */
    assign fmc_busy_o = erase_active | flash_model_busy_i | erase_pending;
    assign fmc_ops_done_pulse_o = flash_model_ops_done_i;
    assign fmc_program_precheck_err_pulse_o = flash_model_program_precheck_err_i;
    assign fmc_program_unaligned_pulse_o = flash_model_program_unaligned_i;

    /* Output FMC status clear signals */
    assign fmc_start_erase_clear_pulse_o = bank_erase_req | sector_erase_req;

endmodule
