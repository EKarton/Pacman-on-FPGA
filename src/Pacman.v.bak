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
			.resetn(~reset),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y[6:0]),
			.plot(plot),
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

	assign LEDR[0] = plot;


	wire slow_clock;
	/*
		input [27:0] interval,
	input reset,
	input en,
	input clock_50,
	output reg reduced_clock);

	*/
	RateDivider divider(
		.interval(27'd5000000),
		.reset(reset),
		.en(1'b1),
		.clock_50(CLOCK_50),
		.reduced_clock(slow_clock)
		);

	assign LEDR[1] = slow_clock;

	HexDisplay hex0(
		.hex_digit({1'b0, colour}),
		.segments(HEX0)
		);
	HexDisplay hex1(
		.hex_digit(x[3:0]),
		.segments(HEX1)
		);
	HexDisplay hex2(
		.hex_digit(y[3:0]),
		.segments(HEX2)
		);

	MainModule main_module(
		.move_up(SW[0]),
		.move_left(SW[1]),
		.pacman_controls(KEY[3:0]),
		.clock_50(CLOCK_50),
		.reset(reset),
		.vga_colour(colour),
		.vga_x(x),
		.vga_y(y),
		.vga_plot(plot),
		.debug_leds(LEDR[9:2]));

endmodule

module MainModule(
	input move_up,
	input move_left,
	input[3:0] pacman_controls,
	input clock_50,
	input reset,
	output [2:0] vga_colour,
	output [7:0] vga_x,
	output [7:0] vga_y,
	output vga_plot,
	output [7:0] debug_leds);

	wire [7:0] char_x_in, char_y_in, char_x_out, char_y_out;
	wire [2:0] character_type;

	wire [4:0] map_x;
	wire [4:0] map_y;
	wire [2:0] sprite_data_in;
	wire [2:0] sprite_data_out;

	wire map_readwrite = 1'b0;//0 for read, 1 for write
	wire char_readwrite = 1'b0;//0 for read, 1 for write

	wire able_to_damage;

	wire pac_man_x;
	wire pac_man_y;




	module PacmanController(
		.enable(),
		.move_left(),
		.move_up(),
		.reset(),
		.clock(),
		.able_to_move(),

		.pacman_x_init(),
		.pacman_y_init(),

		.curr_sprite_data(),

		.able_to_damage(),

		//current location
		.pacman_x_coordinate_in(),
		.pacman_y_coordinate_in(),

		//location it is trying to move to
		.target_x_coordinate_out(),
		.target_y_coordinate_out());


	// The map, containing map data
	MapController map(
		.map_x(map_x),
		.map_y(map_y),
		.sprite_data_in(sprite_data_in),
		.sprite_data_out(sprite_data_out),
		.readwrite(map_readwrite),
		.clock_50(clock_50)
		);

	CharacterRegisters character_registers(
		.x_in(char_x_in),
		.y_in(char_y_in),
		.pacman_x_coordinate(pac_man_x),
		.pacman_y_coordinate(pac_man_y),
		.x_out(char_x_out),
		.y_out(char_y_out),
		.character_type(character_type),
		.readwrite(char_readwrite),
		.clock_50(clock_50),
		.reset(reset)
		);

	DisplayController display_controller(
		.en(1'b1),
		.map_x(map_x),
		.map_y(map_y),
		.sprite_type(sprite_data_out),
		.pacman_orientation(pacman_controls[0]),
		.character_type(character_type),
		.char_x(char_x_out),
		.char_y(char_y_out),
		.vga_plot(vga_plot),
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_color(vga_colour),
		.reset(reset),
		.clock_50(clock_50),
		.debug_leds(debug_leds)
		);

endmodule
