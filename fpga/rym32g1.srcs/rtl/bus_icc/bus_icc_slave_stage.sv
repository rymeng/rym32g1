`timescale 1ns / 1ps

module bus_icc_slave_stage (
    /* Clock & reset signals */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    /* Get-from-cortex-m3-ibus-decoder signal */
    input  logic        hsel_cm3_ibus_decoder_i,
    /* Get-from-cortex-m3-ibus-stage signals */
    input  logic [31:0] haddr_cm3_ibus_stage_i,
    input  logic        hwrite_cm3_ibus_stage_i,
    input  logic [2:0]  hsize_cm3_ibus_stage_i,
    input  logic [3:0]  hmaster_cm3_ibus_stage_i,
    input  logic [1:0]  htrans_cm3_ibus_stage_i,
    input  logic [2:0]  hburst_cm3_ibus_stage_i,
    input  logic [3:0]  hprot_cm3_ibus_stage_i,
    input  logic        hmastlock_cm3_ibus_stage_i,
    input  logic [31:0] hwdata_cm3_ibus_stage_i,
    input  logic        xfer_req_cm3_ibus_stage_i,
    /* Output-to-cortex-m3-ibus-decoder signal */
    output logic        xfer_granted_cm3_ibus_decoder_o,
    /* Get-from-cortex-m3-dbus-decoder signal */
    input  logic        hsel_cm3_dbus_decoder_i,
    /* Get-from-cortex-m3-dbus-stage signals */
    input  logic [31:0] haddr_cm3_dbus_stage_i,
    input  logic        hwrite_cm3_dbus_stage_i,
    input  logic [2:0]  hsize_cm3_dbus_stage_i,
    input  logic [3:0]  hmaster_cm3_dbus_stage_i,
    input  logic [1:0]  htrans_cm3_dbus_stage_i,
    input  logic [2:0]  hburst_cm3_dbus_stage_i,
    input  logic [3:0]  hprot_cm3_dbus_stage_i,
    input  logic        hmastlock_cm3_dbus_stage_i,
    input  logic [31:0] hwdata_cm3_dbus_stage_i,
    input  logic        xfer_req_cm3_dbus_stage_i,
    /* Output-to-cortex-m3-dbus-decoder signal */
    output logic        xfer_granted_cm3_dbus_decoder_o,
    /* Get-from-cortex-m3-sbus-decoder signal */
    input  logic        hsel_cm3_sbus_decoder_i,
    /* Get-from-cortex-m3-sbus-stage signals */
    input  logic [31:0] haddr_cm3_sbus_stage_i,
    input  logic        hwrite_cm3_sbus_stage_i,
    input  logic [2:0]  hsize_cm3_sbus_stage_i,
    input  logic [3:0]  hmaster_cm3_sbus_stage_i,
    input  logic [1:0]  htrans_cm3_sbus_stage_i,
    input  logic [2:0]  hburst_cm3_sbus_stage_i,
    input  logic [3:0]  hprot_cm3_sbus_stage_i,
    input  logic        hmastlock_cm3_sbus_stage_i,
    input  logic [31:0] hwdata_cm3_sbus_stage_i,
    input  logic        xfer_req_cm3_sbus_stage_i,
    /* Output-to-cortex-m3-sbus-decoder signal */
    output logic        xfer_granted_cm3_sbus_decoder_o,
    /* Output-to-all-decoder signals */
    output logic [1:0]  hresp_decoder_o,
    output logic [31:0] hrdata_decoder_o,
    /* AHB slave interface signals */
    output logic        hsel_slave_o,
    output logic [31:0] haddr_slave_o,
    output logic        hwrite_slave_o,
    output logic [2:0]  hsize_slave_o,
    output logic [3:0]  hmaster_slave_o,
    output logic [1:0]  htrans_slave_o,
    output logic [2:0]  hburst_slave_o,
    output logic [3:0]  hprot_slave_o,
    output logic        hmastlock_slave_o,
    output logic        hready_slave_o,
    output logic [31:0] hwdata_slave_o,
    input  logic        hreadyout_slave_i,
    input  logic [1:0]  hresp_slave_i,
    input  logic [31:0] hrdata_slave_i
);
    /* Generate master device access request signals */
    logic xfer_req_valid_cm3_ibus;
    logic xfer_req_valid_cm3_dbus;
    logic xfer_req_valid_cm3_sbus;

    assign xfer_req_valid_cm3_ibus = hsel_cm3_ibus_decoder_i && xfer_req_cm3_ibus_stage_i;
    assign xfer_req_valid_cm3_dbus = hsel_cm3_dbus_decoder_i && xfer_req_cm3_dbus_stage_i;
    assign xfer_req_valid_cm3_sbus = hsel_cm3_sbus_decoder_i && xfer_req_cm3_sbus_stage_i;

    /* Arbitrated AHB slave interface signals */
    logic        hsel;
    logic [31:0] haddr;
    logic        hwrite;
    logic [2:0]  hsize;
    logic [3:0]  hmaster;
    logic [1:0]  htrans;
    logic [2:0]  hburst;
    logic [3:0]  hprot;
    logic        hmastlock;
    logic        hready;
    logic [31:0] hwdata;
    
    /* Generate locked sequence active signal */
    logic lock;
    logic lock_next;
    logic xfer_seq_lock_active;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            lock <= 1'b0;
        end else if (hready) begin
            lock <= lock_next;
        end
    end    

    always_comb begin
        if (hsel && htrans[1] && hmastlock) begin
            lock_next = 1'b1;
        end else if (hmastlock == 1'b0) begin
            lock_next = 1'b0;
        end else begin
            lock_next = lock;
        end
    end

    assign xfer_seq_lock_active = hmastlock && (hsel || lock);

    /* Arbiter */
    logic [1:0] granted_master_code;
    logic       granted_master_null;
    
    bus_icc_arbiter bus_icc_arbiter_inst (
        .hclk_i                     (hclk_i),
        .hreset_n_i                 (hreset_n_i),
        .hsel_granted_master_i      (hsel),
        .htrans_granted_master_i    (htrans),
        .xfer_req_valid_cm3_ibus_i  (xfer_req_valid_cm3_ibus),
        .xfer_req_valid_cm3_dbus_i  (xfer_req_valid_cm3_dbus),
        .xfer_req_valid_cm3_sbus_i  (xfer_req_valid_cm3_sbus),
        .xfer_seq_lock_active_i     (xfer_seq_lock_active),
        .hready_slave_i             (hready),
        .granted_master_code_o      (granted_master_code),
        .granted_master_null_o      (granted_master_null)
    );
    
    /* Select address / data phase master */
    logic [1:0] addr_phase_master_code;
    logic [1:0] data_phase_master_code;
    
    always_comb begin
        addr_phase_master_code = granted_master_code;
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            data_phase_master_code <= 2'b00;
        end else if (hready) begin
            data_phase_master_code <= addr_phase_master_code;
        end
    end

    /* Generate HSEL / HADDR / HTRANS / HWRITE / HSIZE / HBURST / HPROT / HMASTER / HMASTLOCK signal */
    always_comb begin
        hsel = 1'b0;
        haddr = 32'b0;
        htrans = 2'b00;
        hwrite = 1'b0;
        hsize = 3'b000;
        hburst = 3'b000;
        hprot = 4'b0000;
        hmaster = 4'b0000;
        hmastlock = 1'b0;

        if (!granted_master_null) begin
            case (addr_phase_master_code)
                2'b00: begin
                    hsel = hsel_cm3_ibus_decoder_i;
                    haddr = haddr_cm3_ibus_stage_i;
                    htrans = htrans_cm3_ibus_stage_i;
                    hwrite = hwrite_cm3_ibus_stage_i;
                    hsize = hsize_cm3_ibus_stage_i;
                    hburst = hburst_cm3_ibus_stage_i;
                    hprot = hprot_cm3_ibus_stage_i;
                    hmaster = hmaster_cm3_ibus_stage_i;
                    hmastlock = hmastlock_cm3_ibus_stage_i;
                end

                2'b01: begin
                    hsel = hsel_cm3_dbus_decoder_i;
                    haddr = haddr_cm3_dbus_stage_i;
                    htrans = htrans_cm3_dbus_stage_i;
                    hwrite = hwrite_cm3_dbus_stage_i;
                    hsize = hsize_cm3_dbus_stage_i;
                    hburst = hburst_cm3_dbus_stage_i;
                    hprot = hprot_cm3_dbus_stage_i;
                    hmaster = hmaster_cm3_dbus_stage_i;
                    hmastlock = hmastlock_cm3_dbus_stage_i;
                end

                2'b10: begin
                    hsel = hsel_cm3_sbus_decoder_i;
                    haddr = haddr_cm3_sbus_stage_i;
                    htrans = htrans_cm3_sbus_stage_i;
                    hwrite = hwrite_cm3_sbus_stage_i;
                    hsize = hsize_cm3_sbus_stage_i;
                    hburst = hburst_cm3_sbus_stage_i;
                    hprot = hprot_cm3_sbus_stage_i;
                    hmaster = hmaster_cm3_sbus_stage_i;
                    hmastlock = hmastlock_cm3_sbus_stage_i;
                end

                default: begin
                    hsel = 'x;
                    haddr = 'x;
                    htrans = 'x;
                    hwrite = 'x;
                    hsize = 'x;
                    hburst = 'x;
                    hprot = 'x;
                    hmaster = 'x;
                    hmastlock = 'x;
                end
            endcase
        end
    end

    /* Output HSEL / HADDR / HTRANS / HWRITE / HSIZE / HBURST / HPROT / HMASTER / HMASTLOCK signals */
    assign hsel_slave_o = hsel;
    assign haddr_slave_o = haddr;
    assign htrans_slave_o = htrans;
    assign hwrite_slave_o = hwrite;
    assign hsize_slave_o = hsize;
    assign hburst_slave_o = hburst;
    assign hprot_slave_o = hprot;
    assign hmaster_slave_o = hmaster;
    assign hmastlock_slave_o = hmastlock;

    /* Generate HWDATA signal */
    always_comb begin
        hwdata = 32'b0;

        case (data_phase_master_code)
            2'b00: begin
                hwdata = hwdata_cm3_ibus_stage_i;
            end

            2'b01: begin
                hwdata = hwdata_cm3_dbus_stage_i;
            end

            2'b10: begin
                hwdata = hwdata_cm3_sbus_stage_i;
            end

            default: begin
                hwdata = 'x;
            end
        endcase
    end

    /* Output HWDATA signal */
    assign hwdata_slave_o = hwdata;

    /* Generate transfer granted signals */
    logic xfer_granted_cm3_ibus;
    logic xfer_granted_cm3_dbus;
    logic xfer_granted_cm3_sbus;

    always_comb begin
        xfer_granted_cm3_ibus = 1'b0;
        xfer_granted_cm3_dbus = 1'b0;
        xfer_granted_cm3_sbus = 1'b0;

        if (!granted_master_null) begin
            case (addr_phase_master_code)
                2'b00: xfer_granted_cm3_ibus = 1'b1;
                2'b01: xfer_granted_cm3_dbus = 1'b1;
                2'b10: xfer_granted_cm3_sbus = 1'b1;
                default: begin
                    xfer_granted_cm3_ibus = 'x;
                    xfer_granted_cm3_dbus = 'x;
                    xfer_granted_cm3_sbus = 'x;
                end
            endcase
        end
    end

    /* Output transfer granted signals */
    assign xfer_granted_cm3_ibus_decoder_o = xfer_granted_cm3_ibus;
    assign xfer_granted_cm3_dbus_decoder_o = xfer_granted_cm3_dbus;
    assign xfer_granted_cm3_sbus_decoder_o = xfer_granted_cm3_sbus;

    /* Generate HREADY signal */
    logic hsel_valid;
    logic hsel_valid_next;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            hsel_valid <= 1'b0;
        end else if (hready) begin
            hsel_valid <= hsel_valid_next;
        end
    end

    always_comb begin
        hsel_valid_next = hsel;
    end

    assign hready = (hsel_valid) ? hreadyout_slave_i : 1'b1;

    /* Output HREADY / HRESP / HRDATA signals */
    assign hready_slave_o = hready;
    assign hresp_decoder_o = hresp_slave_i;
    assign hrdata_decoder_o = hrdata_slave_i;

endmodule
