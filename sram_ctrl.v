`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 18.09.2018 00:28:22
// Design Name:
// Module Name: sradata_regm_ctrl
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


module sram_ctrl(clk, reset, mem, rw, addr, data_f2s, ready, data_s2f_r, data_s2f_ur, ad, we_n, oe_n, dio_a, ce_a_n);

  input wire clk;                         //  Clock signal
  input wire reset;                       //  Reset signal

  input wire mem;                         //  We assert this signal in order to start working with the SRAM
  input wire rw;                          //  With this signal, we select reading or writing operation
  input wire [18:0] addr;                 //  Address bus
  input wire [7:0] data_f2s;             //  Data to be writteb in the SRAM
  output reg ready;                       //  Is a status signal indicating whether the controller is ready to accept a new command. This signal is needed since a memory operation may take more than one clock cycle.
  output wire [7:0] data_s2f_r;           //  It is the 16-bit registered data retrieved from the SRAM (the -s2f suffix stands for SRAM to FPGA)
  output wire [7:0] data_s2f_ur;          //  It is the 16-bit unregistered data retrieved from SRAM

  output wire [18:0] ad;                   //  Address bus
  output wire we_n;                        //  Write enable (active-low)
  output wire oe_n;                        //  Output enable (active-low)

  inout wire [7:0] dio_a;                //  Data bus
  output wire ce_a_n;                     //  Chip enable (active-low). Disables or enables the chip.
 // output wire ub_a_n;                     //  Upper byte enable (active-low). Disables or enables the upper byte of the data bus
 // output wire lb_a_n;                     //  Lower byte enable (active-low). Disables or enables the lower byte of the data bus

  //FSM states declaration
  localparam [2:0]
  idle    =   3'b000,
  rd1     =   3'b001,
  rd2     =   3'b010,
  wr1     =   3'b011,
  wr2     =   3'b100;


  // signal declaration
  reg [2:0] state_reg, state_next;                 //  State indicator signal
  reg [7:0] data_f2s_reg, data_f2s_next;
  reg [7:0] data_s2f_reg, data_s2f_next;
  reg [18:0] addr_reg, addr_next;
  reg we_buf, oe_buf, tri_buf;
  reg we_reg, oe_reg, tri_reg;



  //body
  //FSMD state logic
  always@(posedge clk, posedge reset)
    if(reset)
      begin
        state_reg <= idle;
        addr_reg <= 0;
        data_f2s_reg <= 0;
        data_s2f_reg <= 0;
        tri_reg <= 1'b1;
        we_reg <= 1'b1;
        oe_reg <= 1'b1;
      end
  else
    begin
      state_reg <= state_next;
      addr_reg <= addr_next;
      data_f2s_reg <= data_f2s_next;
      data_s2f_reg <= data_s2f_next;
      tri_reg <= tri_buf;
      we_reg <= we_buf;
      oe_reg <= oe_buf;
    end

  //FSMD next state logic
  always@(*)
    begin
      addr_next = addr_reg;
      data_f2s_next = data_f2s_reg;
      data_s2f_next = data_s2f_reg;

      ready           =   1'b0;

      case(state_reg)

        idle:                                     //  idle begins
          begin                                   //  We are in the initial state: idle                         
            if(~mem)                              //  ?Any memory operation to do?
              state_next = idle;                  //  No
            else                                  //  Yes, which one?
              begin

                addr_next = addr;                 //  We place the address in the address register
                if(~rw)begin                      //  rw==0? Yes, then we'll do a write operation
                  state_next = wr1;               //  Let's move to the wr1 state!
                  data_f2s_next = data_f2s;       //  We place the data to be written in the data register
                end 
                else                              //  rw==1? Yes, then we'll do a read operation
                  state_next = rd1;               //  Let's move to the rd1 state!
              end
            ready = 1'b1;
          end                                     // idle ends

        wr1:
          state_next = wr2;                       //  Let's move to the wr2 state!
        wr2:    
          state_next = idle;                      //  Let's move to the idle state!
        rd1:
          state_next = rd2;                       //  Let's move to the rd2 state!
        rd2:
          begin
            data_s2f_next   = dio_a;              //  Store data from SRAM into a register
            state_next = idle;                    //  Let's move to the idle state!
          end
        default:
          state_next = idle;                      //  If no match with previous cases, we move to the idle state!
      endcase
    end

  //Look-ahead output logic
  always@(*) begin
    tri_buf = 1'b1;                               //  Signals are active low
    we_buf = 1'b1;
    oe_buf = 1'b1;

    case(state_next)
      idle:
        oe_buf = 1'b1;                  //  We deactive the output
      wr1:
        begin
          tri_buf = 1'b0;               //  We deactive the buffer tri-state
          we_buf = 1'b0;                //  We deactive the write enable
        end
      wr2:
        tri_buf = 1'b0;                 //  We active the buffer tri-state
      rd1:
        oe_buf = 1'b0;                  //  We active the output
      rd2:
        oe_buf = 1'b0;                  //  We active the output
    endcase
  end


  // to main system
  assign data_s2f_r = data_s2f_reg;
  assign data_s2f_ur = dio_a;
  // to sram
  assign we_n = we_reg;
  assign oe_n = oe_reg;
  assign ad = addr_reg;
  // i/o for sram chip a
  assign ce_a_n = 1'b0;
//  assign ub_a_n = 1'b0;
//  assign lb_a_n = 1'b0;
  assign dio_a = (~tri_reg) ? data_f2s_reg : 8'bz;


endmodule
