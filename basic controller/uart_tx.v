`timescale 1ns / 1ps


module uart_tx
  #(
    parameter DBIT = 8,				// Number of data bits to receive
    SB_TICK = 16			// Number of ticks for the stop bit. 16 ticks=1 stop bit, 24=1.5 and 32=2.
  )
  ( 
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    input wire s_tick,
    input wire tx_start,
    output reg tx_done_tick,
    output wire  data_out,
    output reg tx_ready

  );

  // state declaration for the FSMD
  localparam [1:0]
		idle  = 2'b00,
		start = 2'b01,
		data  = 2'b10,
		stop  = 2'b11;

  //	signal declaration
  reg [1:0] state_reg, state_next;
  reg [3:0] cnt_15_reg, cnt_15_next;
  reg [2:0] cnt_8_reg, cnt_8_next;
  reg [7:0] shift_out_reg, shift_out_next;
  reg tx_reg, tx_next;

  //	body
  //	FSMD state & data registers
  always@(posedge clk, posedge reset)
    if (reset)
      begin
        state_reg <= idle;
        cnt_15_reg <= 0;
        cnt_8_reg <= 0;
        shift_out_reg <= 0;
        tx_reg <= 0;
      end
  else
    begin
      state_reg <= state_next;
      cnt_15_reg <= cnt_15_next;
      cnt_8_reg <= cnt_8_next;
      shift_out_reg <= shift_out_next;
      tx_reg <= tx_next;
    end

  //	FSMD next-state logic
  always@*
    begin
      state_next = state_reg ;
      cnt_15_next = cnt_15_reg;
      cnt_8_next = cnt_8_reg;
      shift_out_next = shift_out_reg;
		tx_next = tx_reg;
		tx_done_tick = 1'b0;
		
      case (state_reg)
		
        idle:
			 begin
			 	tx_ready<=1'b1;
				 tx_next = 1'b1;
				 if(tx_start)
					begin
					  state_next = start;
					  cnt_15_next = 0;
					  shift_out_next = data_in;
					end
			 end
				
        start:
			 begin
			 	tx_ready<=1'b0;

				 tx_next = 1'b0;
				 if (s_tick)
					if(cnt_15_reg==15)
					  begin
						 state_next=data;
						 cnt_15_next=0;
						 cnt_8_next=0;
					  end
			  else
				 cnt_15_next = cnt_15_reg+1'b1;
			 end
			 
        data:
			 begin
				 tx_next = shift_out_reg[0];
				 if(s_tick)
					if(cnt_15_reg==15)
					  begin
						 cnt_15_next=0;
						 shift_out_next = shift_out_reg >> 1;
						 if(cnt_8_reg==(DBIT-1))
							state_next=stop;
						 else
							cnt_8_next=cnt_8_reg+1'b1;
					  end
			  else
				 cnt_15_next=cnt_15_reg+1'b1;
			 end
			 
        stop:
			 begin
				 tx_next = 1'b1;
				 if(s_tick)
					if(cnt_15_reg==(SB_TICK-1))
					  begin
						 state_next=idle;
						 tx_done_tick=1'b1;
					  end
			  else
				 cnt_15_next = cnt_15_reg+1'b1;
			 end
      endcase
    end

    //output
    assign data_out = tx_reg;

endmodule