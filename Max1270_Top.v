/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Lite RAM
 */
module Max1270_Top #
(
    /*
    * AXI-lite slave interface
    */
    parameter AXIL_ADDR_WIDTH      = 32,
    parameter AXIL_DATA_WIDTH      = 32,
    parameter AXIL_STRB_WIDTH      = AXIL_DATA_WIDTH/8
)
(
    input  wire                   s_axil_clk    ,
    input  wire                   s_axil_rst    ,
    
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_awaddr ,
    input  wire [2:0]             s_axil_awprot ,
    input  wire                   s_axil_awvalid,
    output wire                   s_axil_awready,
    input  wire [AXIL_DATA_WIDTH-1:0]  s_axil_wdata  ,
    input  wire [AXIL_STRB_WIDTH-1:0]  s_axil_wstrb  ,
    input  wire                   s_axil_wvalid ,
    output wire                   s_axil_wready ,
    output wire [1:0]             s_axil_bresp  ,
    output wire                   s_axil_bvalid ,
    input  wire                   s_axil_bready ,
    input  wire [AXIL_ADDR_WIDTH-1:0]  s_axil_araddr ,
    input  wire [2:0]             s_axil_arprot ,
    input  wire                   s_axil_arvalid,
    output wire                   s_axil_arready,
    output wire [AXIL_DATA_WIDTH-1:0]  s_axil_rdata  ,
    output wire [1:0]             s_axil_rresp  ,
    output wire                   s_axil_rvalid ,
    input  wire                   s_axil_rready ,
    
    input                         I_MAX1270_MISO,
    output                        O_MAX1270_SCK ,
    output                        O_MAX1270_MOSI,
    output                        O_MAX1270_CS  ,
    output                        O_MAX1270_SHDN,
    input                         I_MAX1270_SSTRB
);

    wire [11:0]             wADCh0Data     ;
    wire [11:0]             wADCh1Data     ;
    wire [11:0]             wADCh2Data     ;
    wire [11:0]             wADCh3Data     ;
    wire [11:0]             wADCh4Data     ;
    wire [11:0]             wADCh5Data     ;
    wire [11:0]             wADCh6Data     ;
    wire [11:0]             wADCh7Data     ;


    Max1270_Phy inst_Max1270_Phy
        (
            .clk             (s_axil_clk),
            .rst             (~s_axil_rst),

            .oADCh0Data      (wADCh0Data),
            .oADCh1Data      (wADCh1Data),
            .oADCh2Data      (wADCh2Data),
            .oADCh3Data      (wADCh3Data),
            .oADCh4Data      (wADCh4Data),
            .oADCh5Data      (wADCh5Data),
            .oADCh6Data      (wADCh6Data),
            .oADCh7Data      (wADCh7Data),

            .I_MAX1270_MISO  (I_MAX1270_MISO),
            .O_MAX1270_SCK   (O_MAX1270_SCK),
            .O_MAX1270_MOSI  (O_MAX1270_MOSI),
            .O_MAX1270_CS    (O_MAX1270_CS),
            .O_MAX1270_SHDN  (O_MAX1270_SHDN),
            .I_MAX1270_SSTRB (I_MAX1270_SSTRB)
        );
//    assign O_MAX1270_SHDN = 1;
//    MAX1270 inst_MAX1270
//        (
//            .AD_0(wADCh0Data),
//            .AD_1(wADCh1Data),
//            .AD_2(wADCh2Data),
//            .AD_3(wADCh3Data),
//            .AD_4(wADCh4Data),
//            .AD_5(wADCh5Data),
//            .AD_6(wADCh6Data),
//            .AD_7(wADCh7Data),
//            .CLK(s_axil_clk),
//            .HRST(s_axil_rst),
//            .ADMAX_SCLK(O_MAX1270_SCK),
//            .ADMAX_CS(O_MAX1270_CS),
//            .ADMAX_DIN(O_MAX1270_MOSI),
//            .ADMAX_DOUT(I_MAX1270_MISO),
//            .ADMAX_SSTRB(I_MAX1270_SSTRB)
//        );
    Max1270_AXIL_Reg #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .PIPELINE_OUTPUT(0)
        ) inst_Max1270_AXIL_Reg (
            .clk            (s_axil_clk),
            .rst            (~s_axil_rst),

            .s_axil_awaddr  (s_axil_awaddr),
            .s_axil_awprot  (s_axil_awprot),
            .s_axil_awvalid (s_axil_awvalid),
            .s_axil_awready (s_axil_awready),
            .s_axil_wdata   (s_axil_wdata),
            .s_axil_wstrb   (s_axil_wstrb),
            .s_axil_wvalid  (s_axil_wvalid),
            .s_axil_wready  (s_axil_wready),
            .s_axil_bresp   (s_axil_bresp),
            .s_axil_bvalid  (s_axil_bvalid),
            .s_axil_bready  (s_axil_bready),
            .s_axil_araddr  (s_axil_araddr),
            .s_axil_arprot  (s_axil_arprot),
            .s_axil_arvalid (s_axil_arvalid),
            .s_axil_arready (s_axil_arready),
            .s_axil_rdata   (s_axil_rdata),
            .s_axil_rresp   (s_axil_rresp),
            .s_axil_rvalid  (s_axil_rvalid),
            .s_axil_rready  (s_axil_rready),

            .iADCh0Data     (wADCh0Data),
            .iADCh1Data     (wADCh1Data),
            .iADCh2Data     (wADCh2Data),
            .iADCh3Data     (wADCh3Data),
            .iADCh4Data     (wADCh4Data),
            .iADCh5Data     (wADCh5Data),
            .iADCh6Data     (wADCh6Data),
            .iADCh7Data     (wADCh7Data)
        );

endmodule
