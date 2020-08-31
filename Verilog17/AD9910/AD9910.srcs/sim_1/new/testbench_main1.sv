`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/24 22:24:43
// Design Name: 
// Module Name: testbench_main1
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


module testbench_main1;

logic Uart_RXD;
logic Uart_TXD;
logic CLK100MHZ;
logic BTN0;
logic BTN1;
logic BTN2;
logic ja_7; //powerdown
wire ja_6; //sdio
logic ja_5; //csb
logic ja_4; //reset
logic ja_3; // sclk
logic ja_2; // powerdown2
wire ja_1; //sdio2
logic ja_0; // csb2
logic jb_0;
logic jb_1;
logic jb_2;
logic jb_3;
logic jb_4;
logic jb_5;
logic jb_6;
logic jb_7;
logic [5:2] led;
logic led0_r;
logic led0_g;
logic led0_b;
logic led1_r;
logic led1_g;
logic led1_b;
logic d5, d4, d3, d2, d1, d0;
wire jc_0;
wire jc_1;
wire jc_2;
wire jc_3;
wire jc_4;
wire jc_5;
wire jc_6;
wire jc_7;
wire jd_0;
wire jd_1;
wire jd_2;
wire jd_3;
wire jd_4;
wire jd_5;
wire jd_6;
wire jd_7;

logic io_val;

assign ja_1 = (~main0.AD9910_driver_0.slave_en_wire)? 1'bz:io_val;
assign ja_6 = (~main0.AD9910_driver_0.slave_en_wire)? 1'bz:io_val;

main main0(
    .Uart_RXD(Uart_RXD),
    .Uart_TXD(Uart_TXD),
    .CLK100MHZ(CLK100MHZ),
    .BTN0(BTN0),
    .BTN1(BTN1),
    .BTN2(BTN2),
    .ja_7(ja_7), //powerdown
    .ja_6(ja_6),
    .ja_5(ja_5), //csb
    .ja_4(ja_4), //reset
    .ja_3(ja_3), // sclk
    .ja_2(ja_2), // powerdown2
    .ja_1(ja_1),
    .ja_0(ja_0), // csb2
    .jb_0(jb_0),
    .jb_1(jb_1),
    .jb_2(jb_2),
    .jb_3(jb_3),
    .jb_4(jb_4),
    .jb_5(jb_5),
    .jb_6(jb_6),
    .jb_7(jb_7),
    .jc_0(jc_0),
    .jc_1(jc_1),
    .jc_2(jc_2),
    .jc_3(jc_3),
    .jc_4(jc_4),
    .jc_5(jc_5),
    .jc_6(jc_6),
    .jc_7(jc_7),
    .jd_0(jd_0),
    .jd_1(jd_1),
    .jd_2(jd_2),
    .jd_3(jd_3),
    .jd_4(jd_4),
    .jd_5(jd_5),
    .jd_6(jd_6),
    .jd_7(jd_7),
    .led(led),
    .led0_r(led0_r),
    .led0_g(led0_g),
    .led0_b(led0_b),
    .led1_r(led1_r),
    .led1_g(led1_g),
    .led1_b(led1_b),
    .d5(d5), 
    .d4(d4), 
    .d3(d3), 
    .d2(d2), 
    .d1(d1), 
    .d0(d0) // For debugging purpose    
    );
   
always begin
    #5
    CLK100MHZ = ~CLK100MHZ;
end

parameter MAX_LENGTH = 256;

logic [MAX_LENGTH-1:0] TEMP;
logic [9:0] TEMP_S;
integer i;
initial begin
    //TEMP = (2**256-1) & 256'b 00001010 00001101 11001100 11001100 11001100 00001100 00000000 00000000 11111111 00111111 00001110 00111001 01100001 00110001 00100011;
    //TEMP = (2**256-1) & 256'b 1000010100 1000011010 1110011000 1110011000 1110011000 1000011000 1000000000 1000000000 1111111110 1001111110 1000011100 1001110010 1011000010 1001100010 1001000110;
    
    Uart_RXD = 1;
    CLK100MHZ = 0;
    BTN0 = 0;
    BTN1 = 0;
    BTN2 = 0;
    io_val = 0;
    
    #1000
    TEMP =((2**256 - 1) - (2**160- 1)) + 256'b1000010100100001101010101001001010001010101010110010100100101010100100101000100010010000001010101000101000101010101001101010001010101010010010110001101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**240- 1)) + 256'b100001010010000110101000100000100010000010011100001000000110100000000010000000001000000000100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101010000000001000000000100000000010000111001000000010100000000010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**240- 1)) + 256'b100001010010000110101000100000100010000011111100001000000110100000000011110100101000000110100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101010000000001000000000111111111010011111101111010100100000011010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**240- 1)) + 256'b100001010010000110101000100000100010000011111100001000000110100100000011101001001000001110100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101011100110001110011000111001100010000110001110100110100000111010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**250- 1)) + 256'b1000010100100001101010001000001000100000100111000010000001101000000000100010000010001000001001001110100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101010000000001000000000100000000010000111101000100010100100111010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**240- 1)) + 256'b100001010010000110101000100000100010000011111100001000000110100000000011111100101001010100100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101010000000001000000000111111111010011111101111110100100101010010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**240- 1)) + 256'b100001010010000110101000100000100010000011111100001000000110100100000011110001001001011100100000000010000000001000000000100000000010000000001000000000100000001010001000001000100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101011001100101100110010110011001010001100101111000110100101110010000000001000000000100000000010000000001000000000100000000010000000101000000000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**220- 1)) + 256'b1000010100100001101010000000101000000000100000000010000000001001000000101001110010000000001000000000100000000010000000001000000000100000000010000000101001100000100000000010000000001001100000100110001010011001001001000110;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101001111010100011001010010010101000110010010000001010001010101010100010100100101010100100101010111010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end
    #1000
    TEMP =((2**256 - 1) - (2**140- 1)) + 256'b10000101001000011010101010100010101001001010000010101010100010101001101001000000101001111010101010001010101010101000001010110000101001000010;
    for( i = 0; i <= MAX_LENGTH - 1 ; i++ ) begin
        #17361
        Uart_RXD = TEMP[i];
    end

end

endmodule