`timescale 1ns / 1ps

package bus_icc_pkg;
    /* HTRANS code */
    localparam logic [1:0] HTRANS_IDLE   = 2'b00;
    localparam logic [1:0] HTRANS_BUSY   = 2'b01;
    localparam logic [1:0] HTRANS_NONSEQ = 2'b10;
    localparam logic [1:0] HTRANS_SEQ    = 2'b11;

    /* HBURST code */
    localparam logic [2:0] HBURST_SINGLE = 3'b000;
    localparam logic [2:0] HBURST_INCR   = 3'b001;
    localparam logic [2:0] HBURST_WRAP4  = 3'b010;
    localparam logic [2:0] HBURST_INCR4  = 3'b011;
    localparam logic [2:0] HBURST_WRAP8  = 3'b100;
    localparam logic [2:0] HBURST_INCR8  = 3'b101;
    localparam logic [2:0] HBURST_WRAP16 = 3'b110;
    localparam logic [2:0] HBURST_INCR16 = 3'b111;

    /* HRESP code */
    localparam logic [1:0] HRESP_OKAY    = 2'b00;
    localparam logic [1:0] HRESP_ERROR   = 2'b01;

    /* Master code */
    localparam logic [1:0] CM3_IBUS_CODE = 2'b00;
    localparam logic [1:0] CM3_DBUS_CODE = 2'b01;
    localparam logic [1:0] CM3_SBUS_CODE = 2'b10;
endpackage
