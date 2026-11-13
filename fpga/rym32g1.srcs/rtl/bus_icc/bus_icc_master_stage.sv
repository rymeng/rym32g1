`timescale 1ns / 1ps

module bus_icc_master_stage (
    /* Clock and reset signals */
    input  logic        hclk_i,
    input  logic        hreset_n_i,
    /* AHB-Lite master interface signals */
    input  logic        hsel_master_i,
    input  logic [31:0] haddr_master_i,
    input  logic        hwrite_master_i,
    input  logic [2:0]  hsize_master_i,
    input  logic [2:0]  hburst_master_i,
    input  logic [3:0]  hprot_master_i,
    input  logic [3:0]  hmaster_master_i,
    input  logic [1:0]  htrans_master_i,
    input  logic        hmastlock_master_i,
    input  logic        hready_master_i,
    output logic        hreadyout_master_o,
    output logic [1:0]  hresp_master_o,
    /* Output-to-decoder signals */
    output logic        hsel_decoder_o,
    output logic [31:0] haddr_decoder_o,
    output logic [1:0]  htrans_decoder_o,
    /* Input-from-decoder signals */
    input  logic        hreadyout_decoder_i,
    input  logic [1:0]  hresp_decoder_i,
    input  logic        xfer_granted_decoder_i,
    /* Output-to-slave-stage signals */
    output logic [31:0] haddr_slave_stage_o,
    output logic        hwrite_slave_stage_o,
    output logic [2:0]  hsize_slave_stage_o,
    output logic [3:0]  hmaster_slave_stage_o,
    output logic [1:0]  htrans_slave_stage_o,
    output logic [2:0]  hburst_slave_stage_o,
    output logic [3:0]  hprot_slave_stage_o,
    output logic        hmastlock_slave_stage_o,
    output logic        xfer_req_slave_stage_o
);
    /* HTRANS / HBURST / HRESP code */
    localparam int HTRANS_IDLE   = 2'b00;
    localparam int HTRANS_NONSEQ = 2'b10;
    localparam int HTRANS_SEQ    = 2'b11;

    localparam int HBURST_SINGLE = 3'b000;
    localparam int HBURST_INCR   = 3'b001;
    localparam int HBURST_WRAP4  = 3'b010;
    localparam int HBURST_INCR4  = 3'b011;
    localparam int HBURST_WRAP8  = 3'b100;
    localparam int HBURST_INCR8  = 3'b101;
    localparam int HBURST_WRAP16 = 3'b110;
    localparam int HBURST_INCR16 = 3'b111;

    localparam int HRESP_OKAY    = 2'b00;

    /* Generate address phase & data phase flag signals */
    logic addr_phase;
    logic data_phase;

    assign addr_phase = hsel_master_i && htrans_master_i[1];

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            data_phase <= 1'b0;
        end else if (hready_master_i) begin
            data_phase <= addr_phase;
        end
    end

    /* Generate address phase valid signal */
    logic addr_phase_valid;

    assign addr_phase_valid = addr_phase && hready_master_i;

    /* Holding address phase signals */
    logic [31:0] haddr;
    logic        hwrite;
    logic [2:0]  hsize;
    logic [2:0]  hburst;
    logic [3:0]  hprot;
    logic [3:0]  hmaster;
    logic        hmastlock;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            haddr <= 32'b0;
            hwrite <= 1'b0;
            hsize <= 3'b000;
            hburst <= 3'b000;
            hprot <= 4'b0000;
            hmaster <= 4'b0000;
            hmastlock <= 1'b0;
        end else if (addr_phase_valid) begin
            haddr <= haddr_master_i;
            hwrite <= hwrite_master_i;
            hsize <= hsize_master_i;
            hburst <= hburst_master_i;
            hprot <= hprot_master_i;
            hmaster <= hmaster_master_i;
            hmastlock <= hmastlock_master_i;
        end
    end

    /* Transfer stalled FSM */
    logic xfer_stalled;
    logic xfer_stalled_next;
    
    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            xfer_stalled <= 1'b0;
        end else begin
            xfer_stalled <= xfer_stalled_next;
        end
    end

    always_comb begin
        if (addr_phase_valid && !xfer_granted_decoder_i) begin
            xfer_stalled_next = 1'b1;
        end else if (xfer_granted_decoder_i && hreadyout_decoder_i) begin
            xfer_stalled_next = 1'b0;
        end else begin
            xfer_stalled_next = xfer_stalled;
        end
    end

    /* Burst override FSM */
    logic burst_override;
    logic burst_override_next;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            burst_override <= 1'b0;
        end else if (hready_master_i) begin
            burst_override <= burst_override_next;
        end
    end

    always_comb begin
        if ((htrans_master_i == HTRANS_NONSEQ) || (htrans_master_i == HTRANS_IDLE)) begin
            burst_override_next = 1'b0;
        end else if ((htrans_master_i == HTRANS_SEQ) && addr_phase_valid && !xfer_granted_decoder_i) begin
            burst_override_next = 1'b1;
        end else begin
            burst_override_next = burst_override;
        end
    end

    /* Get the beat index within the wrap window */
    logic [3:0] wrap_beat_idx;

    always_comb begin
        case (hsize_master_i)
            3'b000: begin
                wrap_beat_idx = haddr_master_i[3:0];
            end

            3'b001: begin
                wrap_beat_idx = haddr_master_i[4:1];
            end

            3'b010: begin
                wrap_beat_idx = haddr_master_i[5:2];
            end
            3'b011: begin
                wrap_beat_idx = haddr_master_i[6:3];
            end

            3'b100, 3'b101, 3'b110, 3'b111: begin
                wrap_beat_idx = haddr_master_i[3:0];
            end

            default: begin
                wrap_beat_idx = 'x;
            end
        endcase
    end

    /* Detect the last beat flag of a wrap window */
    logic wrap_last_beat;

    always_comb begin
        case (hburst_master_i)
            HBURST_WRAP4: begin
                wrap_last_beat = (wrap_beat_idx[1:0] == 2'b11);
            end

            HBURST_WRAP8: begin
                wrap_last_beat = (wrap_beat_idx[2:0] == 3'b111);
            end

            HBURST_WRAP16: begin
                wrap_last_beat = (wrap_beat_idx[3:0] == 4'b1111);
            end

            HBURST_SINGLE, HBURST_INCR, HBURST_INCR4, HBURST_INCR8, HBURST_INCR16: begin
                wrap_last_beat = 1'b0;
            end

            default: begin
                wrap_last_beat = 1'bx;
            end
        endcase
    end

    /* Generate wrap crossed signal */
    logic wrap_crossed;

    always_ff @(posedge hclk_i or negedge hreset_n_i) begin
        if (!hreset_n_i) begin
            wrap_crossed <= 1'b0;
        end else if (addr_phase_valid) begin
            wrap_crossed <= wrap_last_beat;
        end
    end

    /* Output HSEL / HADDR / HWRITE / HSIZE / HMASTER / HBURST / HPROT / HMASTLOCK signals */
    always_comb begin
        if (!xfer_stalled) begin
            hsel_decoder_o          = hsel_master_i;
            haddr_decoder_o         = haddr_master_i;
            haddr_slave_stage_o     = haddr_master_i;
            hwrite_slave_stage_o    = hwrite_master_i;
            hsize_slave_stage_o     = hsize_master_i;
            hmaster_slave_stage_o   = hmaster_master_i;
            hburst_slave_stage_o    = hburst_master_i;
            hprot_slave_stage_o     = hprot_master_i;
            hmastlock_slave_stage_o = hmastlock_master_i;
        end else begin
            hsel_decoder_o          = 1'b1;
            haddr_decoder_o         = haddr;
            haddr_slave_stage_o     = haddr;
            hwrite_slave_stage_o    = hwrite;
            hsize_slave_stage_o     = hsize;
            hmaster_slave_stage_o   = hmaster;
            hburst_slave_stage_o    = hburst;
            hprot_slave_stage_o     = hprot;
            hmastlock_slave_stage_o = hmastlock;
        end
    end
    
    /* Output HREADYOUT / HRESP feed-back signals */
    always_comb begin
        if (!data_phase) begin
            hreadyout_master_o = 1'b1;
            hresp_master_o = HRESP_OKAY;
        end else if (xfer_stalled) begin
            hreadyout_master_o = 1'b0;
            hresp_master_o = HRESP_OKAY;
        end else begin
            hreadyout_master_o = hreadyout_decoder_i;
            hresp_master_o = hresp_decoder_i;
        end
    end
    
    /* Output transfer request */
    assign xfer_req_slave_stage_o = addr_phase_valid || xfer_stalled;

    /* Output HTRANS */
    always_comb begin
        if (xfer_stalled) begin
            htrans_decoder_o = HTRANS_NONSEQ;
            htrans_slave_stage_o = HTRANS_NONSEQ;
        end else begin
            htrans_decoder_o = htrans_master_i;
            htrans_slave_stage_o = htrans_master_i;
        end

        if (burst_override && wrap_crossed) begin
            htrans_decoder_o[0] = 1'b0;
            htrans_slave_stage_o[0] = 1'b0;
        end
    end

endmodule
