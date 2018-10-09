`timescale 1ns / 1ps


//-----------------------------------------------------------------------------
// controller_for_sram_is61lv25616al
// Marat Galimov
// 2014
//-----------------------------------------------------------------------------
//
// Altera DE1 SRAM 512 KB (ISSI IS61LV25616AL) Verilog controller.
//
//-----------------------------------------------------------------------------

module controller_for_sram_is61lv25616al
	(
	   input wire clock_50_mhz_input,
		input wire read_or_write_input,
		input wire start_input, 
		input wire [18:0] address_input,
		input wire [7:0] data_input,
		
		//----------------------------------------------
		
		inout wire [7:0] data_from_to_sram_input_output,
		
		//----------------------------------------------
	   
		output reg [18:0] address_to_sram_output,
		output reg ce_to_sram_output,
		output reg oe_to_sram_output,
		output reg we_to_sram_output,
		//output reg lb_to_sram_output,
		//output reg ub_to_sram_output,
		
		output wire [7:0] data_output,
		output reg data_ready_signal_output,
		output reg writing_finished_signal_output,
		output reg busy_signal_output
	);

reg [1:0] reading_phase;
reg [1:0] writing_phase;

reg [15:0] register_for_reading_data;
reg [15:0] register_for_writing_data;

reg register_for_splitting;

initial
	begin
	
		reading_phase[1:0] <= 2'b00; 
		writing_phase[1:0] <= 2'b00; 
			
		ce_to_sram_output<=1'b1;
		oe_to_sram_output<=1'b1;
		we_to_sram_output<=1'b1;
		//lb_to_sram_output<=1'b0;
		//ub_to_sram_output<=1'b0;
		
		data_ready_signal_output<=1'b0;
		writing_finished_signal_output<=1'b0;
		busy_signal_output<=1'b0;
	   
		reading_phase[1:0]<=2'b00;
		writing_phase[1:0]<=2'b00;
		
		register_for_reading_data[15:0]<=16'b00000000_00000000;
		register_for_writing_data[15:0]<=16'b00000000_00000000;
		
		register_for_splitting<=1'b0;
		
	end

always@(posedge clock_50_mhz_input)
	begin

//==========================================================================================
//	READING PHASES
//==========================================================================================	
		
		//============================== READING_PHASE = 00 ==============================
		
		if (start_input == 1'b1 && read_or_write_input == 1'b0 && busy_signal_output == 1'b0)
			begin
				busy_signal_output<=1'b1;
				address_to_sram_output[18:0]<=address_input[18:0];
				reading_phase<=reading_phase + 1'b1;
			end
			
		//============================== READING_PHASE = 01 ==============================
		
		else if (busy_signal_output == 1'b1 && reading_phase == 2'b01)
			begin
				ce_to_sram_output<=1'b0;
				oe_to_sram_output<=1'b0;
				we_to_sram_output<=1'b1;
				
				reading_phase<=reading_phase + 1'b1;
			end
			
		//============================== READING_PHASE = 10 ==============================
		
		else if (busy_signal_output == 1'b1 && reading_phase == 2'b10)
			begin
				register_for_reading_data[7:0]<=data_from_to_sram_input_output[7:0];
				data_ready_signal_output<=1'b1;
				reading_phase<=reading_phase + 1'b1;	
			end
			
		//============================== READING_PHASE = 11 ==============================
		
		else if (busy_signal_output == 1'b1 && reading_phase == 2'b11)
			begin
				ce_to_sram_output<=1'b1;
				oe_to_sram_output<=1'b1;
				we_to_sram_output<=1'b1;
				
				data_ready_signal_output<=1'b0;
				busy_signal_output<=1'b0;
				reading_phase<= 2'b00;	
			end
			
//==========================================================================================
//	WRITING PHASES
//==========================================================================================		
		
		//============================== WRITING_PHASE = 00 ==============================	
		
		if (start_input == 1'b1 && read_or_write_input == 1'b1 && busy_signal_output == 1'b0)
			begin
				busy_signal_output<=1'b1;
				address_to_sram_output[18:0]<=address_input[18:0];
				register_for_writing_data[7:0]<=data_input[7:0];
				writing_phase<=writing_phase + 1'b1;			
			end
	
		//============================== WRITING_PHASE = 01 ==============================
		
		else if (busy_signal_output == 1'b1 && writing_phase == 2'b01)
			begin
				ce_to_sram_output<=1'b0;
				oe_to_sram_output<=1'b1;
				we_to_sram_output<=1'b0;
				
				register_for_splitting<=1'b1;
				
				writing_phase<=writing_phase + 1'b1;
			end
			
		//============================== WRITING_PHASE = 10	==============================
		
		else if (busy_signal_output == 1'b1 && writing_phase == 2'b10)
			begin
				writing_finished_signal_output<=1'b1;
				
				register_for_splitting<=1'b0;
				
				writing_phase<=writing_phase + 1'b1;
			end
			
		//============================== WRITING_PHASE = 11 ==============================
		
		else if (busy_signal_output == 1'b1 && writing_phase == 2'b11)
			begin
				ce_to_sram_output<=1'b1;
				oe_to_sram_output<=1'b1;
				we_to_sram_output<=1'b1;
				
				writing_finished_signal_output<=1'b0;
				busy_signal_output<=1'b0;
				writing_phase<= 2'b00;				
			end	
	end
	
assign data_output = register_for_reading_data;

assign data_from_to_sram_input_output = (register_for_splitting) ? register_for_writing_data : 8'bz;

endmodule
