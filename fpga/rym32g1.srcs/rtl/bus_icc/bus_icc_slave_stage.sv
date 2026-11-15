`timescale 1ns / 1ps

module bus_icc_slave_stage (
    /* Clock & reset signals */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
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
    input  logic [31:0] hrdata_slave_i,
    /* Input (from Cortex-M3 IBus decoder) signal */
    input  logic        hsel_cm3_ibus_decoder_i,
    /* Input (from Cortex-M3 IBus stage) signals */
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
    /* Output (to Cortex-M3 IBus decoder) signal */
    output logic        hreadyout_cm3_ibus_decoder_o,
    output logic [1:0]  hresp_cm3_ibus_decoder_o,
    output logic [31:0] hrdata_cm3_ibus_decoder_o,
    output logic        xfer_granted_cm3_ibus_decoder_o,
    /* Input (from Cortex-M3 DBus decoder) signal */
    input  logic        hsel_cm3_dbus_decoder_i,
    /* Input (from Cortex-M3 DBus stage) signals */
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
    /* Output (to Cortex-M3 DBus decoder) signal */
    output logic        hreadyout_cm3_dbus_decoder_o,
    output logic [1:0]  hresp_cm3_dbus_decoder_o,
    output logic [31:0] hrdata_cm3_dbus_decoder_o,
    output logic        xfer_granted_cm3_dbus_decoder_o,
    /* Input (from Cortex-M3 SBus decoder) signal */
    input  logic        hsel_cm3_sbus_decoder_i,
    /* Input (from Cortex-M3 SBus stage) signals */
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
    /* Output (to Cortex-M3 SBus decoder) signal */
    output logic        hreadyout_cm3_sbus_decoder_o,
    output logic [1:0]  hresp_cm3_sbus_decoder_o,
    output logic [31:0] hrdata_cm3_sbus_decoder_o,
    output logic        xfer_granted_cm3_sbus_decoder_o
);
    import bus_icc_pkg::*;

    /* AHB slave interface signals */
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
    logic        hreadyout;
    logic [1:0]  hresp;
    logic [31:0] hrdata;

    /* Get AHB slave interface signals (from slave) */
    assign hreadyout = hreadyout_slave_i;
    assign hresp = hresp_slave_i;
    assign hrdata = hrdata_slave_i;

    /* Generate transfer request valid signals */
    logic xfer_req_valid_cm3_ibus;
    logic xfer_req_valid_cm3_dbus;
    logic xfer_req_valid_cm3_sbus;

    assign xfer_req_valid_cm3_ibus = hsel_cm3_ibus_decoder_i && xfer_req_cm3_ibus_stage_i;
    assign xfer_req_valid_cm3_dbus = hsel_cm3_dbus_decoder_i && xfer_req_cm3_dbus_stage_i;
    assign xfer_req_valid_cm3_sbus = hsel_cm3_sbus_decoder_i && xfer_req_cm3_sbus_stage_i;

    /* Generate locked sequence active signal */
    logic xfer_seq_lock_raw;
    logic xfer_seq_lock_active;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            xfer_seq_lock_raw <= 1'b0;
        end else begin
			if (hready) begin
				if (hsel && htrans[1] && hmastlock) begin
					xfer_seq_lock_raw <= 1'b1;
				end else if (!hmastlock) begin
					xfer_seq_lock_raw <= 1'b0;
				end
			end
        end
    end

    assign xfer_seq_lock_active = (hmastlock && hsel) || (hmastlock && xfer_seq_lock_raw);

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

    /* Generate address / data phase master code */
    logic [1:0] addr_phase_master_code;
    logic [1:0] data_phase_master_code;

    always_comb begin
        addr_phase_master_code = granted_master_code;
    end

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            data_phase_master_code <= CM3_IBUS_CODE;
        end else if (hready) begin
            data_phase_master_code <= addr_phase_master_code;
        end
    end

    /* Generate transfer granted signals */
    logic xfer_granted_cm3_ibus_decoder;
    logic xfer_granted_cm3_dbus_decoder;
    logic xfer_granted_cm3_sbus_decoder;

    always_comb begin
        xfer_granted_cm3_ibus_decoder = 1'b0;
        xfer_granted_cm3_dbus_decoder = 1'b0;
        xfer_granted_cm3_sbus_decoder = 1'b0;

        if (!granted_master_null) begin
            case (addr_phase_master_code)
                CM3_IBUS_CODE: xfer_granted_cm3_ibus_decoder = 1'b1;
                CM3_DBUS_CODE: xfer_granted_cm3_dbus_decoder = 1'b1;
                CM3_SBUS_CODE: xfer_granted_cm3_sbus_decoder = 1'b1;
                default: begin
                    xfer_granted_cm3_ibus_decoder = 'x;
                    xfer_granted_cm3_dbus_decoder = 'x;
                    xfer_granted_cm3_sbus_decoder = 'x;
                end
            endcase
        end
    end

    /* Output transfer granted signals */
    assign xfer_granted_cm3_ibus_decoder_o = xfer_granted_cm3_ibus_decoder;
    assign xfer_granted_cm3_dbus_decoder_o = xfer_granted_cm3_dbus_decoder;
    assign xfer_granted_cm3_sbus_decoder_o = xfer_granted_cm3_sbus_decoder;

    /* Route HSEL / HADDR / HTRANS / HWRITE / HSIZE / HBURST / HPROT / HMASTER / HMASTLOCK from the master to the slave in address phase */
    always_comb begin
        hsel = 1'b0;
        haddr = 32'b0;
        htrans = HTRANS_IDLE;
        hwrite = 1'b0;
        hsize = 3'b000;
        hburst = 3'b000;
        hprot = 4'b0000;
        hmaster = 4'b0000;
        hmastlock = 1'b0;

        if (!granted_master_null) begin
            case (addr_phase_master_code)
                CM3_IBUS_CODE: begin
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

                CM3_DBUS_CODE: begin
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

                CM3_SBUS_CODE: begin
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

    /* Route HWDATA from the master to the slave in data phase */
    always_comb begin
        case (data_phase_master_code)
            CM3_IBUS_CODE: hwdata = hwdata_cm3_ibus_stage_i;
            CM3_DBUS_CODE: hwdata = hwdata_cm3_dbus_stage_i;
            CM3_SBUS_CODE: hwdata = hwdata_cm3_sbus_stage_i;
            default:       hwdata = 'x;
        endcase
    end

    /* Route HREADY signal */
    logic hsel_data_phase;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            hsel_data_phase <= 1'b0;
        end else begin
			if (hready) begin
				hsel_data_phase <= hsel;
			end
		end
    end

    assign hready = hsel_data_phase ? hreadyout : 1'b1;

    /* Route HREADYOUT / HRESP / HRDATA from the slave to the master in data phase */
    logic        hreadyout_cm3_ibus_decoder;
    logic [1:0]  hresp_cm3_ibus_decoder;
    logic [31:0] hrdata_cm3_ibus_decoder;
    logic        hreadyout_cm3_dbus_decoder;
    logic [1:0]  hresp_cm3_dbus_decoder;
    logic [31:0] hrdata_cm3_dbus_decoder;
    logic        hreadyout_cm3_sbus_decoder;
    logic [1:0]  hresp_cm3_sbus_decoder;
    logic [31:0] hrdata_cm3_sbus_decoder;

    always_comb begin
        hreadyout_cm3_ibus_decoder = 1'b1;
        hresp_cm3_ibus_decoder = 2'b00;
        hrdata_cm3_ibus_decoder = 32'b0;
        hreadyout_cm3_dbus_decoder = 1'b1;
        hresp_cm3_dbus_decoder = 2'b00;
        hrdata_cm3_dbus_decoder = 32'b0;
        hreadyout_cm3_sbus_decoder = 1'b1;
        hresp_cm3_sbus_decoder = 2'b00;
        hrdata_cm3_sbus_decoder = 32'b0;

        case (data_phase_master_code)
            CM3_IBUS_CODE: begin
                hreadyout_cm3_ibus_decoder = hready;
                hresp_cm3_ibus_decoder = hresp;
                hrdata_cm3_ibus_decoder = hrdata;
            end

            CM3_DBUS_CODE: begin
                hreadyout_cm3_dbus_decoder = hready;
                hresp_cm3_dbus_decoder = hresp;
                hrdata_cm3_dbus_decoder = hrdata;
            end

            CM3_SBUS_CODE: begin
                hreadyout_cm3_sbus_decoder = hready;
                hresp_cm3_sbus_decoder = hresp;
                hrdata_cm3_sbus_decoder = hrdata;
            end

            default: begin
            end
        endcase
    end

    /* Output AHB slave interface signals (to slave) */
    assign hsel_slave_o = hsel;
    assign haddr_slave_o = haddr;
    assign htrans_slave_o = htrans;
    assign hwrite_slave_o = hwrite;
    assign hsize_slave_o = hsize;
    assign hburst_slave_o = hburst;
    assign hprot_slave_o = hprot;
    assign hmaster_slave_o = hmaster;
    assign hmastlock_slave_o = hmastlock;
    assign hready_slave_o = hready;
    assign hwdata_slave_o = hwdata;

    /* Output HREADYOUT / HRESP / HRDATA signals to decoders */
    assign hreadyout_cm3_ibus_decoder_o = hreadyout_cm3_ibus_decoder;
    assign hresp_cm3_ibus_decoder_o = hresp_cm3_ibus_decoder;
    assign hrdata_cm3_ibus_decoder_o = hrdata_cm3_ibus_decoder;
    assign hreadyout_cm3_dbus_decoder_o = hreadyout_cm3_dbus_decoder;
    assign hresp_cm3_dbus_decoder_o = hresp_cm3_dbus_decoder;
    assign hrdata_cm3_dbus_decoder_o = hrdata_cm3_dbus_decoder;
    assign hreadyout_cm3_sbus_decoder_o = hreadyout_cm3_sbus_decoder;
    assign hresp_cm3_sbus_decoder_o = hresp_cm3_sbus_decoder;
    assign hrdata_cm3_sbus_decoder_o = hrdata_cm3_sbus_decoder;

endmodule
