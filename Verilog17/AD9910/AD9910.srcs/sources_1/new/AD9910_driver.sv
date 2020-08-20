`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/20 15:08:43
// Design Name: 
// Module Name: AD9910_driver
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


module AD9910_driver
#(
    parameter NUM_CS = 2
)
(
    input wire clk,
    input wire reset,
    input wire auto_start,
    input wire flush_rto_fifo,
    input wire write_rto_fifo,
    input wire [127:0] rto_fifo_din,
    input wire [63:0] counter,
    input wire flush_rti_fifo,
    input wire read_rti_fifo,
    input wire gpo_override_en,
    input wire gpo_selected_en,
    input wire [63:0] gpo_override_value,
    output wire [127:0] rto_timestamp_error_data,
    output wire [127:0] rto_overflow_error_data,
    output wire rto_timestamp_error,
    output wire rto_overflow_error,
    output wire rto_fifo_full,
    output wire rto_fifo_empty,
    output wire [127:0] rti_out,
    output wire [127:0] rti_overflow_error_data,
    output wire rti_overflow_error,
    output wire rti_underflow_error,
    output wire rti_fifo_full,
    output wire rti_fifo_empty,
    output wire busy,
    output wire [127:0] gpo_error_data,
    output wire gpo_overrided,
    output wire gpo_busy_error,
    output wire gpi_data_ready,
    output wire [127:0] gpi_out,
    inout wire io,
    output wire sck,
    output wire [NUM_CS - 1:0] cs
    );
    
wire counter_matched;
wire [127:0] rto_out;
wire [127:0] rti_in;
wire data_ready;
wire spi_busy;
wire selected;
wire spi_config_selected;
wire spi_data_selected;
wire [63:0] gpo_out;
wire [31:0] spi_data_in;
wire [31:0] spi_data_out;
wire gpi_write;
wire sdi_wire;
wire sdo_wire;
wire cpha_wire;
wire cpol_wire;
wire cspol_wire;
wire slave_en_wire;
wire cs_next_wire;
wire sck_next_wire;
wire [NUM_CS - 1:0] cs_val_wire;

assign spi_config_selected = gpo_out[47] && selected;
assign spi_data_selected = (~gpo_out[47]) && selected;
assign spi_data_in[31:0] = gpo_out[31:0];
assign gpi_data_ready = data_ready;
assign busy = spi_busy;

rto_core_prime rto_core_prime_0(
    .clk(clk),
    .auto_start(auto_start),
    .reset(reset),
    .flush(flush_rto_fifo),
    .write(write_rto_fifo),
    .fifo_din(rto_fifo_din),
    .counter(counter),
    .counter_matched(counter_matched),
    .rto_out(rto_out),
    .timestamp_error_data(rto_timestamp_error_data),
    .overflow_error_data(rto_overflow_error_data),
    .timestamp_error(rto_timestamp_error),
    .overflow_error(rto_overflow_error),
    .full(rto_fifo_full),
    .empty(rto_fifo_empty)
    );

rti_core_prime rti_core_prime_0(
    .clk(clk),
    .reset(reset),
    .flush(flush_rti_fifo),
    .write(data_ready),
    .read(read_rti_fifo),
    .rti_in(rti_in),
    .rti_out(rti_out),
    .overflow_error_data(rti_overflow_error_data),
    .overflow_error(rti_overflow_error),
    .underflow_error(rti_underflow_error),
    .full(rti_fifo_full),
    .empty(rti_fifo_empty)
    );
    
gpo_core_prime
#(
    .DEST_VAL(12'h1),
    .CHANNEL_LENGTH(12)
)
gpo_core_prime_0
(
    .CLK100MHZ(clk),
    .reset(reset),
    .override_en(gpo_override_en),
    .selected_en(gpo_selected_en),
    .override_value(gpo_override_value),
    .counter_matched(counter_matched),
    .gpo_in(rto_out),
    .busy(spi_busy),
    .selected(selected),
    .error_data(gpo_error_data),
    .overrided(gpo_overrided),
    .busy_error(gpo_busy_error),
    .gpo_out(gpo_out)
    );
    
gpi_core_prime
#(
    .DEST_VAL(16'h1),
    .CHANNEL_LENGTH(12)
)
gpi_core_prime_0
(
    .clk(clk),
    .reset(reset),
    .gpi_in(spi_data_out),
    .write(gpi_write),
    .counter(counter),
    .data_ready(data_ready),
    .gpi_out(rti_in)
    );
    
spi_fsm_module
#(
    .NUM_CS(2)
)
spi_fsm_module_0
(
    .CLK100MHZ(clk),
    .spi_config_in(spi_data_in),
    .spi_config_selected(spi_config_selected),
    .spi_data_in(spi_data_in),
    .spi_data_selected(spi_data_selected),
    .busy(spi_busy),
    .spi_data_out(spi_data_out),
    .data_write(gpi_write),
    .sdi(sdi_wire),
    .sdo(sdo_wire),
    .cpha(cpha_wire),
    .cpol(cpol_wire),
    .cspol(cspol_wire),
    .slave_en(slave_en_wire),
    .cs_next(cs_next_wire),
    //output wire off_spi(),
    .sck_next(sck_next_wire),
    .cs_val(cs_val_wire)
    );
    
spi_single_output 
#(
    .NUM_CS(2)
)
spi_single_output_0
(
    .CLK100MHZ(clk),
    .cpol(cpol_wire),
    .cspol(cspol_wire),
    .slave_en(slave_en_wire),
    .cs_next(cs_next_wire),
    .sdo(sdo_wire),
    .sck_next(sck_next_wire),
    .cs_val(cs_val_wire),
    .sdi(sdi_wire),
    .io(io),
    .sck(sck),
    .cs(cs)
    );

endmodule
