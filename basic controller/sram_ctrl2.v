`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2018 01:07:38
// Design Name: 
// Module Name: sram_ctrl2
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


module sram_ctrl2(

  input wire clk,                        //  Clock signal
  input wire reset,                      //  Reset signal

  input wire rw,                         //  With this signal, we select reading or writing operation
  input wire [18:0] addr,                //  Address bus
  input wire [7:0] data_f2s,             //  Data to be writteb in the SRAM
  
  output reg [7:0] data_s2f_r,           //  It is the 8-bit registered data retrieved from the SRAM (the -s2f suffix stands for SRAM to FPGA)
  output wire [18:0] ad,                 //  Address bus
  output wire we_n,                      //  Write enable (active-low)
  output wire oe_n,                      //  Output enable (active-low)

  inout wire [7:0] dio_a,                //  Data bus
  output wire ce_a_n                     //  Chip enable (active-low). Disables or enables the chip.
  );

  assign ce_a_n = 1'b0;
  assign oe_n = 1'b0;
  assign we_n = rw;
  assign ad = addr;
  
  assign dio_a = (rw == 1'b1)? 8'hZZ : data_f2s;
  
  always @(posedge clk) begin
    if (rw == 1'b1)
      data_s2f_r <= dio_a;
  end
endmodule