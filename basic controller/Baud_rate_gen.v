`timescale 1ns / 1ps

module Baud_rate_gen
  #(
   // M=5	//	mod-M. M=clock freq/(16 * baud rate)   <---  10 Mhz (use this in test bench)
  //  M=208	//	mod-M. M=clock freq/(16 * baud rate)   <---  32 Mhz
    M=78	//	mod-M. M=clock freq/(16 * baud rate)   <---  12 Mhz
  )
  (
    input wire clk,
    input wire reset,
    output wire tick
  );

  //signal declaration
  localparam N=log2(M);	//	numbers of bits needed in the counter
  reg [N-1:0] r_reg;
  wire [N-1:0] r_next;

  //body
  //register
  always@(posedge clk, posedge reset)
    if(reset)
      r_reg <= 0;
    else
      r_reg<=r_next;

  //next-state logic
  assign r_next = (r_reg==(M-1)) ? 1'b0 : r_reg+1'b1;
  //ouput logic
  assign tick=(r_reg==(M-1))?1'b1:1'b0;

  //function to calculate the bits for the counter according to the size of M
  function integer log2(input integer n);
    integer i;
    begin
      log2=1;
      for (i=0; 2**i < n; i=i+1)
        log2=i+1;
    end
  endfunction

endmodule