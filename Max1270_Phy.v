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
module Max1270_Phy (
    clk           ,
    rst           ,
    
    oADCh0Data    ,
    oADCh1Data    ,
    oADCh2Data    ,
    oADCh3Data    ,
    oADCh4Data    ,
    oADCh5Data    ,
    oADCh6Data    ,
    oADCh7Data    ,
    
    I_MAX1270_MISO,
    O_MAX1270_SCK ,
    O_MAX1270_MOSI,
    O_MAX1270_CS  ,
    O_MAX1270_SHDN,
    I_MAX1270_SSTRB 
);

    input                     clk            ;
    input                     rst            ;
    
    output [11:0]             oADCh0Data     ;
    output [11:0]             oADCh1Data     ;
    output [11:0]             oADCh2Data     ;
    output [11:0]             oADCh3Data     ;
    output [11:0]             oADCh4Data     ;
    output [11:0]             oADCh5Data     ;
    output [11:0]             oADCh6Data     ;
    output [11:0]             oADCh7Data     ;
    
    input                     I_MAX1270_MISO ;
    output                    O_MAX1270_SCK  ;
    output                    O_MAX1270_MOSI ;
    output                    O_MAX1270_CS   ;
    output                    O_MAX1270_SHDN ;
    input                     I_MAX1270_SSTRB; 

    reg [11:0]                rADCh0Data;
    reg [11:0]                rADCh1Data;
    reg [11:0]                rADCh2Data;
    reg [11:0]                rADCh3Data;
    reg [11:0]                rADCh4Data;
    reg [11:0]                rADCh5Data;
    reg [11:0]                rADCh6Data;
    reg [11:0]                rADCh7Data;

    reg                       rMAX1270_SCK  ;
    reg                       rMAX1270_MOSI ;
    reg                       rMAX1270_CS   ;
    reg                       rMAX1270_SHDN ;


    reg [7:0]                 rSCKCnt;
    reg                       rSCKBps;

    reg [2:0]                 rMOSICnt;
    reg [2:0]                 rCHCnt;

    reg [7:0]                 rMOSIWaitCnt;


    always @(posedge clk) begin
        if (rst) begin
            rSCKBps <= 0;
            rSCKCnt <= 0;
            rMAX1270_SCK    <= 0;
        end else begin
            if (rSCKCnt <= 8'd49) begin 
                rMAX1270_SCK <= 0;
                rSCKCnt      <= rSCKCnt + 1;
                rSCKBps      <= 0;
            end else if ((rSCKCnt >= 8'd50) && (rSCKCnt < 8'd99)) begin
                rMAX1270_SCK <= 1 & (~rMAX1270_CS);
                rSCKCnt      <= rSCKCnt + 1;
                rSCKBps      <= 0;
            end else if (rSCKCnt == 8'd99) begin
                rMAX1270_SCK <= 1 & (~rMAX1270_CS);
                rSCKCnt      <= 0;
                rSCKBps      <= 1;
            end else begin
                rMAX1270_SCK <= rMAX1270_SCK;
                rSCKCnt      <= rSCKCnt + 1;
                rSCKBps      <= 0;
            end
        end
    end

    localparam MOSI_FSM_BIT = 4;
    localparam MOSI_RESET = 4'b0001;
    localparam MOSI_DATAO = 4'b0010; //
    localparam MOSI_WAIT  = 4'b0100; //

    reg     [MOSI_FSM_BIT-1:0]       rMOSI_cur_state ;

    always @(posedge clk) begin
        if (rst) begin
            rMAX1270_MOSI   <= 0;
            rMAX1270_CS     <= 1;
            rMAX1270_SHDN   <= 1;

            rMOSI_cur_state <= MOSI_RESET;

            rMOSICnt        <= 0;
            rMOSIWaitCnt    <= 0;
            rCHCnt          <= 0;
        end else begin
            if (rSCKBps) begin
                case (rMOSI_cur_state)
                    MOSI_RESET: begin
                        rMAX1270_MOSI   <= 0;
                        rMAX1270_CS     <= 1;
                        rMAX1270_SHDN   <= 1;
                        rMOSI_cur_state <= MOSI_DATAO;
                        rMOSICnt        <= 0;
                        rMOSIWaitCnt    <= 0;
                        rCHCnt          <= 0;
                    end
                    MOSI_DATAO: begin
                        rMAX1270_CS   <= 0;
                        rMAX1270_SHDN <= 1;
                        rMOSIWaitCnt  <= 0;
                        case (rMOSICnt)
                            3'b000 : begin rMAX1270_MOSI <= 1        ; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b001 : begin rMAX1270_MOSI <= rCHCnt[2]; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b010 : begin rMAX1270_MOSI <= rCHCnt[1]; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b011 : begin rMAX1270_MOSI <= rCHCnt[0]; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b100 : begin rMAX1270_MOSI <= 1        ; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b101 : begin rMAX1270_MOSI <= 1        ; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b110 : begin rMAX1270_MOSI <= 0        ; rMOSI_cur_state <= MOSI_DATAO; end 
                            3'b111 : begin rMAX1270_MOSI <= 1        ; rMOSI_cur_state <= MOSI_WAIT ; end 
                        endcase
                        rMOSICnt <= rMOSICnt + 1;
                    end
                    MOSI_WAIT: begin
                        rMAX1270_MOSI <= 0;
                        
                        rMAX1270_SHDN <= 1;
                        rMOSICnt      <= 0;

                        if (rMOSIWaitCnt == 0) begin
                            rMAX1270_CS   <= 0;
                            rCHCnt          <= rCHCnt;
                            rMOSIWaitCnt    <= rMOSIWaitCnt + 1;
                            rMOSI_cur_state <= MOSI_WAIT;
                        end else if (rMOSIWaitCnt == 8'd9) begin
                            rMAX1270_CS   <= 0;
                            rCHCnt          <= rCHCnt + 1;
                            rMOSIWaitCnt    <= 0;
                            rMOSI_cur_state <= MOSI_DATAO;
//                        end else if (rMOSIWaitCnt == 8'd20) begin
//                            rMAX1270_CS   <= 1;
//                            rCHCnt          <= rCHCnt;
//                            rMOSIWaitCnt    <= 0;
//                            rMOSI_cur_state <= MOSI_DATAO;
                        end else begin
                            rMAX1270_CS   <= rMAX1270_CS;
                            rCHCnt          <= rCHCnt;
                            rMOSIWaitCnt    <= rMOSIWaitCnt + 1;
                            rMOSI_cur_state <= MOSI_WAIT;
                        end
                    end
                    default: begin
                        rMAX1270_MOSI   <= 0;
                        rMAX1270_CS     <= 1;
                        rMAX1270_SHDN   <= 1;
                        rCHCnt          <= 0;
                        rMOSI_cur_state <= MOSI_RESET;

                        rMOSICnt        <= 0;
                        rMOSIWaitCnt    <= 0;
                    end
                endcase
            end else begin
                rMOSI_cur_state <= rMOSI_cur_state;
            end
        end
    end

    reg [11:0]                      rDataSLR;
    reg [ 7:0]                      rMISOCnt;

    reg [2:0]                 rLastCHCnt;

    localparam MISO_FSM_BIT = 4;
    localparam MISO_RESET = 4'b0001;
    localparam MISO_DATAI = 4'b0010; //
    localparam MISO_WAIT  = 4'b0100; //

    reg     [MISO_FSM_BIT-1:0]       rMISO_cur_state ;


    always @(posedge clk) begin
        if (rst) begin
            rADCh0Data <= 12'd0;
            rADCh1Data <= 12'd0;
            rADCh2Data <= 12'd0;
            rADCh3Data <= 12'd0;
            rADCh4Data <= 12'd0;
            rADCh5Data <= 12'd0;
            rADCh6Data <= 12'd0;
            rADCh7Data <= 12'd0;
            
            rMISO_cur_state <= MISO_RESET;

            rDataSLR        <= 0;
            rMISOCnt        <= 0;
            rLastCHCnt      <= 0;
        end else begin
            if (rSCKBps) begin
                case (rMISO_cur_state)
                    MISO_RESET: begin
                        if (I_MAX1270_SSTRB) begin
                            rMISO_cur_state <= MISO_DATAI;
                            rLastCHCnt <= rCHCnt;
                        end else begin
                            rMISO_cur_state <= rMISO_cur_state;
                            rLastCHCnt <= rLastCHCnt;
                        end
                        rMISOCnt <= 0;
                        rDataSLR <= 0;
                    end
                    MISO_DATAI: begin
                        rLastCHCnt <= rLastCHCnt;
                        if (rMISOCnt == 8'd11) begin
                            case (rLastCHCnt)
                                3'b000 : begin rADCh0Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b001 : begin rADCh1Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b010 : begin rADCh2Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b011 : begin rADCh3Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b100 : begin rADCh4Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b101 : begin rADCh5Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b110 : begin rADCh6Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                                3'b111 : begin rADCh7Data <= {rDataSLR[10:0], I_MAX1270_MISO}; rMISO_cur_state <= MISO_RESET; end 
                            endcase
                            rMISOCnt <= 0;
                        end else begin
                            rDataSLR <= {rDataSLR[10:0], I_MAX1270_MISO};
                            rMISOCnt <= rMISOCnt + 1;
                        end
                    end
                    // MOSI_WAIT: begin
                    //     rMOSICnt      <= 0;

                    //     if (rMOSIWaitCnt == 0) begin
                    //         rCHCnt          <= rCHCnt + 1;
                    //         rMOSIWaitCnt    <= rMOSIWaitCnt + 1;
                    //         rMOSI_cur_state <= MOSI_WAIT;
                    //     end else if (rMOSIWaitCnt == 8'h9) begin
                    //         rCHCnt          <= rCHCnt;
                    //         rMOSIWaitCnt    <= 0;
                    //         rMOSI_cur_state <= MOSI_DATAO;
                    //     end else begin
                    //         rCHCnt          <= rCHCnt;
                    //         rMOSIWaitCnt    <= rMOSIWaitCnt + 1;
                    //         rMOSI_cur_state <= MOSI_WAIT;
                    //     end
                    // end
                    default: begin
                        rADCh0Data <= 12'd0;
                        rADCh1Data <= 12'd0;
                        rADCh2Data <= 12'd0;
                        rADCh3Data <= 12'd0;
                        rADCh4Data <= 12'd0;
                        rADCh5Data <= 12'd0;
                        rADCh6Data <= 12'd0;
                        rADCh7Data <= 12'd0;
                        
                        rMISO_cur_state <= MISO_RESET;

                        rDataSLR        <= 0;
                        rMISOCnt        <= 0;
                        rLastCHCnt      <= 0;
                    end
                endcase
            end else begin
                rMISO_cur_state <= rMISO_cur_state;
            end
        end
    end

    assign                    O_MAX1270_SCK  = rMAX1270_SCK  ;
    assign                    O_MAX1270_MOSI = rMAX1270_MOSI ;
    assign                    O_MAX1270_CS   = rMAX1270_CS   ;
    assign                    O_MAX1270_SHDN = rMAX1270_SHDN ;

    assign                    oADCh0Data = rADCh0Data;
    assign                    oADCh1Data = rADCh1Data;
    assign                    oADCh2Data = rADCh2Data;
    assign                    oADCh3Data = rADCh3Data;
    assign                    oADCh4Data = rADCh4Data;
    assign                    oADCh5Data = rADCh5Data;
    assign                    oADCh6Data = rADCh6Data;
    assign                    oADCh7Data = rADCh7Data;


endmodule
