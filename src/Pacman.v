module Pacman(
		SW, 
		KEY, 
		LEDR, 
		HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, 
		CLOCK_50, 
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B);   						//	VGA Blue[9:0]);
		
	input [3:0] KEY; 
	input [9:0] SW;
	output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0; 
	output [9:0] LEDR;
	input CLOCK_50;
	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire reset;
	assign reset = SW[9];
	
	wire en;
	assign en = SW[8];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [7:0] y;
	wire plot;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y[6:0]),
			.plot(1'b1),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
	
	MainModule main_module(KEY[3:0], CLOCK_50, reset, colour, x, y, plot);
	
endmodule

module MainModule(
	input[3:0] pacman_controls, 
	input clock_50, 
	input reset,
	output [2:0] colour, 
	output [7:0] vga_x, 
	output [7:0] vga_y, 
	output vga_plot);	
			
	// The clock, which should run at 60 fps.
	wire frame_clock;
	RateDivider frame_clock_counter(27'd83333, reset, 1'b1, CLOCK_50, frame_clock);
	
	// The map data
	wire [4:0] map_x;
	wire [4:0] map_y;
	wire [2:0] sprite_data_in;
	wire [2:0] sprite_data_out;
	wire map_readwrite;
	assign map_readwrite = 1'b0;
	
	// The map, containing map data
	MapController map(map_x, map_y, sprite_data_in, sprite_data_out, map_readwrite, clock_50);
	
	
	// The display controller, which runs at 60 fps
	MapDisplayController controller(frame_clock, grid_x, grid_y, grid_data_out, reset, vga_plot, vga_x, vga_y, reset, clock_50);
	
endmodule