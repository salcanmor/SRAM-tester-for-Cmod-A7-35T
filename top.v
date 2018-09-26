`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Description: Top level module containing an UART and a checker module.
//	The checker module, gets the bytes coming from the receiver module and 
// adds one bit. Doing this, we can check the receiver and the transmitter module
// of the UART.
// The baud rate generator is configured for a 50Mhz clock. It accepts input 
// parameters, as well as the rx and tx modules.
//
//////////////////////////////////////////////////////////////////////////////////
module top
( 
    input wire clk,
    input wire reset,
    input wire data_in,
    output wire data_out
	// output wire [7:0] leds
  );

wire [7:0] r_data_bus;
wire [7:0] w_data_bus;



uart uart_unit (
    .clk(clk), 
    .reset(reset), 
    .data_in(data_in), 
    .tx_start(tx_start), 
    .w_data(w_data_bus), 
    .data_out(data_out), 
    .rx_done_tick(rx_done_tick), 
    .tx_done_tick(tx_done_tick), 
    .r_data(r_data_bus),
    .tx_ready(tx_ready)

    );



checker checker_unit (
    .clk(clk), 
    .reset(reset), 
    .rx_done_tick(rx_done_tick), 
    .r_data(r_data_bus), 
    .w_data(w_data_bus),
    .tx_start(tx_start),
    .tx_ready(tx_ready)

    );


//assign leds=w_data_bus;


endmodule