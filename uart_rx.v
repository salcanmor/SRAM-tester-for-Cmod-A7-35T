`timescale 1ns / 1ps

module uart_rx
  #(
    parameter DBIT = 8,				// Number of data bits to receive
    SB_TICK = 16			// Number of ticks for the stop bit. 16 ticks=1 stop bit, 24=1.5 and 32=2.
  )
  ( 
    input wire clk,
    input wire reset,
    input wire data_in,
    input wire s_tick,
    output reg rx_done_tick,
    output wire [7:0] data_out
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

  //	body
  //	FSMD state & data registers
  always@(posedge clk, posedge reset)
    if (reset)
      begin
        state_reg <= idle;
        cnt_15_reg <= 0;
        cnt_8_reg <= 0;
        shift_out_reg <= 0;
      end
  else
    begin
      state_reg <= state_next;
      cnt_15_reg <= cnt_15_next;
      cnt_8_reg <= cnt_8_next;
      shift_out_reg <= shift_out_next;
    end

  //	FSMD next-state logic
  always@*
    begin
      state_next = state_reg ;
      cnt_15_next = cnt_15_reg;
      cnt_8_next = cnt_8_reg;
      shift_out_next = shift_out_reg;
      rx_done_tick = 1'b0;

      case (state_reg)
		
        idle:
          if(~data_in)
            begin
              state_next = start;
              cnt_15_next = 0;
            end
				
        start:
          if (s_tick)
            if(cnt_15_reg==7)
              begin
                state_next=data;
                cnt_15_next=0;
                cnt_8_next=0;
              end
        else
          cnt_15_next = cnt_15_reg+1'b1;
			 
        data:
          if(s_tick)
            if(cnt_15_reg==15)
              begin
                cnt_15_next=0;
                shift_out_next = {data_in, shift_out_reg[7:1]};
					 //shift_out_next<={shift_out_reg[6:0],data_in}; // shift the bits in reverse order
                if(cnt_8_reg==(DBIT-1))
                  state_next=stop;
                else
                  cnt_8_next=cnt_8_reg+1'b1;
              end
        else
          cnt_15_next=cnt_15_reg+1'b1;
			 
        stop:
          if(s_tick)
            if(cnt_15_reg==(SB_TICK-1))
              begin
                state_next=idle;
                rx_done_tick=1'b1;
              end
        else
          cnt_15_next = cnt_15_reg+1'b1;
      endcase
    end

    //output
    assign data_out = shift_out_reg;

endmodule