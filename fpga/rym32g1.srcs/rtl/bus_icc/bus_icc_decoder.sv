`timescale 1ns / 1ps

module bus_icc_decoder (
    /* Clock and reset signal */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    /* Master stage signals */
    input  logic        hsel_master_stage_i,
    input  logic [31:0] haddr_master_stage_i,
    input  logic [1:0]  htrans_master_stage_i,
    input  logic        hready_master_stage_i,
    output logic        hreadyout_master_stage_o,
    output logic [1:0]  hresp_master_stage_o,
    output logic [31:0] hrdata_master_stage_o,
    output logic        master_stage_xfer_granted_o,
    /* RCC */
    output logic        hsel_rcc_o,
    input  logic        hreadyout_rcc_i,
    input  logic [1:0]  hresp_rcc_i,
    input  logic [31:0] hrdata_rcc_i,
    input  logic        rcc_xfer_granted_i,
    /* Flash */
    output logic        hsel_flash_o,
    input  logic        hreadyout_flash_i,
    input  logic [1:0]  hresp_flash_i,
    input  logic [31:0] hrdata_flash_i,
    input  logic        flash_xfer_granted_i,
    /* SRAM */
    output logic        hsel_sram_o,
    input  logic        hreadyout_sram_i,
    input  logic [1:0]  hresp_sram_i,
    input  logic [31:0] hrdata_sram_i,
    input  logic        sram_xfer_granted_i,
    /* GPIO A */
    output logic        hsel_gpioa_o,
    input  logic        hreadyout_gpioa_i,
    input  logic [1:0]  hresp_gpioa_i,
    input  logic [31:0] hrdata_gpioa_i,
    input  logic        gpioa_xfer_granted_i,
    /* GPIO B */
    output logic        hsel_gpiob_o,
    input  logic        hreadyout_gpiob_i,
    input  logic [1:0]  hresp_gpiob_i,
    input  logic [31:0] hrdata_gpiob_i,
    input  logic        gpiob_xfer_granted_i,
    /* FMC */
    output logic        hsel_fmc_o,
    input  logic        hreadyout_fmc_i,
    input  logic [1:0]  hresp_fmc_i,
    input  logic [31:0] hrdata_fmc_i,
    input  logic        fmc_xfer_granted_i,
    /* AHB to APB bridge */
    output logic        hsel_apb1_br_o,
    input  logic        hreadyout_apb1_br_i,
    input  logic [1:0]  hresp_apb1_br_i,
    input  logic [31:0] hrdata_apb1_br_i,
    input  logic        apb1_br_xfer_granted_i
);
    /* Generate default slave */
    logic       hsel_default_slave;
    logic       hreadyout_default_slave;
    logic [1:0] hresp_default_slave;

    bus_icc_default_slave default_slave_inst (
        .hclk_i      (hclk_i),
        .hreset_n_i  (hreset_n_i),
        .hsel_i      (hsel_default_slave),
        .htrans_i    (htrans_master_stage_i[1]),
        .hready_i    (hready_master_stage_i),
        .hreadyout_o (hreadyout_default_slave),
        .hresp_o     (hresp_default_slave)
    );

    /* Generate slave code */
    localparam int DEFAULT_SLAVE_CODE = 3'b000;

    logic [2:0] addr_phase_slave_code;
    logic [2:0] data_phase_slave_code;

    always_comb begin
        if (((haddr_master_stage_i >= 32'h400B0000) && (haddr_master_stage_i <= 32'h400B0FFF)) || ((data_phase_slave_code == 3'b001) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b001;
        end else if (((haddr_master_stage_i >= 32'h00000000) && (haddr_master_stage_i <= 32'h0000FFFF)) || ((data_phase_slave_code == 3'b010) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b010;
        end else if (((haddr_master_stage_i >= 32'h20000000) && (haddr_master_stage_i <= 32'h2000FFFF)) || ((data_phase_slave_code == 3'b011) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b011;
        end else if (((haddr_master_stage_i >= 32'h40080000) && (haddr_master_stage_i <= 32'h400803FF)) || ((data_phase_slave_code == 3'b100) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b100;
        end else if (((haddr_master_stage_i >= 32'h40080400) && (haddr_master_stage_i <= 32'h400807FF)) || ((data_phase_slave_code == 3'b101) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b101;
        end else if (((haddr_master_stage_i >= 32'h400B1000) && (haddr_master_stage_i <= 32'h400B1FFF)) || ((data_phase_slave_code == 3'b110) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b110;
        end else if (((haddr_master_stage_i >= 32'h40000000) && (haddr_master_stage_i <= 32'h4001FFFF)) || ((data_phase_slave_code == 3'b111) && (htrans_master_stage_i[1] == 1'b0))) begin
            addr_phase_slave_code = 3'b111;
        end else begin
            addr_phase_slave_code = DEFAULT_SLAVE_CODE;
        end
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            data_phase_slave_code <= DEFAULT_SLAVE_CODE;
        end else if (hready_master_stage_i) begin
            data_phase_slave_code <= addr_phase_slave_code;
        end
    end

    /* Generate HSEL signals */
    assign hsel_rcc_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b001);
    assign hsel_flash_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b010);
    assign hsel_sram_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b011);
    assign hsel_gpioa_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b100);
    assign hsel_gpiob_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b101);
    assign hsel_fmc_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b110);
    assign hsel_apb1_br_o = hsel_master_stage_i && (addr_phase_slave_code == 3'b111);
    assign hsel_default_slave = hsel_master_stage_i && (addr_phase_slave_code == DEFAULT_SLAVE_CODE);

    /* Generate the transfer granted signal */
    always_comb begin
        case (addr_phase_slave_code)
            3'b001: begin
                master_stage_xfer_granted_o = rcc_xfer_granted_i;
            end

            3'b010: begin
                master_stage_xfer_granted_o = flash_xfer_granted_i;
            end

            3'b011: begin
                master_stage_xfer_granted_o = sram_xfer_granted_i;
            end

            3'b100: begin
                master_stage_xfer_granted_o = gpioa_xfer_granted_i;
            end

            3'b101: begin
                master_stage_xfer_granted_o = gpiob_xfer_granted_i;
            end

            3'b110: begin
                master_stage_xfer_granted_o = fmc_xfer_granted_i;
            end

            3'b111: begin
                master_stage_xfer_granted_o = apb1_br_xfer_granted_i;
            end

            DEFAULT_SLAVE_CODE: begin
                master_stage_xfer_granted_o = 1'b1;
            end

            default: begin
                master_stage_xfer_granted_o = 'x;
            end
        endcase
    end

    always_comb begin
        case (data_phase_slave_code)
            3'b001: begin
                hrdata_master_stage_o = hrdata_rcc_i;
                hreadyout_master_stage_o = hreadyout_rcc_i;
                hresp_master_stage_o = hresp_rcc_i;
            end

            3'b010: begin
                hrdata_master_stage_o = hrdata_flash_i;
                hreadyout_master_stage_o = hreadyout_flash_i;
                hresp_master_stage_o = hresp_flash_i;
            end

            3'b011: begin
                hrdata_master_stage_o = hrdata_sram_i;
                hreadyout_master_stage_o = hreadyout_sram_i;
                hresp_master_stage_o = hresp_sram_i;
            end

            3'b100: begin
                hrdata_master_stage_o = hrdata_gpioa_i;
                hreadyout_master_stage_o = hreadyout_gpioa_i;
                hresp_master_stage_o = hresp_gpioa_i;
            end

            3'b101: begin
                hrdata_master_stage_o = hrdata_gpiob_i;
                hreadyout_master_stage_o = hreadyout_gpiob_i;
                hresp_master_stage_o = hresp_gpiob_i;
            end

            3'b110: begin
                hrdata_master_stage_o = hrdata_fmc_i;
                hreadyout_master_stage_o = hreadyout_fmc_i;
                hresp_master_stage_o = hresp_fmc_i;
            end

            3'b111: begin
                hrdata_master_stage_o = hrdata_apb1_br_i;
                hreadyout_master_stage_o = hreadyout_apb1_br_i;
                hresp_master_stage_o = hresp_apb1_br_i;
            end

            DEFAULT_SLAVE_CODE: begin
                hrdata_master_stage_o = 32'b0;
                hreadyout_master_stage_o = hreadyout_default_slave;
                hresp_master_stage_o = hresp_default_slave;
            end

            default: begin
                hrdata_master_stage_o = 'x;
                hreadyout_master_stage_o = 'x;
                hresp_master_stage_o = 'x;
            end
        endcase
    end

endmodule
