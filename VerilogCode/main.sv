`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 20:28:05
// Design Name: 
// Module Name: main
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
//  The FILE_TYPE of this file is set to SystemVerilog to utilize SystemVerilog features.
//  Generally to apply SystemVerilog syntax, the file extension should be ".sv" rather than ".v"
//  If you want to choose between verilog2001 and SystemVerilog without changing the file extension, 
//  right-click on the file name in "Design Sources", choose "Source Node Properties...", and 
//  change FILE_TYPE in Properties tab.
//////////////////////////////////////////////////////////////////////////////////
function integer bits_to_represent; //https://www.beyond-circuits.com/wordpress/2008/11/constant-functions/
    input integer value;
    begin
        for (bits_to_represent=0; value>0; bits_to_represent=bits_to_represent+1)
            value = value>>1;
    end
endfunction

module main(
    input  wire Uart_RXD,
    output Uart_TXD,
    input  wire CLK100MHZ,
    input  wire BTN0,
    input  wire BTN1,
    input  wire BTN2,

    input  wire ja_7, // EXT_PROFILE1_1
    input  wire ja_6, // EXT_IOUPDATE1
    input  wire ja_5, // EXT_PROFILE2_0
    input  wire ja_4, // EXT_PROFILE2_2
    
    input  wire ja_3, // EXT_PROFILE1_2
    input  wire ja_2, // EXT_PROFILE1_0
    input  wire ja_1, // EXT_IOUPDATE2
    input  wire ja_0, // EXT_PROFILE2_1
    
    output wire jb_0, // PROFILE2_1
    output wire jb_1, // IOUPDATE2
    output wire jb_2, // PROFILE1_0
    output wire jb_3, // PROFILE1_2
    
    output wire jb_4, // PROFILE2_2
    output wire jb_5, // PROFILE2_0
    output wire jb_6, // IOUPDATE1
    output wire jb_7, // PROFILE1_1
    
    output wire jc_0, // SCLK1
    output wire jc_1, // CSB1
    output wire jc_2, // MASTERRESET1
    output wire jc_3, // EXT_PWR_DOWN2
    output wire jc_4, // SDIO1
    output wire jc_5, // CSB2
    output wire jc_6, // Not Connected
    output wire jc_7, // EXT_PWR_DOWN1
    
    //////////////////////////////////////////////////////////////////////////
    //RESERVED PINS
    //////////////////////////////////////////////////////////////////////////
    output jd_0,
    output jd_1,
    output jd_2,
    output jd_3,
    output jd_4,
    output jd_5,
    output jd_6,
    output jd_7,
    output [5:2] led,
    output led0_r,
    output led0_g,
    output led0_b,
    output led1_r,
    output led1_g,
    output led1_b,
    output d5, d4, d3, d2, d1, d0 // For debugging purpose    
);
    
    
/////////////////////////////////////////////////////////////////
// UART setting
/////////////////////////////////////////////////////////////////
parameter ClkFreq                           = 100000000;	// make sure this matches the clock frequency on your board
parameter BaudRate                          = 57600;    // Baud rate

/////////////////////////////////////////////////////////////////
// Global setting
/////////////////////////////////////////////////////////////////
parameter BTF_MAX_BYTES                     = 9'h100;
parameter BTF_MAX_BUFFER_WIDTH              = 8 * BTF_MAX_BYTES;
parameter BTF_MAX_BUFFER_COUNT_WIDTH        = bits_to_represent(BTF_MAX_BYTES);


/////////////////////////////////////////////////////////////////
// To receive data from PC
/////////////////////////////////////////////////////////////////
parameter BTF_RX_BUFFER_BYTES               = BTF_MAX_BYTES;
parameter BTF_RX_BUFFER_WIDTH               = BTF_MAX_BUFFER_WIDTH;
parameter BTF_RX_BUFFER_COUNT_WIDTH         = BTF_MAX_BUFFER_COUNT_WIDTH;
parameter CMD_RX_BUFFER_BYTES               = 4'hf;
parameter CMD_RX_BUFFER_WIDTH               = 8 * CMD_RX_BUFFER_BYTES;

wire [BTF_RX_BUFFER_WIDTH:1] BTF_Buffer;
wire [BTF_RX_BUFFER_COUNT_WIDTH-1:0] BTF_Length;

wire [CMD_RX_BUFFER_WIDTH:1] CMD_Buffer;
wire [3:0] CMD_Length;    
wire CMD_Ready;

wire esc_char_detected;
wire [7:0] esc_char;

wire wrong_format;
    

data_receiver receiver(
    .RxD                                    (Uart_RXD), 
    .clk                                    (CLK100MHZ), 
    .BTF_Buffer                             (BTF_Buffer), 
    .BTF_Length                             (BTF_Length), 
    .CMD_Buffer                             (CMD_Buffer), 
    .CMD_Length                             (CMD_Length), 
    .CMD_Ready                              (CMD_Ready), 
    .esc_char_detected                      (esc_char_detected), 
    .esc_char                               (esc_char),
    .wrong_format                           (wrong_format)
);
defparam receiver.BTF_RX_BUFFER_COUNT_WIDTH = BTF_RX_BUFFER_COUNT_WIDTH;
defparam receiver.BTF_RX_BUFFER_BYTES       = BTF_RX_BUFFER_BYTES; // can be between 1 and 2^BTF_RX_BUFFER_COUNT_WIDTH - 1
defparam receiver.BTF_RX_BUFFER_WIDTH       = BTF_RX_BUFFER_WIDTH;
defparam receiver.ClkFreq                   = ClkFreq;
defparam receiver.BaudRate                  = BaudRate;
defparam receiver.CMD_RX_BUFFER_BYTES       = CMD_RX_BUFFER_BYTES;
defparam receiver.CMD_RX_BUFFER_WIDTH       = CMD_RX_BUFFER_WIDTH;

/////////////////////////////////////////////////////////////////
// To send data to PC
/////////////////////////////////////////////////////////////////

parameter TX_BUFFER1_BYTES                  = 4'hf;
parameter TX_BUFFER1_WIDTH                  = 8 * TX_BUFFER1_BYTES;
parameter TX_BUFFER1_LENGTH_WIDTH           = bits_to_represent(TX_BUFFER1_BYTES);

parameter TX_BUFFER2_BYTES                  = BTF_MAX_BYTES;
parameter TX_BUFFER2_WIDTH                  = BTF_MAX_BUFFER_WIDTH;
parameter TX_BUFFER2_LENGTH_WIDTH           = BTF_MAX_BUFFER_COUNT_WIDTH;


reg  [TX_BUFFER1_LENGTH_WIDTH-1:0] TX_buffer1_length;
reg  [1:TX_BUFFER1_WIDTH] TX_buffer1;
reg  TX_buffer1_ready;

reg  [TX_BUFFER2_LENGTH_WIDTH-1:0] TX_buffer2_length;
reg  [1:TX_BUFFER2_WIDTH] TX_buffer2;
reg  TX_buffer2_ready;


wire TX_FIFO_ready;

wire [1:32] monitoring_32bits;

data_sender sender(
    .FSMState                               (),
    .clk                                    (CLK100MHZ),
    .TxD                                    (Uart_TXD),
    .esc_char_detected                      (esc_char_detected),
    .esc_char                               (esc_char),
    .wrong_format                           (wrong_format),
    .TX_buffer1_length                      (TX_buffer1_length),
    .TX_buffer1                             (TX_buffer1),
    .TX_buffer1_ready                       (TX_buffer1_ready),
    .TX_buffer2_length                      (TX_buffer2_length),
    .TX_buffer2                             (TX_buffer2),
    .TX_buffer2_ready                       (TX_buffer2_ready),
    .TX_FIFO_ready                          (TX_FIFO_ready),
    .bits_to_send                           (monitoring_32bits)
);

defparam sender.ClkFreq                     = ClkFreq;
defparam sender.BaudRate                    = BaudRate;
defparam sender.TX_BUFFER1_LENGTH_WIDTH     = TX_BUFFER1_LENGTH_WIDTH;
defparam sender.TX_BUFFER1_BYTES            = TX_BUFFER1_BYTES;
defparam sender.TX_BUFFER1_WIDTH            = TX_BUFFER1_WIDTH;
defparam sender.TX_BUFFER2_LENGTH_WIDTH     = TX_BUFFER2_LENGTH_WIDTH;
defparam sender.TX_BUFFER2_BYTES            = TX_BUFFER2_BYTES;
defparam sender.TX_BUFFER2_WIDTH            = TX_BUFFER2_WIDTH;




/////////////////////////////////////////////////////////////////
// LED0 & LED1 intensity adjustment
/////////////////////////////////////////////////////////////////

reg [7:0] LED_intensity;
wire red0, green0, blue0, red1, green1, blue1;
initial begin
    LED_intensity <= 0;
end

led_intensity_adjust led_intensity_modulator(
    .led0_r                                 (led0_r), 
    .led0_g                                 (led0_g), 
    .led0_b                                 (led0_b), 
    .led1_r                                 (led1_r), 
    .led1_g                                 (led1_g), 
    .led1_b                                 (led1_b), 
    .red0                                   (red0), 
    .green0                                 (green0), 
    .blue0                                  (blue0), 
    .red1                                   (red1), 
    .green1                                 (green1), 
    .blue1                                  (blue1),
    .intensity                              (LED_intensity), 
    .CLK100MHZ                              (CLK100MHZ) 
);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Command definitions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////
// Command definition for *IDN? command
/////////////////////////////////////////////////////////////////
parameter CMD_IDN                           = "*IDN?";
parameter IDN_REPLY                         = "Quiqcl AD9910"; // 13 characters


/////////////////////////////////////////////////////////////////
// Command definition for DDS
/////////////////////////////////////////////////////////////////
parameter CMD_WRITE_DDS_REG                 = "WRITE DDS REG"; // 13 characters
parameter CMD_RESET_DRIVER                  = "RESET DRIVER";        //12 characters. this reset ad9910 driver. notice that 
                                                    //fifo_generator IP requires 6 cycles to work properly at least
                                                    //after reset 
parameter CMD_SET_COUNTER                   = "SET COUNTER";      // 13 characters. this sets auto mode of FPGA
parameter CMD_AUTO_START                    = "AUTO START";            // 10 characters. this start auto mode of FPGA
parameter CMD_AUTO_STOP                     = "AUTO STOP";              // 9 characters. this stop auto mode of FPGA
parameter CMD_SET_DDS_PIN                   = "SET DDS PIN";          // 11 characters. this sets DDS profile, parallel, io_update pin
parameter CMD_WRITE_FIFO                    = "WRITE FIFO";            // 10 characters. this store data to FIFO. FIFO depth is set to 512
parameter CMD_READ_RTI_FIFO                 = "READ RTI FIFO";      // 13 characters. this read rti_core_prime FIFO
parameter CMD_OVERRIDE_EN                   = "OVERRIDE EN";       // 12 characters. this sets FPGA to manula mode
parameter CMD_OVERRIDE_DIS                  = "OVERRIDE DIS";       // 13 characters. this sets FPGA to manula mode
parameter CMD_IOUPDATE_DDS_REG              = "DDS IO UPDATE";   // 13 characters. this makes IO_UPDATE pulse
parameter CMD_EXCEPTION_LOG                 = "EXCEPTION LOG"; // 13 characters. report exceptions occured
parameter CMD_DDS_PWR_DOWN1                 = "DDS PWR DOWN1"; // 13 characters. power down DDS1
parameter CMD_DDS_PWR_DOWN2                 = "DDS PWR DOWN2"; // 13 characters. power down DDS2
parameter CMD_DDS_PWR_ON1                   = "DDS PWR ON1"; // 11 characters. power ON DDS1
parameter CMD_DDS_PWR_ON2                   = "DDS PWR ON2"; // 11 characters. power up DDS2
parameter CMD_DDS_RESET                     = "DDS RESET"; // 9 characters. reset all DDS
parameter CMD_DDS_EXTERNAL                  = "EXTERNAL"; // 8 use external IOUPDATE and PROFILE
parameter CMD_DDS_INTERNAL                  = "INTERNAL"; // 8 use internal IOUPDATE and PROFILE

/////////////////////////////////////////////////////////////////
// Parameter definition for DDS
/////////////////////////////////////////////////////////////////
parameter INST_LENGTH                       = 8'h10;
parameter INST_WIDTH                        = INST_LENGTH * 8;
parameter OVERRIDE_LENGTH                   = 8'h8;
parameter OVERRIDE_WIDTH                    = OVERRIDE_LENGTH * 8;

parameter NUM_CS                            = 8'h2;        // number SPI slave
parameter DEST_VAL                          = 12'h1;     // destination number of ad9910
parameter CHANNEL_LENGTH                    = 12;  // length of channel in destination

reg  auto_start;
reg  reset_driver;
reg  flush_rto_fifo;
reg  write_rto_fifo;
reg  [INST_WIDTH - 1:0] rto_fifo_din;
reg  flush_rti_fifo;
reg  read_rti_fifo;
reg  gpo_override_en;
reg  gpo_selected_en;
reg  [OVERRIDE_WIDTH - 1:0] gpo_override_value;            
reg  [2:0]busy_wait_counter;
reg  [4:0] io_update_count;
reg select_io_profile;
reg  [4:0] dds_reset_count;
reg  dds_reset;
reg  dds_pwr_down1;
reg  dds_pwr_down2;
reg  rto_timestamp_error_buffer;
reg  [INST_WIDTH - 1:0] rto_timestamp_error_data_buffer;
reg  rto_overflow_error_buffer;
reg  [INST_WIDTH - 1:0] rto_overflow_error_data_buffer;
reg  gpo_overrided_buffer;
reg  gpo_busy_error_buffer;
reg  [INST_WIDTH - 1:0] gpo_error_data_buffer;
reg  rti_overflow_error_buffer;
reg  [INST_WIDTH - 1:0] rti_overflow_error_data_buffer;
reg  reset_error;

wire [63:0] counter;
wire [INST_WIDTH - 1:0] rto_timestamp_error_data;    
wire [INST_WIDTH - 1:0] rto_overflow_error_data;     
wire rto_timestamp_error;                           
wire rto_overflow_error;                            
wire rto_fifo_full;                                 
wire rto_fifo_empty;                                
wire [INST_WIDTH - 1:0] rti_out;                     
wire [INST_WIDTH - 1:0] rti_overflow_error_data;     
wire rti_overflow_error;                            
wire rti_underflow_error;                           
wire rti_fifo_full;                                 
wire rti_fifo_empty;                                
wire spi_busy;                                      
wire [INST_WIDTH - 1:0] gpo_error_data;              
wire gpo_overrided;                                 
wire gpo_busy_error;                                
wire gpi_data_ready;         
wire reset_driver_bufg;           
wire [INST_WIDTH - 1:0] gpi_out;
wire [ NUM_CS - 1:0] io;
wire sck;
wire [NUM_CS-1:0] cs;
wire io_update1;
wire io_update2;
wire [2:0] profile1;
wire [2:0] profile2;
wire [18:0] parallel_out;   

BUFG BUFG_inst (
   .O(reset_driver_bufg), 
   .I(reset_driver) 
);

//AD9910 driver
AD9910_driver
#(
    .NUM_CS                                 (NUM_CS),
    .DEST_VAL                               (DEST_VAL),
    .CHANNEL_LENGTH                         (CHANNEL_LENGTH)
)
AD9910_driver_0
(
    .clk                                    (CLK100MHZ),
    .reset                                  (reset_driver_bufg),
    .auto_start                             (auto_start),
    .flush_rto_fifo                         (flush_rto_fifo),
    .write_rto_fifo                         (write_rto_fifo),
    .rto_fifo_din                           (rto_fifo_din),
    .counter                                (counter),
    .flush_rti_fifo                         (flush_rti_fifo),
    .read_rti_fifo                          (read_rti_fifo),
    .gpo_override_en                        (gpo_override_en),
    .gpo_selected_en                        (gpo_selected_en),
    .gpo_override_value                     (gpo_override_value),
    .rto_timestamp_error_data               (rto_timestamp_error_data),
    .rto_overflow_error_data                (rto_overflow_error_data),
    .rto_timestamp_error                    (rto_timestamp_error),
    .rto_overflow_error                     (rto_overflow_error),
    .rto_fifo_full                          (rto_fifo_full),
    .rto_fifo_empty                         (rto_fifo_empty),
    .rti_out                                (rti_out),
    .rti_overflow_error_data                (rti_overflow_error_data),
    .rti_overflow_error                     (rti_overflow_error),
    .rti_underflow_error                    (rti_underflow_error),
    .rti_fifo_full                          (rti_fifo_full),
    .rti_fifo_empty                         (rti_fifo_empty),
    .busy                                   (spi_busy),
    .gpo_error_data                         (gpo_error_data),
    .gpo_overrided                          (gpo_overrided),
    .gpo_busy_error                         (gpo_busy_error),
    .gpi_data_ready                         (gpi_data_ready),
    .gpi_out                                (gpi_out),
    .io                                     (jc_4),
    .sck                                    (sck),
    .cs                                     (cs),
    .io_update1                             (io_update1),
    .io_update2                             (io_update2),
    .profile1                               (profile1),
    .profile2                               (profile2),
    .parallel_out                           (parallel_out)
);


always @(posedge CLK100MHZ) begin
    if(reset_driver_bufg == 1'b1 | reset_error == 1'b1) begin
        rto_timestamp_error_buffer <= 1'b0;
        rto_overflow_error_buffer <= 1'b0;
        gpo_busy_error_buffer <= 1'b0;
        gpo_overrided_buffer <= 1'b0;
        rti_overflow_error_buffer <= 1'b0;
        rto_timestamp_error_data_buffer <= 'h0;
        rto_overflow_error_data_buffer <= 'h0;
        gpo_error_data_buffer <= 'h0;
        rti_overflow_error_data_buffer <= 'h0;
        reset_error <= 1'b0;
    end
    else begin
        if( rto_timestamp_error == 1'b1 ) begin
            if( rto_timestamp_error ) begin
                rto_timestamp_error_buffer <= 1'b1;
                rto_timestamp_error_data_buffer[INST_WIDTH - 1:0]  <= rto_timestamp_error_data[INST_WIDTH - 1:0];
            end
            if( rto_overflow_error ) begin
                rto_overflow_error_buffer <= 1'b1;
                rto_overflow_error_data_buffer[INST_WIDTH - 1:0]  <= rto_overflow_error_data[INST_WIDTH - 1:0];
            end
            
            if( gpo_busy_error ) begin
                gpo_busy_error_buffer <= 1'b1;
                gpo_error_data_buffer [INST_WIDTH - 1:0] <= gpo_error_data [INST_WIDTH - 1:0];
            end
            else if( gpo_overrided ) begin
                gpo_overrided_buffer <= 1'b1;
                gpo_error_data_buffer [INST_WIDTH - 1:0] <= gpo_error_data [INST_WIDTH - 1:0];
            end
            
            if ( rti_overflow_error ) begin
                rti_overflow_error_buffer <= 1'b1;
                rti_overflow_error_data_buffer[INST_WIDTH - 1:0] <= rti_overflow_error_data[INST_WIDTH - 1:0];
            end
        end
    end
end

reg reset_counter;
reg start_counter;
reg[63:0] counter_offset;
reg counter_offset_en;
timestamp_counter timestamp_counter_0(
    .clk(CLK100MHZ),
    .reset(reset_counter),
    .start(start_counter),
    .counter_offset(counter_offset),
    .offset_en(counter_offset_en),
    .counter(counter)
);

////
//****code modified for AD9910****
// ja_6 and ja_1 are directly connected to IOBUF, so these are not connected below "assign" com
// select_io_profile = 1 -> external
// select_io_profile = 0 -> internal
////
reg ja_0_buffer1;
reg ja_0_buffer2;
reg ja_1_buffer1;
reg ja_1_buffer2;
reg ja_2_buffer1;
reg ja_2_buffer2;
reg ja_3_buffer1;
reg ja_3_buffer2;
reg ja_4_buffer1;
reg ja_4_buffer2;
reg ja_5_buffer1;
reg ja_5_buffer2;
reg ja_6_buffer1;
reg ja_6_buffer2;
reg ja_7_buffer1;
reg ja_7_buffer2;

assign jb_7 = (select_io_profile == 1'b1) ? ja_7_buffer2 : profile1[1];
assign jb_6 = (select_io_profile == 1'b1) ? ja_6_buffer2 : io_update1;
assign jb_5 = (select_io_profile == 1'b1) ? ja_5_buffer2 : profile2[0];
assign jb_4 = (select_io_profile == 1'b1) ? ja_4_buffer2 : profile2[2];
assign jb_3 = (select_io_profile == 1'b1) ? ja_3_buffer2 : profile1[2];
assign jb_2 = (select_io_profile == 1'b1) ? ja_2_buffer2 : profile1[0];
assign jb_1 = (select_io_profile == 1'b1) ? ja_1_buffer2 : io_update2;
assign jb_0 = (select_io_profile == 1'b1) ? ja_0_buffer2 : profile2[1];

always @ (posedge CLK100MHZ) begin
    {ja_0_buffer2, ja_0_buffer1} <= {ja_0_buffer1,ja_0};
    {ja_1_buffer2, ja_1_buffer1} <= {ja_1_buffer1,ja_1};
    {ja_2_buffer2, ja_2_buffer1} <= {ja_2_buffer1,ja_2};
    {ja_3_buffer2, ja_3_buffer1} <= {ja_3_buffer1,ja_3};
    {ja_4_buffer2, ja_4_buffer1} <= {ja_4_buffer1,ja_4};
    {ja_5_buffer2, ja_5_buffer1} <= {ja_5_buffer1,ja_5};
    {ja_6_buffer2, ja_6_buffer1} <= {ja_6_buffer1,ja_6};
    {ja_7_buffer2, ja_7_buffer1} <= {ja_7_buffer1,ja_7};
end

assign jc_0 = sck;
assign jc_1 = cs[0];
assign jc_2 = dds_reset;
assign jc_3 = dds_pwr_down2;
assign jc_5 = cs[1];
assign jc_6 = 1'b0;
assign jc_7 = dds_pwr_down1;

/////////////////////////////////////////////////////////////////
// Command definition for DNA_PORT command
/////////////////////////////////////////////////////////////////
parameter CMD_DNA_PORT                      = "DNA_PORT";
wire [63:0] DNA_wire;
device_DNA device_DNA_inst(
    .clk                                    (CLK100MHZ),
    .DNA                                    (DNA_wire) // If 4 MSBs == 4'h0, DNA_PORT reading is not finished. If 4 MSBs == 4'h1, DNA_PORT reading is done 
);

/////////////////////////////////////////////////////////////////
// Command definition for LED0 & LED1 intensity adjustment
/////////////////////////////////////////////////////////////////
parameter CMD_ADJUST_INTENSITY              = "ADJ INTENSITY"; // 13 characters
parameter CMD_READ_INTENSITY                = "READ INTENSITY"; // 14 characters




/////////////////////////////////////////////////////////////////
// Command definition to investigate the contents in the BTF buffer
/////////////////////////////////////////////////////////////////
// Capturing the snapshot of BTF buffer
parameter CMD_CAPTURE_BTF_BUFFER            = "CAPTURE BTF"; // 11 characters
reg [BTF_RX_BUFFER_WIDTH:1] BTF_capture;
// Setting the number of bytes to read from the captured BTF buffer
parameter CMD_SET_BTF_BUFFER_READING_COUNT  = "BTF READ COUNT"; // 14 characters
reg [BTF_RX_BUFFER_COUNT_WIDTH-1:0] BTF_read_count;
// Read from the captured BTF buffer
parameter CMD_READ_BTF_BUFFER               = "READ BTF"; // 8 characters



/////////////////////////////////////////////////////////////////
// Command definition for bit patterns manipulation
/////////////////////////////////////////////////////////////////
// This command uses the first PATTERN_WIDTH bits as mask bits to update and update those bits with the following PATTERN_WIDTH bits
parameter CMD_UPDATE_BIT_PATTERNS           = "UPDATE BITS"; // 11 characters
parameter PATTERN_BYTES                     = 4;
parameter PATTERN_WIDTH                     = PATTERN_BYTES * 8; 
reg [1:PATTERN_WIDTH] patterns;
wire [1:PATTERN_WIDTH] pattern_masks;
wire [1:PATTERN_WIDTH] pattern_data;

assign pattern_masks = BTF_Buffer[2*PATTERN_WIDTH:PATTERN_WIDTH+1];
assign pattern_data = BTF_Buffer[PATTERN_WIDTH:1];

// This command reads the 32-bit patterns
parameter CMD_READ_BIT_PATTERNS             = "READ BITS"; // 9 characters




/////////////////////////////////////////////////////////////////
// Main FSM
/////////////////////////////////////////////////////////////////
reg [3:0] main_state;
parameter MAIN_IDLE                         = 4'h0;
parameter MAIN_DDS_WAIT_FOR_BUSY_ON         = 4'h1;
parameter MAIN_DDS_WAIT_FOR_BUSY_OFF        = 4'h2;
parameter MAIN_DDS_RESET                    = 4'h3;
parameter MAIN_DRIVER_RESET                 = 4'h7;
parameter MAIN_SET_COUNTER                  = 4'h8;
parameter MAIN_SET_DDS_PIN                  = 4'ha;
parameter MAIN_WRITE_FIFO                   = 4'hb;
parameter MAIN_READ_RTI_FIFO                = 4'hc;
parameter MAIN_DDS_IOUPDATE_OUT             = 4'hd;
parameter MAIN_DDS_IOUPDATE_END             = 4'he;
parameter MAIN_UNKNOWN_CMD                  =4'hf;

initial begin
    main_state <= MAIN_IDLE;
    patterns <= 'd0;
    TX_buffer1_ready <= 1'b0;
    TX_buffer2_ready <= 1'b0;
end

always @ (posedge CLK100MHZ) begin
    if (esc_char_detected == 1'b1) begin
        if (esc_char == "C") begin
            TX_buffer1_ready <= 1'b0;
            TX_buffer2_ready <= 1'b0;
            main_state <= MAIN_IDLE;
        end
    end
    else begin
        case (main_state)
            MAIN_IDLE:
                if (CMD_Ready == 1'b1) begin

                    if ((CMD_Length == $bits(CMD_IDN)/8) && (CMD_Buffer[$bits(CMD_IDN):1] == CMD_IDN)) begin
                        TX_buffer1[1:$bits(IDN_REPLY)] <= IDN_REPLY;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= $bits(IDN_REPLY)/8;
                        TX_buffer1_ready <= 1'b1;
                    end


                    else if ((CMD_Length == $bits(CMD_WRITE_DDS_REG)/8) && (CMD_Buffer[$bits(CMD_WRITE_DDS_REG):1] == CMD_WRITE_DDS_REG)) begin
                        if (BTF_Length != OVERRIDE_LENGTH) begin
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else begin
                            main_state <= MAIN_DDS_WAIT_FOR_BUSY_ON;
                            gpo_selected_en <= 1'b1;
                            busy_wait_counter[2:0] <= 3'h4;
                            gpo_override_value[OVERRIDE_WIDTH - 1:0] <= BTF_Buffer[OVERRIDE_WIDTH:1];
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_IOUPDATE_DDS_REG)/8) && (CMD_Buffer[$bits(CMD_IOUPDATE_DDS_REG):1] == CMD_IOUPDATE_DDS_REG)) begin
                        if (BTF_Length != OVERRIDE_LENGTH) begin
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else begin
                            io_update_count <= 5'h5;
                            main_state <= MAIN_DDS_IOUPDATE_OUT;
                            gpo_selected_en <= 1'b1;
                            gpo_override_value[OVERRIDE_WIDTH - 1:0] <= BTF_Buffer[OVERRIDE_WIDTH:1];
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_RESET_DRIVER)/8) && (CMD_Buffer[$bits(CMD_RESET_DRIVER):1] == CMD_RESET_DRIVER)) begin
                        begin
                            main_state <= MAIN_DRIVER_RESET;
                            reset_driver <= 1'b1;
                            reset_counter <= 1'b1;
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_SET_COUNTER)/8) && (CMD_Buffer[$bits(CMD_SET_COUNTER):1] == CMD_SET_COUNTER)) begin
                        if (BTF_Length != 64) begin
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else begin
                            main_state <= MAIN_SET_COUNTER;
                            counter_offset_en <= 1'b1;
                            counter_offset[63:0] <= BTF_Buffer[64:1];
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_AUTO_START)/8) && (CMD_Buffer[$bits(CMD_AUTO_START):1] == CMD_AUTO_START)) begin
                        auto_start <= 1'b1;
                        start_counter <= 1'b1;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_AUTO_STOP)/8) && (CMD_Buffer[$bits(CMD_AUTO_STOP):1] == CMD_AUTO_STOP)) begin
                        auto_start <= 1'b0;
                        start_counter <= 1'b0;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_SET_DDS_PIN)/8) && (CMD_Buffer[$bits(CMD_SET_DDS_PIN):1] == CMD_SET_DDS_PIN)) begin
                        if (BTF_Length != OVERRIDE_LENGTH) begin
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else begin
                            main_state <= MAIN_SET_DDS_PIN;
                            gpo_selected_en <= 1'b1;
                            gpo_override_value[OVERRIDE_WIDTH - 1:0] <= BTF_Buffer[OVERRIDE_WIDTH:1];
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_WRITE_FIFO)/8) && (CMD_Buffer[$bits(CMD_WRITE_FIFO):1] == CMD_WRITE_FIFO)) begin
                        if (BTF_Length != INST_LENGTH) begin
                            TX_buffer1[1:13*8] <= {"Wrong length", BTF_Length[7:0]}; // Assuming that BTF_Length is less than 256
                            TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd13;
                            TX_buffer1_ready <= 1'b1;
                        end
                        else begin
                            main_state <= MAIN_WRITE_FIFO;
                            write_rto_fifo <= 1'b1;
                            rto_fifo_din[INST_WIDTH - 1:0] <= BTF_Buffer[INST_WIDTH:1];
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_READ_RTI_FIFO)/8) && (CMD_Buffer[$bits(CMD_READ_RTI_FIFO):1] == CMD_READ_RTI_FIFO)) begin
                        if( rti_fifo_empty == 1'b1 ) begin
                            TX_buffer2[1:( INST_LENGTH + 1 )*8] <= {8'hff,"  RTI FIFO Empty"}; // Assuming that BTF_Length is less than 256
                            TX_buffer2_length[TX_BUFFER2_LENGTH_WIDTH-1:0] <= 'd17;
                            TX_buffer2_ready <= 1'b1;
                        end
                        else begin
                            TX_buffer2[1:( INST_LENGTH + 1 )*8] <= {8'h00, rti_out[INST_WIDTH-1:0] }; // Assuming that BTF_Length is less than 256
                            TX_buffer2_length[TX_BUFFER2_LENGTH_WIDTH-1:0] <= 'd17;
                            TX_buffer2_ready <= 1'b1;
                            main_state <= MAIN_READ_RTI_FIFO;
                            read_rti_fifo <= 1'b1;
                        end
                    end
                    
                    else if ((CMD_Length == $bits(CMD_EXCEPTION_LOG)/8) && (CMD_Buffer[$bits(CMD_EXCEPTION_LOG):1] == CMD_EXCEPTION_LOG)) begin
                        TX_buffer2[1:( INST_LENGTH * 4 + 1 )*8] <= {3'h0,{rto_timestamp_error_buffer, rto_overflow_error_buffer, gpo_overrided_buffer, gpo_busy_error_buffer, rti_overflow_error_buffer},
                                                                    rto_timestamp_error_data_buffer[INST_WIDTH-1:0],
                                                                    rto_overflow_error_data_buffer[INST_WIDTH-1:0],
                                                                    gpo_error_data_buffer[INST_WIDTH-1:0],
                                                                    rti_overflow_error_data_buffer[INST_WIDTH-1:0] }; // Assuming that BTF_Length is less than 256
                        TX_buffer2_length[TX_BUFFER2_LENGTH_WIDTH-1:0] <= 'd65;
                        TX_buffer2_ready <= 1'b1;
                        reset_error <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_OVERRIDE_EN)/8) && (CMD_Buffer[$bits(CMD_OVERRIDE_EN):1] == CMD_OVERRIDE_EN)) begin
                        gpo_override_en <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_OVERRIDE_DIS)/8) && (CMD_Buffer[$bits(CMD_OVERRIDE_DIS):1] == CMD_OVERRIDE_DIS)) begin
                        gpo_override_en <= 1'b0;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_ADJUST_INTENSITY)/8) && (CMD_Buffer[$bits(CMD_ADJUST_INTENSITY):1] == CMD_ADJUST_INTENSITY)) begin
                        LED_intensity[7:0] <= BTF_Buffer[8:1];
                    end

                    else if ((CMD_Length == $bits(CMD_READ_INTENSITY)/8) && (CMD_Buffer[$bits(CMD_READ_INTENSITY):1] == CMD_READ_INTENSITY)) begin
                        TX_buffer1[1:8] <= LED_intensity;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd1;
                        TX_buffer1_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_CAPTURE_BTF_BUFFER)/8) && (CMD_Buffer[$bits(CMD_CAPTURE_BTF_BUFFER):1] == CMD_CAPTURE_BTF_BUFFER)) begin
                        BTF_capture[BTF_RX_BUFFER_WIDTH:1] <= BTF_Buffer[BTF_RX_BUFFER_WIDTH:1];
                        main_state <= MAIN_IDLE;
                    end


                    else if ((CMD_Length == $bits(CMD_SET_BTF_BUFFER_READING_COUNT)/8) && (CMD_Buffer[$bits(CMD_SET_BTF_BUFFER_READING_COUNT):1] == CMD_SET_BTF_BUFFER_READING_COUNT)) begin
                        BTF_read_count[BTF_RX_BUFFER_COUNT_WIDTH-1:0] <= BTF_Buffer[BTF_RX_BUFFER_COUNT_WIDTH:1];
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_READ_BTF_BUFFER)/8) && (CMD_Buffer[$bits(CMD_READ_BTF_BUFFER):1] == CMD_READ_BTF_BUFFER)) begin
                        TX_buffer2[1:TX_BUFFER2_WIDTH] <= BTF_capture[BTF_RX_BUFFER_WIDTH:1];
                        TX_buffer2_length[TX_BUFFER2_LENGTH_WIDTH-1:0] <= BTF_read_count[BTF_RX_BUFFER_COUNT_WIDTH-1:0];
                        TX_buffer2_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_UPDATE_BIT_PATTERNS)/8) && (CMD_Buffer[$bits(CMD_UPDATE_BIT_PATTERNS):1] == CMD_UPDATE_BIT_PATTERNS)) begin
                        patterns <= (patterns & ~pattern_masks) | (pattern_masks & pattern_data);
                    end

                    else if ((CMD_Length == $bits(CMD_READ_BIT_PATTERNS)/8) && (CMD_Buffer[$bits(CMD_READ_BIT_PATTERNS):1] == CMD_READ_BIT_PATTERNS)) begin
                        TX_buffer1[1:PATTERN_WIDTH] <= patterns;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= PATTERN_WIDTH/8;
                        TX_buffer1_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_DNA_PORT)/8) && (CMD_Buffer[$bits(CMD_DNA_PORT):1] == CMD_DNA_PORT)) begin
                        TX_buffer1[1:64] <= DNA_wire;
                        TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 8;
                        TX_buffer1_ready <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_DDS_PWR_DOWN1)/8) && (CMD_Buffer[$bits(CMD_DDS_PWR_DOWN1):1] == CMD_DDS_PWR_DOWN1)) begin
                        dds_pwr_down1 <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end
                        
                    else if ((CMD_Length == $bits(CMD_DDS_PWR_DOWN2)/8) && (CMD_Buffer[$bits(CMD_DDS_PWR_DOWN2):1] == CMD_DDS_PWR_DOWN2)) begin
                        dds_pwr_down2 <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_DDS_PWR_ON1)/8) && (CMD_Buffer[$bits(CMD_DDS_PWR_ON1):1] == CMD_DDS_PWR_ON1)) begin
                        dds_pwr_down1 <= 1'b0;
                        main_state <= MAIN_IDLE;
                    end
                        
                    else if ((CMD_Length == $bits(CMD_DDS_PWR_ON2)/8) && (CMD_Buffer[$bits(CMD_DDS_PWR_ON2):1] == CMD_DDS_PWR_ON2)) begin
                        dds_pwr_down2 <= 1'b0;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else if ((CMD_Length == $bits(CMD_DDS_RESET)/8) && (CMD_Buffer[$bits(CMD_DDS_RESET):1] == CMD_DDS_RESET)) begin
                        dds_reset_count <= 5'h1f;
                        dds_reset <= 1'b1;
                        main_state <= MAIN_DDS_RESET;
                    end

                    else if ((CMD_Length == $bits(CMD_DDS_EXTERNAL)/8) && (CMD_Buffer[$bits(CMD_DDS_EXTERNAL):1] == CMD_DDS_EXTERNAL)) begin
                        select_io_profile <= 1'b1;
                        main_state <= MAIN_IDLE;
                    end

                    else if ((CMD_Length == $bits(CMD_DDS_INTERNAL)/8) && (CMD_Buffer[$bits(CMD_DDS_INTERNAL):1] == CMD_DDS_INTERNAL)) begin
                        select_io_profile <= 1'b0;
                        main_state <= MAIN_IDLE;
                    end
                    
                    else begin
                        main_state <= MAIN_UNKNOWN_CMD;
                    end
                end
                else begin
                    TX_buffer1_ready <= 1'b0;
                    TX_buffer2_ready <= 1'b0;
                end
                
            MAIN_DDS_RESET: begin
                dds_reset_count <= dds_reset_count - 5'h1;
                if( dds_reset_count == 5'h0 ) begin
                    dds_reset <= 1'b0;
                    main_state <= MAIN_IDLE;
                end
            end


            MAIN_DDS_WAIT_FOR_BUSY_ON: begin
                    gpo_selected_en <= 1'b0;
                    busy_wait_counter[2:0] <= {3'h0,busy_wait_counter[2:1]};
                    if( busy_wait_counter[2:0] == 3'h1) begin
                    busy_wait_counter[2:0] <= 3'h0;
                        main_state <= MAIN_DDS_WAIT_FOR_BUSY_OFF;;
                    end
                end

            MAIN_DDS_WAIT_FOR_BUSY_OFF: begin
                    if( spi_busy == 1'b0 ) main_state <= MAIN_IDLE;
                end
                
            MAIN_DDS_IOUPDATE_OUT: begin
                gpo_selected_en <= 1'b0;
                io_update_count <= io_update_count - 5'd1;
                if( io_update_count == 5'd0 ) begin
                    main_state <= MAIN_DDS_IOUPDATE_END;
                    gpo_selected_en <= 1'b1;
                    gpo_override_value[OVERRIDE_WIDTH - 1:0] <= 'h0 | 'h2 << (32 + CHANNEL_LENGTH);
                    end
                end
                
            MAIN_DDS_IOUPDATE_END: begin
                    gpo_selected_en <= 1'b0;
                    io_update_count <= 5'h0;
                    main_state <= MAIN_IDLE;
                end
                
            MAIN_DRIVER_RESET: begin
                    main_state <= MAIN_IDLE;
                    reset_driver <= 1'b0;
                    reset_counter <= 1'b0;
                    gpo_selected_en <= 1'b0;
                    gpo_override_value[OVERRIDE_WIDTH - 1:0] <= 'h0;
                    gpo_override_en <= 1'b0;
                end
                
            MAIN_SET_COUNTER: begin
                    main_state <= MAIN_IDLE;
                    counter_offset_en <= 1'b0;
                    counter_offset[63:0] <= 64'h0;
                end
                
            MAIN_SET_DDS_PIN: begin
                    gpo_selected_en <= 1'b0;
                    main_state <= MAIN_IDLE;
                end
                
            MAIN_WRITE_FIFO: begin
                    main_state <= MAIN_IDLE;
                    write_rto_fifo <= 1'b0;
                end
                
            MAIN_READ_RTI_FIFO: begin
                    main_state <= MAIN_IDLE;
                    read_rti_fifo <= 1'b0;
                end




            MAIN_UNKNOWN_CMD:
                begin
                    TX_buffer1[1:11*8] <= "Unknown CMD";
                    TX_buffer1_length[TX_BUFFER1_LENGTH_WIDTH-1:0] <= 'd11;
                    TX_buffer1_ready <= 1'b1;

                    //led1_b <= ~led1_b;
                    main_state <= MAIN_IDLE;
                end
                
            default:
                main_state <= MAIN_IDLE;
        endcase
    end      
end      
                








////////////////////////////////////////////////////////////////
// Detect when BTN0 is pressed
////////////////////////////////////////////////////////////////
wire BTN0EdgeDetect;
reg BTN0Delay;
initial BTN0Delay = 1'b0;
always @ (posedge CLK100MHZ) begin
    BTN0Delay <= BTN0;
end
assign BTN0EdgeDetect = (BTN0 & !BTN0Delay);




assign {d0, d1, d2, d3, d4, d5} = 6'h00;
assign {led, red1, green1, blue1, red0, green0, blue0} = patterns[1:10];
assign monitoring_32bits = patterns[1:32];

endmodule
