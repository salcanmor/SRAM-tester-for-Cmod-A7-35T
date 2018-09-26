`timescale 1ns / 1ps

module checker
  ( 
    input wire clk,
    input wire reset,
    input wire rx_done_tick,
    input wire tx_ready,
    input wire [7:0] r_data,
    output reg [7:0] w_data,
    output reg tx_start
    

  );

  // state declaration for the FSM
  localparam [1:0]
  idle_and_receive    = 2'b00,
  send 					 = 2'b01,
  bienvenida        =2'b10;

  //	signal declaration
  reg [1:0] state_reg;
  reg [7:0] rx_buffer;
  
////
reg[7:0]count_read;
reg[7:0]count_write;
reg[2:0] count_tx_ready;
////
  always@(posedge clk, posedge reset)

    if(reset)begin
      state_reg<=bienvenida;
      tx_start<=0;
      
      ///
      count_read <= 0;
      count_write <= 0;
      count_tx_ready <= 0;
///
    end
  else 

    case (state_reg)
    
    

/////////////

		bienvenida:begin
				if (tx_ready)
					count_tx_ready <= count_tx_ready + 1;
				else
					count_tx_ready <= 0;
	if (count_write < 192) //ultimo +1
					if(count_tx_ready == 7)begin
						count_write <= count_write + 1;
						tx_start<=1'b1;
						case(count_write)
                        191: w_data<=8'b00001101;
                        190: w_data<=")";
                        189: w_data<="g";
                        188: w_data<="n";
                        187: w_data<="i";
                        186: w_data<="h";
                        185: w_data<="c";
                        184: w_data<="t";
                        183: w_data<="a";
                        182: w_data<="m";
                        181: w_data<=" ";
                        180: w_data<="h";
                        179: w_data<="t";
                        178: w_data<="i";
                        177: w_data<="w";
                        176: w_data<=" ";
                        175: w_data<="p";
                        174: w_data<="i";
                        173: w_data<="h";
                        172: w_data<="c";
                        171: w_data<=" ";
                        170: w_data<="l";
                        169: w_data<="l";
                        168: w_data<="u";
                        167: w_data<="f";
                        166: w_data<=" ";
                        165: w_data<="e";
                        164: w_data<="h";
                        163: w_data<="t";
                        162: w_data<=" ";
                        161: w_data<="d";
                        160: w_data<="a";
                        159: w_data<="e";
                        158: w_data<="r";
                        157: w_data<=" ";
                        156: w_data<="d";
                        155: w_data<="n";
                        154: w_data<="a";
                        153: w_data<=" ";
                        152: w_data<="e";
                        151: w_data<="t";
                        150: w_data<="i";
                        149: w_data<="r";
                        148: w_data<="w";
                        147: w_data<="(";
                        146: w_data<=" ";
                        145: w_data<="t";
                        144: w_data<="s";
                        143: w_data<="e";
                        142: w_data<="t";
                        141: w_data<=" ";
                        140: w_data<="c";
                        139: w_data<="i";
                        138: w_data<="t";
                        137: w_data<="a";
                        136: w_data<="m";
                        135: w_data<="o";
                        134: w_data<="t";
                        133: w_data<="u";
                        132: w_data<="A";
                        131: w_data<="-";
                        130: w_data<="3";
                        129: w_data<=8'b00001001;
                        128: w_data<=8'b00001101;
                        127: w_data<="d";
                        126: w_data<="a";
                        125: w_data<="e";
                        124: w_data<="R";
                        123: w_data<="-";
                        122: w_data<="2";
						121: w_data<=8'b00001001;
						120: w_data<=8'b00001101;
						119: w_data<="e";
						118: w_data<="t";
						117: w_data<="i";//8'b00001101
                        116: w_data<="r";
                        115: w_data<="W";
                        114: w_data<="-";
                        113: w_data<="1";
                        112: w_data<=8'b00001001;
                        111: w_data<=8'b00001101;
                        110: w_data<=":";
                        109: w_data<="s";
                        108: w_data<="n";
                        107: w_data<="o";
                        106: w_data<="i";
                        105: w_data<="t";
                        104: w_data<="p";
                        103: w_data<="O";
                        102: w_data<=8'b00001101;
                        101: w_data<=8'b00001101;
                        100: w_data<="-";
                        99: w_data<="-";
                        98: w_data<="-";
                        97: w_data<="-";
                        96: w_data<="-";
                        95: w_data<="-";
                        94: w_data<="-";
                        93: w_data<="-";
                        92: w_data<="-";
                        91: w_data<="-";
                        90: w_data<="-";
                        89: w_data<="-";
                        88: w_data<="-";
                        87: w_data<="-";
                        86: w_data<="-";
                        85: w_data<="-";
                        84: w_data<="-";
                        83: w_data<="-";
                        82: w_data<="-";
                        81: w_data<="-";
                        80: w_data<="-";
                        79: w_data<="-";
                        78: w_data<="-";
                        77: w_data<="-";
                        76: w_data<="-";
                        75: w_data<="-";
                        74: w_data<="-";
                        73: w_data<="-";						73: w_data<="-";//8'b00001101
                        72: w_data<="-";
                        71: w_data<="-";
                        70: w_data<="-";
                        69: w_data<="-";
                        68: w_data<="-";
                        67: w_data<="-";
                        66: w_data<="-";
                        65: w_data<="-";
                        64: w_data<="-";
                        63: w_data<="-";
                        62: w_data<="-";
                        61: w_data<="-";
                        60: w_data<="-";
                        59: w_data<="-";
                        58: w_data<="-";
                        57: w_data<="-";
                        56: w_data<="-";
                        55: w_data<="-";
                        54: w_data<="-";
                        53: w_data<="-";
                        52: w_data<="-";
                        51: w_data<="-";
						50: w_data<=8'b00001101;
						49: w_data<=")";
						48: w_data<="o";
						47: w_data<="n";
						46: w_data<="e";
                        45: w_data<="r";
                        44: w_data<="o";
                        43: w_data<="M";
                        42: w_data<=" ";
                        41: w_data<="s";
                        40: w_data<="a";
                        39: w_data<="n";
                        38: w_data<="a";
                        37: w_data<="C";
                        36: w_data<=" ";
                        35: w_data<="r";
                        34: w_data<="o";
                        33: w_data<="d";
                        32: w_data<="a";
                        31: w_data<="v";
                        30: w_data<="l";
                        29: w_data<="a";
                        28: w_data<="S";
                        27: w_data<=" ";
                        26: w_data<="y";
                        25: w_data<="b";
                        24: w_data<="(";
						23: w_data<=" ";
						22: w_data<="7";//8'b00001101
						21: w_data<="A";
						20: w_data<=" ";
						19: w_data<="d";
						18: w_data<="o";
						17: w_data<="m";
						16: w_data<="C";
						15: w_data<=" ";
						14: w_data<="R";
						13: w_data<="O";
						12: w_data<="F";
						11: w_data<=" ";
						10: w_data<="R";
						9: w_data<="E";
						8: w_data<="T";
						7: w_data<="S";
						6: w_data<="E";
						5: w_data<="T";
						4: w_data<=" ";
						3: w_data<="M";
						2: w_data<="A";
						1: w_data<="R";
						0: w_data<="S";
						default: w_data<=8'b0;
						endcase
					end
					else
						begin
							tx_start<=1'b0;
						end
				else
					begin
						state_reg<=idle_and_receive;
						count_write <= 0;
						tx_start<=1'b0;
						count_tx_ready <= 0;
						count_read <= 0;
					end	
			end


/////////////

      idle_and_receive: 
        begin 
          tx_start<=0;
          if(rx_done_tick)begin
            tx_start<=0;
            rx_buffer<=r_data;
            state_reg<=send;
          end 
        end

      send:
        begin
          tx_start<=1;
          w_data<=rx_buffer+1'b1;
          state_reg<=idle_and_receive;
        end

    endcase

endmodule