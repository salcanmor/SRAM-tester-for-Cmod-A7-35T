`timescale 1ns / 1ps



module top
  ( 
    input wire clk,
    input wire reset,
    input wire data_in,
    output wire data_out,

    // to/from SRAM
    output wire [18:0] ad,   
    inout wire [7:0] dio_a, 
    output wire we_n,
    output wire oe_n,
    output wire ce_a_n
  );

  wire [7:0] r_data_bus;
  wire [7:0] w_data_bus;
  wire [7:0] data_f2s_bus;
  wire [7:0] data_s2f_r_bus;
  wire [18:0] addr_bus;

  wire button_wire;

  debouncer debouncer_unit (
    .clk(clk),     
    .PB(reset), 
    .PB_state(), 
    .PB_down(), 
    .PB_up(button_wire)
  );


  uart uart_unit (
    .clk(clk), 
    .reset(button_wire), 
    .data_in(data_in), 
    .tx_start(tx_start), 
    .w_data(w_data_bus), 
    .data_out(data_out), 
    .rx_done_tick(rx_done_tick), 
    .tx_done_tick(tx_done_tick), 
    .r_data(r_data_bus),
    .tx_ready(tx_ready)

  );



  // Instantiate the module
  checker checker_unit (
    .clk(clk), 
    .reset(button_wire), 
    .rx_done_tick(rx_done_tick), 
    .tx_ready(tx_ready), 
    .r_data(r_data_bus), 
    .w_data(w_data_bus), 
    .tx_start(tx_start), 
    .mem(mem), 
    .rw(rw), 
    .addr(addr_bus), 
    .data_s2f_r(data_s2f_r_bus), 
    .data_f2s(data_f2s_bus)
  );


sram_ctrl2 instance_name (
    .clk(clk), 
    .reset(reset), 
  //  .mem(mem), 
    .rw(rw), 
    .addr(addr_bus), 
    .data_f2s(data_f2s_bus), 
   // .ready(ready), 
    .data_s2f_r(data_s2f_r_bus), 
   // .data_s2f_ur(data_s2f_ur), 
    .ad(ad), 
    .we_n(we_n), 
    .oe_n(oe_n), 
    .dio_a(dio_a), 
    .ce_a_n(ce_a_n)
    );



    //	 
    //	 // Instantiate the module
    //    controller_for_sram_is61lv25616al sram_controller (
    //        .clock_50_mhz_input(clk), 
    //        .read_or_write_input(rw), 
    //        .start_input(mem), 
    //        .address_input(addr_bus), 
    //        .data_input(data_f2s_bus), 
    //        .data_from_to_sram_input_output(dio_a), 
    //        .address_to_sram_output(ad), 
    //        .ce_to_sram_output(ce_a_n), 
    //        .oe_to_sram_output(oe_n), 
    //        .we_to_sram_output(we_n), 
    //        .data_output(data_s2f_r_bus), 
    //        .data_ready_signal_output(data_ready_signal_output), 
    //        .writing_finished_signal_output(writing_finished_signal_output), 
    //        .busy_signal_output(busy_signal_output)
    //        );


//
//    // Instantiate the module
//    sram_ctrl sram_ctrl_unit (
//      .clk(clk), 
//      .reset(reset), 
//      .mem(mem), 
//      .rw(rw), 
//      .addr(addr_bus), 
//      .data_f2s(data_f2s_bus), 
//      .ready(ready), 
//      .data_s2f_r(data_s2f_r_bus), 
//      .data_s2f_ur(data_s2f_ur), 
//      .ad(ad), 
//      .we_n(we_n), 
//      .oe_n(oe_n), 
//      .dio_a(dio_a), 
//      .ce_a_n(ce_a_n)
//    );

    endmodule
