`timescale 1ns / 1ps

module sram_ctrl3(clk, start_operation, rw, address_input, data_f2s, data_s2f, address_to_sram_output, we_to_sram_output, oe_to_sram_output, ce_to_sram_output, data_from_to_sram_input_output);

  input wire clk ;                                 //  Clock signal

  input wire start_operation;                      //  start operation signal

  input wire rw;                                   //  With this signal, we select reading or writing operation
  input wire [18:0] address_input;                 //  Address bus
  input wire [7:0] data_f2s;                       //  Data to be writteb in the SRAM

  output wire [7:0] data_s2f;                      //  It is the 8-bit registered data retrieved from the SRAM (the -s2f suffix stands for SRAM to FPGA)
  output reg [18:0] address_to_sram_output;        //  Address bus

  output reg we_to_sram_output;                    //  Write enable (active-low)
  output reg oe_to_sram_output;                    //  Output enable (active-low)
  output reg ce_to_sram_output;                    //  Chip enable (active-low). Disables or enables the chip.

  inout wire [7:0] data_from_to_sram_input_output; //  Data bus


  //FSM states declaration
  localparam [4:0]
  rd0     =   3'b000,
  rd1     =   3'b001,
  rd2     =   3'b010,
  rd3     =   3'b011,
  wr0     =   3'b100,
  wr1     =   3'b101,
  wr2     =   3'b110,
  wr3     =   3'b111,
  idle    =   4'b1000;

  //	signal declaration
  reg [3:0] state_reg;

  reg [7:0] register_for_reading_data;
  reg [7:0] register_for_writing_data;

  reg register_for_splitting;

initial
	begin
	
			
		ce_to_sram_output<=1'b1;
		oe_to_sram_output<=1'b1;
		we_to_sram_output<=1'b1;
		
	    state_reg <= idle;
		
		register_for_reading_data[7:0]<=8'b0000_0000;
		register_for_writing_data[7:0]<=8'b0000_0000;
		
		register_for_splitting<=1'b0;
		
	end


  always@(posedge clk)
    begin

      case(state_reg)
        idle: 
          begin   
            if(~start_operation)
              state_reg = idle;
            else begin
              if(rw)
                state_reg = rd0;
              else  
                state_reg = wr0;
            end
          end
        rd0:
          begin
            address_to_sram_output[18:0]<=address_input[18:0];

            state_reg = rd1;
          end   

        rd1:
          begin
            ce_to_sram_output<=1'b0;
            oe_to_sram_output<=1'b0;
            we_to_sram_output<=1'b1;

            state_reg = rd2;
          end

        rd2:
          begin
            register_for_reading_data[7:0]<=data_from_to_sram_input_output[7:0];

            state_reg = rd3;
          end

        rd3:
          begin
            ce_to_sram_output<=1'b1;
            oe_to_sram_output<=1'b1;
            we_to_sram_output<=1'b1;

            state_reg = idle;
          end

        wr0:
          begin
            address_to_sram_output[18:0]<=address_input[18:0];
            register_for_writing_data[7:0]<=data_f2s[7:0];

            state_reg = wr1;
          end

        wr1:
          begin
            ce_to_sram_output<=1'b0;
            oe_to_sram_output<=1'b1;
            we_to_sram_output<=1'b0;

            register_for_splitting<=1'b1;

            state_reg = wr2;

          end

        wr2:
          begin
            register_for_splitting<=1'b0;
            state_reg = wr3;
          end

        wr3:
          begin

            ce_to_sram_output<=1'b1;
            oe_to_sram_output<=1'b1;
            we_to_sram_output<=1'b1;

            state_reg = idle;

          end

      endcase

    end

  assign data_s2f = register_for_reading_data;

  assign data_from_to_sram_input_output = (register_for_splitting) ? register_for_writing_data : 8'bz;

endmodule   
