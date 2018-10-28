`timescale 1ns / 1ps

module checker
  ( 
    input wire clk,
    input wire reset,
    input wire rx_done_tick,
    input wire tx_ready,
    input wire [7:0] r_data,
    output reg [7:0] w_data,
    output reg tx_start,

    /*   Signal to/from the SRAM chip   */
    output reg mem,
    output reg rw,
    output wire [18:0] addr,                   //  Address bus
    input wire [7:0] data_s2f_r,           //  It is the 16-bit registered data retrieved from the SRAM (the -s2f suffix stands for SRAM to FPGA)
    output wire [7:0] data_f2s             //  Data to be writteb in the SRAM


  );

  // state declaration for the FSM
  localparam [3:0]
  bienvenida                =   4'd0,         //  Here I show the main menu.
  idle_and_receive          =   4'd1,         //  Wait till the user select any option (1, 2 or 3). The option is store in a register.
  seleccion                 =   4'd2,         //  We check which option was selected.
  escritura                 =   4'd3,         //  We have selected write operation, so that we show a message to enter the input data value.
  escritura2                =   4'd4,         //  The entered data is stored in both formats ASCII and binary.
  escritura3                =   4'd5,         //  We show a message to enter the address value.
  escritura4                =   4'd6,         //  The entered data is stored in both formats ASCII and binary.
  pintar_datos_escritura    =   4'd7,         //  We print the 2 previous entered data
  lectura                   =   4'd8,         //  We have selected read operation, so that we show a message to enter the address value.
  lectura2                  =   4'd9,         //  The entered data is stored in both formats ASCII and binary.
  pintar_datos_lectura      =   4'd10,        //  We print the previous entered data
  pintar_datos_lectura2     =   4'd11,        //  We print the previous entered data
  bin2ascii                 =   4'd12;        //  TO BE FINISHED




  //	signal declaration
  reg [3:0] state_reg;

  ////
  reg[7:0]count_read;
  reg[7:0]count_write;
  reg[2:0] count_tx_ready;
  ////

  reg [15:0] PB_cnt;
  reg[8:0]count;
  reg [63:0]rx_buffer;
  reg [152:0]rx_buffer2;
  reg [152:0]rx_buffer3;
  reg [7:0]dato_binario;
  reg [18:0]dato_binario2;
  reg [18:0]dato_binario3;
  reg [7:0] dato_desde_sram;
  wire [63:0] buffer_data_s2f_r;

  always@(posedge clk, posedge reset)

    if(reset)begin
      state_reg<=bienvenida;
      tx_start<=0;
      ///
      count_read <= 0;
      count_write <= 0;
      count_tx_ready <= 0;
      ///

      count<=0;   // reset the counter
      rx_buffer<=0;
      rx_buffer2<=0;
      dato_binario<=0;
      dato_binario2<=0;

      mem <= 1'b0;
      rw <= 1'b1;


    end
  else 

    case (state_reg)


      bienvenida:begin
        mem <= 1'b0;

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
              73: w_data<="-";
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


      idle_and_receive: 
        begin 
          tx_start<=0;
          if(rx_done_tick)begin
            tx_start<=0;
            rx_buffer<=r_data;
            state_reg<=seleccion;
          end 
        end


      seleccion:
        begin

          tx_start<=1;
          if(rx_buffer == 8'b00110001)  // input: 1. escritura
            // state_reg<=escritura;
            begin  //w_data<="W";     
              state_reg<=escritura; end    


          else    if(rx_buffer == 8'b00110010)  // input: 2. lectura
            //state_reg<=lectura;
            begin     state_reg<=lectura;
            end    


          else    if(rx_buffer == 8'b00110011)  // input: 3. testeo
            //          state_reg<=testeo;
            begin    w_data<="Z";  state_reg<=idle_and_receive; end    

            else state_reg<=idle_and_receive; 
            
          //state_reg<=idle_and_receive;
          //      begin      w_data<="X"; state_reg<=idle_and_receive; end    

        end

      escritura:
        begin

          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 33) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                32: w_data<=":";
                31: w_data<="n";
                30: w_data<="e";
                29: w_data<="t";
                28: w_data<="t";
                27: w_data<="i";
                26: w_data<="r";
                25: w_data<="w";
                24: w_data<=" ";
                23: w_data<="e";
                22: w_data<="b";//8'b00001101
                21: w_data<=" ";
                20: w_data<="o";
                19: w_data<="t";
                18: w_data<=" ";
                17: w_data<="a";
                16: w_data<="t";
                15: w_data<="a";
                14: w_data<="d";
                13: w_data<=" ";
                12: w_data<="r";
                11: w_data<="e";
                10: w_data<="t";
                9: w_data<="n";
                8: w_data<="E";
                7: w_data<="-";
                6: w_data<=8'b00001101;
                5: w_data<="E";
                4: w_data<="T";
                3: w_data<="I";
                2: w_data<="R";
                1: w_data<="W";
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              state_reg<=escritura2;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;
            end	
        end


      escritura2:begin
      mem = 1'b1;
      rw = 1'b0;

        tx_start<=0;

        if(rx_done_tick && count==7)// if the byte number 20 is received 

          begin

            dato_binario <= {dato_binario[6:0], r_data[0]};

            count<=0;   // reset the counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=escritura3;  // go to state s1
       //     rx_buffer <= {rx_buffer[55:0],r_data}; // shift in last received byte
          end
        else if(rx_done_tick) // if a byte is received
          begin

            if (r_data[7:1] == 7'h18)begin  // si lo recibido es "0" o "1"...
              dato_binario <= {dato_binario[6:0], r_data[0]};


            count<=count+1; // increment byte indicating counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=escritura2;              
          //  rx_buffer <= {rx_buffer[55:0],r_data}; // shift in the received byte
            end
            else             state_reg<=escritura2;              

            
            
          end

      end


      escritura3:
        begin

          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 16) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                15: w_data<=":";
                14: w_data<="s";
                13: w_data<="s";
                12: w_data<="e";
                11: w_data<="r";
                10: w_data<="d";
                9: w_data<="d";
                8: w_data<="a";
                7: w_data<=" ";
                6: w_data<="r";
                5: w_data<="e";
                4: w_data<="t";
                3: w_data<="n";
                2: w_data<="E";
                1: w_data<="-";
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              state_reg<=escritura4;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;
            end    
        end


      escritura4:begin

        tx_start<=0;

        if(rx_done_tick && count==18)// if the byte number 19 is received 

          begin
            dato_binario2 <= {dato_binario2[17:0], r_data[0]};

            count<=0;   // reset the counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=pintar_datos_escritura;  // go to state s1
            rx_buffer2 <= {rx_buffer2[55:0],r_data}; // shift in last received byte
          end
        else if(rx_done_tick) // if a byte is received
          begin

            if (r_data[7:1] == 7'h18)begin  // si lo recibido es "0" o "1"... SINO NO ESCRIBIMOS NADA Y SEGUIMOS ESPERANDO UN 0 ó 1
              dato_binario2 <= {dato_binario2[17:0], r_data[0]};

            count<=count+1; // increment byte indicating counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=escritura4;              
            rx_buffer2 <= {rx_buffer2[55:0],r_data}; // shift in the received byte
            end
            
            else             state_reg<=escritura4;              

            
          end

      end


      pintar_datos_escritura:
        begin

          mem <= 1'b1;
          rw <= 1'b1;


          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 29) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                28: w_data<=8'b00001101;
                27: w_data<=8'b00001101;
                26: w_data<="!";
                25: w_data<="y";
                24: w_data<="l";
                23: w_data<="l";
                22: w_data<="u";
                21: w_data<="f";
                20: w_data<="s";
                19: w_data<="s";
                18: w_data<="e";
                17: w_data<="c";
                16: w_data<="c";
                15: w_data<="u";
                14: w_data<="s";
                13: w_data<=" ";
                12: w_data<="n";
                11: w_data<="e";
                10: w_data<="t";
                9: w_data<="t";
                8: w_data<="i";
                7: w_data<="r";
                6: w_data<="w";
                5: w_data<=" ";
                4: w_data<="a";
                3: w_data<="t";
                2: w_data<="a";
                1: w_data<="D";
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              state_reg<=bienvenida;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;
            end    
        end


      lectura:
        begin

          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 32) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                31: w_data<=":";
                30: w_data<="d";
                29: w_data<="a";
                28: w_data<="e";
                27: w_data<="r";
                26: w_data<=" ";
                25: w_data<="e";
                24: w_data<="b";//8'b00001101
                23: w_data<=" ";
                22: w_data<="o";
                21: w_data<="t";
                20: w_data<=" ";
                19: w_data<="s";
                18: w_data<="s";
                17: w_data<="e";
                16: w_data<="r";
                15: w_data<="d";
                14: w_data<="d";
                13: w_data<="a";
                12: w_data<=" ";
                11: w_data<="r";
                10: w_data<="e";
                9: w_data<="t";
                8: w_data<="n";
                7: w_data<="E";
                6: w_data<="-";
                5: w_data<=8'b00001101;
                4: w_data<="D";
                3: w_data<="A";
                2: w_data<="E";
                1: w_data<="R";
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              //  mem = 1'b1;
              //  rw = 1'b1;
              state_reg<=lectura2;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;


            end	
        end



      lectura2:begin

        tx_start<=0;

        if(rx_done_tick && count==18)// if the byte number 20 is received 

          begin

            dato_binario3 <= {dato_binario3[17:0], r_data[0]};

            count<=0;   // reset the counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=pintar_datos_lectura;  // go to state s1
            rx_buffer3 <= {rx_buffer3[55:0],r_data}; // shift in last received byte
          end
        else if(rx_done_tick) // if a byte is received
          begin

            if (r_data[7:1] == 7'h18)  // si lo recibido es "0" o "1"...
            begin
              dato_binario3 <= {dato_binario3[17:0], r_data[0]};


            count<=count+1; // increment byte indicating counter
            w_data<=r_data;
            tx_start<=1;

            state_reg<=lectura2;              
            rx_buffer3 <= {rx_buffer3[55:0],r_data}; // shift in the received byte
            
            end else             state_reg<=lectura2;              

            
            
          end

      end


/*      pintar_datos_lectura:
        begin

          //dato_binario3



          mem<=1;
          rw<=1;

          ///

          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 12) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                11: w_data<=8'b00001101;
                10: w_data<=dato_binario3[7:0];
                9: w_data<=8'b00001101;
                8: w_data<=rx_buffer3[7:0];
                7: w_data<=rx_buffer3[15:8];
                6: w_data<=rx_buffer3[23:16];
                5: w_data<=rx_buffer3[31:24];
                4: w_data<=rx_buffer3[39:32];
                3: w_data<=rx_buffer3[47:40];
                2: w_data<=rx_buffer3[55:48];
                1: w_data<=rx_buffer3[63:56];
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              state_reg<=pintar_datos_lectura2;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;
            end    
        end



/*
bin2ascii:begin


buffer_data_s2f_r[7:0] =   (data_s2f_r[0]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[15:8] =  (data_s2f_r[1]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[23:16] = (data_s2f_r[2]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[31:24] = (data_s2f_r[3]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[39:32] = (data_s2f_r[4]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[47:40] = (data_s2f_r[5]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[55:48] = (data_s2f_r[6]) ? 8'b00110001 : 8'b00110000 ;
buffer_data_s2f_r[63:56] = (data_s2f_r[7]) ? 8'b00110001 : 8'b00110000 ;

              state_reg<=pintar_datos_lectura2;


end

*/





      pintar_datos_lectura://begin
        //dato_desde_sram =  data_s2f_r;


          
//        tx_start<=1;
//        w_data<="X";	//PINTAMOS EL DATO RECOGIDO DE LA RAM (DATO REGISTRADO, ES DECIR QUE HA PASADO POR UN FF)
//      //  w_data<=data_s2f_r;	//PINTAMOS EL DATO RECOGIDO DE LA RAM (DATO REGISTRADO, ES DECIR QUE HA PASADO POR UN FF)
//        state_reg<=bienvenida;
                

        begin
  mem<=1;
        rw<=1;
          //dato_binario3
   

          if (tx_ready)
            count_tx_ready <= count_tx_ready + 1;
          else
            count_tx_ready <= 0;
          if (count_write < 27) //ultimo +1
            if(count_tx_ready == 7)begin
              count_write <= count_write + 1;
              tx_start<=1'b1;
              case(count_write)

                26: w_data<=8'b00001101;
                25: w_data<=8'b00001101;
                24: w_data<=buffer_data_s2f_r[7:0];
                23: w_data<=buffer_data_s2f_r[15:8];
                22: w_data<=buffer_data_s2f_r[23:16];
                21: w_data<=buffer_data_s2f_r[31:24];
                20: w_data<=buffer_data_s2f_r[39:32];
                19: w_data<=buffer_data_s2f_r[47:40];
                18: w_data<=buffer_data_s2f_r[55:48];
                17: w_data<=buffer_data_s2f_r[63:56];
                16: w_data<=" ";
                15: w_data<=":";
                14: w_data<="a";
                13: w_data<="t";
                12: w_data<="a";
                11: w_data<="d";
                10: w_data<=" ";
                9: w_data<="d";
                8: w_data<="e";
                7: w_data<="v";
                6: w_data<="e";
                5: w_data<="i";
                4: w_data<="r";
                3: w_data<="t";
                2: w_data<="e";
                1: w_data<="R";
                0: w_data<=8'b00001101;
                default: w_data<=8'b0;
              endcase
            end
          else
            begin
              tx_start<=1'b0;
            end
          else
            begin
              state_reg<=bienvenida;
              count_write <= 0;
              tx_start<=1'b0;
              count_tx_ready <= 0;
              count_read <= 0;
            end    
        end




    endcase

//	NOTA: PARA ESTA PRIMERA VERSIÓN, SOLO MANEJAREMOS LAS DIRECCIONES LAS 256 PRIMERAS DIRECCIONES
//	ES DECIR, LAS DIRECCIONES: 00000_00000_XXXX_XXXX
 // assign addr = (rw) ? {10'b00_0000_0000, dato_binario3} : {10'b00_0000_0000, dato_binario2} ; 
  assign addr = (rw) ? {10'b00_0000_0000, dato_binario3} : dato_binario2 ; 
  assign data_f2s = (~rw) ? dato_binario : 8'bz;
  
 assign  buffer_data_s2f_r[7:0] =   (data_s2f_r[0]) ? 8'b00110001 : 8'b00110000 ;
 assign  buffer_data_s2f_r[15:8] =  (data_s2f_r[1]) ? 8'b00110001 : 8'b00110000 ;
assign   buffer_data_s2f_r[23:16] = (data_s2f_r[2]) ? 8'b00110001 : 8'b00110000 ;
assign   buffer_data_s2f_r[31:24] = (data_s2f_r[3]) ? 8'b00110001 : 8'b00110000 ;
assign   buffer_data_s2f_r[39:32] = (data_s2f_r[4]) ? 8'b00110001 : 8'b00110000 ;
assign   buffer_data_s2f_r[47:40] = (data_s2f_r[5]) ? 8'b00110001 : 8'b00110000 ;
 assign  buffer_data_s2f_r[55:48] = (data_s2f_r[6]) ? 8'b00110001 : 8'b00110000 ;
 assign  buffer_data_s2f_r[63:56] = (data_s2f_r[7]) ? 8'b00110001 : 8'b00110000 ;


  endmodule
