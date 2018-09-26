`timescale 1ns / 1ps

module uart
  #(
    parameter DBIT = 8,			// Number of data bits to receive
				  SB_TICK = 16,	// Number of ticks for the stop bit. 16/24/32 for 1/1,5/2 bits
              DVSR = 326		// Baud rate divisor. DVSR = 50M/(16*baud rate)
  )
  ( 
    input wire clk,
    input wire reset,
    input wire data_in,
    input wire tx_start,
    input wire [7:0] w_data,
    output wire data_out,
    output wire rx_done_tick,
    output wire tx_done_tick,
    output wire tx_ready,
    output wire [7:0] r_data

  );


  //body
  Baud_rate_gen baud_gen_unit (
    .clk(clk), 
    .reset(reset), 
    .tick(tick)
  );


  uart_rx uart_rx_unit (
    .clk(clk), 
    .reset(reset), 
    .data_in(data_in), 
    .s_tick(tick), 
    .rx_done_tick(rx_done_tick), 
    .data_out(r_data)
  );


  uart_tx uart_tx_unit (
    .clk(clk), 
    .reset(reset), 
    .data_in(w_data), 
    .s_tick(tick), 
    .tx_start(tx_start), 
    .tx_done_tick(tx_done_tick), 
    .data_out(data_out),
    .tx_ready(tx_ready)

  );



endmodule