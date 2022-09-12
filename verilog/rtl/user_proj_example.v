`default_nettype none

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

  wire [`MPRJ_IO_PADS-1:0] io_in;
  wire [`MPRJ_IO_PADS-1:0] io_out;
  wire [`MPRJ_IO_PADS-1:0] io_oeb;


  wire load;
  wire reset;

  //inputs
   wire [3:0] M;
   wire [3:0] Q;
   wire [7:0] P;
   wire  space;
   wire [15:0] space_1;
   wire clk;
   
   assign space = 0; 
   assign io_oeb = 0;
   assign {space,clk,reset,load,Q,M,space_1} = io_in[`MPRJ_IO_PADS-9:0];
   assign io_out[35:28]	= P;
   
iiitb_r2_4bit_bm instan ( clk,load, reset, M, Q, P );

endmodule

module iiitb_r2_4bit_bm(

	// control signals
	input clk,
	input load,
	input reset,

	//inputs
	input [3:0] M,
	input [3:0] Q,
		
	//outputs
	output reg [7:0] P

    );

	 
	 reg [3:0] A 		=  4'b0;
	 reg Q_minus_one 	=  0;
	 reg [3:0] Q_temp 	=  4'b0;
	 reg [3:0] M_temp 	=  4'b0;
	 reg [2:0] Count 	=  3'd4;
	 
	 
	 
	 always @ (posedge clk)
	 begin
		if (reset == 1)
		begin
			A 		 =  4'b0;		//reset values
			Q_minus_one  	 =  0;
			P 		 =  8'b0;
			Q_temp 		 =  4'b0;
			M_temp 		 =  4'b0;
			Count 		 =  3'd4;

		end

		else if (load == 1)
		begin
			Q_temp 		=  Q;
			M_temp 		=  M;
		end

		else if((Q_temp[0] == Q_minus_one ) && (Count > 3'd0))
		begin
			Q_minus_one 	=  Q_temp[0];
			Q_temp 		=  {A[0],Q_temp[3:1]};				// right shift Q							
			A 		=  {A[3],A[3:1]};				// right shift A	
		    Count 		=  Count - 1'b1;					
		end
		else if((Q_temp[0] == 0 && Q_minus_one == 1)  && (Count > 3'd0))
		begin
			A 			=  A + M_temp;
			Q_minus_one 	=  Q_temp[0];
			Q_temp 		=  {A[0],Q_temp[3:1]};				// right shift Q
			A 		=  {A[3],A[3:1]};				// right shift A
			Count 		=  Count - 1'b1;
		end
		else if((Q_temp[0] == 1 && Q_minus_one == 0)  && (Count > 3'd0))
		begin
			A 			=  A - M_temp;
			Q_minus_one 	=  Q_temp[0];
			Q_temp 		=  {A[0],Q_temp[3:1]};				// right shift Q
			A 		=  {A[3],A[3:1]};				// right shift A
			 Count 		=  Count - 1'b1;
		end
		else 
		begin
			Count = 3'b0;
		end
		P = {A, Q_temp};
		
	 end

endmodule
