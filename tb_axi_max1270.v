`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/07/02 22:39:41
// Design Name: 
// Module Name: tb_phy
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_max1270_Phy;

    /*
    * AXI-lite slave interface
    */
    parameter AXIL_ADDR_WIDTH           = 32              ;
    parameter AXIL_DATA_WIDTH           = 32              ;
    parameter AXIL_STRB_WIDTH           = AXIL_DATA_WIDTH/8    ;

    reg                           s_axil_rst            ; // SDR 100MHz
    reg                           s_axil_clk          ; // SDR 200Mhz



    // 200 MHz
    initial                 
    begin
        s_axil_clk          <= 1'b0;
        #10000;
        forever
        begin    
            s_axil_clk      <= 1'b1;
            #5000;
            s_axil_clk      <= 1'b0;
            #5000;
        end
    end
    reg  [AXIL_ADDR_WIDTH-1:0]      s_axil_awaddr                             ;
    reg  [2:0]                 s_axil_awprot                             ;
    reg                        s_axil_awvalid                            ;
    reg  [AXIL_DATA_WIDTH-1:0]      s_axil_wdata                              ;
    reg  [AXIL_STRB_WIDTH-1:0]      s_axil_wstrb                              ;
    reg                        s_axil_wvalid                             ;
    reg                        s_axil_bready                             ;
    reg  [AXIL_ADDR_WIDTH-1:0]      s_axil_araddr                             ;
    reg  [2:0]                 s_axil_arprot                             ;
    reg                        s_axil_arvalid                            ;
    reg                        s_axil_rready                             ;

    wire                       s_axil_awready                            ;
    wire                       s_axil_wready                             ;
    wire [1:0]                 s_axil_bresp                              ;
    wire                       s_axil_bvalid                             ;
    wire                       s_axil_arready                            ;
    wire [AXIL_DATA_WIDTH-1:0]      s_axil_rdata                              ;
    wire [1:0]                 s_axil_rresp                              ;
    wire                       s_axil_rvalid                             ;

    reg                    I_MAX1270_MISO = 0;
    wire                   O_MAX1270_SCK  ;
    wire                   O_MAX1270_MOSI ;
    wire                   O_MAX1270_CS   ;
    wire                   O_MAX1270_SHDN ;
    reg                    I_MAX1270_SSTRB = 0; 

    Max1270_Top inst_Max1270_Phy
        (
            .s_axil_clk          (s_axil_clk          ),
            .s_axil_rst          (s_axil_rst          ),
            
            .s_axil_awaddr       (s_axil_awaddr       ),
            .s_axil_awprot       (s_axil_awprot       ),
            .s_axil_awvalid      (s_axil_awvalid      ),
            .s_axil_awready      (s_axil_awready      ),
            .s_axil_wdata        (s_axil_wdata        ),
            .s_axil_wstrb        (s_axil_wstrb        ),
            .s_axil_wvalid       (s_axil_wvalid       ),
            .s_axil_wready       (s_axil_wready       ),
            .s_axil_bresp        (s_axil_bresp        ),
            .s_axil_bvalid       (s_axil_bvalid       ),
            .s_axil_bready       (s_axil_bready       ),
            .s_axil_araddr       (s_axil_araddr       ),
            .s_axil_arprot       (s_axil_arprot       ),
            .s_axil_arvalid      (s_axil_arvalid      ),
            .s_axil_arready      (s_axil_arready      ),
            .s_axil_rdata        (s_axil_rdata        ),
            .s_axil_rresp        (s_axil_rresp        ),
            .s_axil_rvalid       (s_axil_rvalid       ),
            .s_axil_rready       (s_axil_rready       ),

            .I_MAX1270_MISO  (I_MAX1270_MISO),
            .O_MAX1270_SCK   (O_MAX1270_SCK),
            .O_MAX1270_MOSI  (O_MAX1270_MOSI),
            .O_MAX1270_CS    (O_MAX1270_CS),
            .O_MAX1270_SHDN  (O_MAX1270_SHDN),
            .I_MAX1270_SSTRB (I_MAX1270_SSTRB)
        );



    task AXIL32_WriteChannel;
        input  [AXIL_ADDR_WIDTH-1:0]      r_axil_awaddr ;
        input  [2:0]                 r_axil_awprot ;
        input                        r_axil_awvalid;
        input  [AXIL_DATA_WIDTH-1:0]      r_axil_wdata  ;
        input  [AXIL_STRB_WIDTH-1:0]      r_axil_wstrb  ;
        input                        r_axil_wvalid ;
        input                        r_axil_bready ;
        begin
            @(posedge s_axil_clk);   
            s_axil_awaddr  <= r_axil_awaddr ;
            s_axil_awprot  <= r_axil_awprot ;
            s_axil_awvalid <= r_axil_awvalid;
            s_axil_wdata   <= r_axil_wdata  ;
            s_axil_wstrb   <= r_axil_wstrb  ;
            s_axil_wvalid  <= r_axil_wvalid ;
            s_axil_bready  <= r_axil_bready ;
        end                     
    endtask

    task AXIL32_ReadChannel;
        input  [AXIL_ADDR_WIDTH-1:0]      r_axil_araddr ;
        input  [2:0]                 r_axil_arprot ;
        input                        r_axil_arvalid;
        input                        r_axil_rready ;
        begin
            @(posedge s_axil_clk);   
            s_axil_araddr <= r_axil_araddr ;
            s_axil_arprot <= r_axil_arprot ;
            s_axil_arvalid<= r_axil_arvalid;
            s_axil_rready <= r_axil_rready ;
        end                     
    endtask

    task AXIL32_IN;
        input [31:0] addr;
        output reg [31:0] odata;
        begin
            AXIL32_ReadChannel(addr, 0, 1, 1);
            wait(s_axil_rvalid == 1);
            AXIL32_ReadChannel(addr, 0, 0, 0);  
            odata <= s_axil_rdata;
            @(posedge s_axil_clk);  
        end                  
    endtask

    task AXIL32_OUT;
        input [31:0] addr;
        input [31:0] data;
        begin
            AXIL32_WriteChannel(addr, 3'd0, 1, data, 4'hf, 1, 1);
            wait(s_axil_awready == 1);
            @(posedge s_axil_clk);   
            AXIL32_WriteChannel(   0, 3'd0, 0, data, 4'hf, 0, 0);
        end                          
                      
    endtask

    integer I;

    reg [4:0] Cnt = 0;

    reg DV = 0;
    always @(negedge O_MAX1270_SCK) begin
        if (!O_MAX1270_CS) begin
            case (Cnt)
            5'd11: begin I_MAX1270_SSTRB <= 1; Cnt <= Cnt + 1; end
            5'd17: begin I_MAX1270_SSTRB <= 0;  Cnt <= 0; end
            default: begin I_MAX1270_SSTRB <= 0; Cnt <= Cnt + 1; end
            endcase
        end else begin
            Cnt <= 0;
        end
    end

reg [4:0] Cnt2 = 0;
    always @(negedge O_MAX1270_SCK) begin
        if ((DV == 1) || (I_MAX1270_SSTRB == 1))begin
            case (Cnt2)
            5'd0: begin DV <= 1;  Cnt2 <= Cnt2 + 1; I_MAX1270_MISO <= 1; end
            5'd12: begin DV <= 0;  Cnt2 <= 0; end
            default: begin DV <= 1;  Cnt2 <= Cnt2 + 1; I_MAX1270_MISO <= ~I_MAX1270_MISO; end
            endcase
        end else begin
            DV <= 0;
            Cnt2 <= 0;
            I_MAX1270_MISO <= 0;
        end
    end

    reg [31:0] ADDATA;
    initial
    
        begin
		$dumpfile("./tb_max1270_Phy.vcd");
		$dumpvars(0, tb_max1270_Phy);
        s_axil_rst <= 0;
        # 1000000
        s_axil_rst <= 1;
        repeat (30000) @(posedge s_axil_clk);
        $finish;
        end
    
    initial
    
        begin
        # 1000000

        while(1) begin
            AXIL32_IN(0, ADDATA);
            AXIL32_IN(4, ADDATA);
            AXIL32_IN(8, ADDATA);
            AXIL32_IN(12, ADDATA);
            repeat (100) @(posedge s_axil_clk);
        end
    end

endmodule
