// Part 2 skeleton

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
			// The ports below are for the VGA output.  Do not change.
			VGA_CLK,   						//	VGA Clock
			VGA_HS,							//	VGA H_SYNC
			VGA_VS,							//	VGA V_SYNC
			VGA_BLANK_N,						//	VGA BLANK
			VGA_SYNC_N,						//	VGA SYNC
			VGA_R,   						//	VGA Red[9:0]
			VGA_G,	 						//	VGA Green[9:0]
			VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

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

	wire resetn;
	assign resetn = KEY[0];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
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

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	assign colour[2:0] = SW[9:7];

	wire ld_x, ld_y;
	wire [1:0] add_x, add_y;

    // Instansiate datapath
		datapath d0(
			.clock(CLOCK_50),
			.resetn(resetn),
			.ld_x(ld_x),
			.ld_y(ld_y),
			.add_x(add_x[1:0]),
			.add_y(add_y[1:0]),
			.data_in(SW[6:0]),
			.x_out(x[7:0]),
			.y_out(y[6:0])
			);

    // Instansiate FSM control
    control c0(
			.clock(CLOCK_50),
			.resetn(resetn),
			.load(~KEY[3]),
			.draw(~KEY[1]),
			.ld_x(ld_x),
			.ld_y(ld_y),
			.add_x(add_x[1:0]),
			.add_y(add_y[1:0]),
			.plot(writeEn)
			);

endmodule

module datapath (clock, resetn, data_in, ld_x, ld_y, add_x, add_y, x_out, y_out);
	input clock;
	input resetn;
	input ld_x, ld_y;
	input [1:0] add_x, add_y;
	input [6:0] data_in;
	output [7:0] x_out;
	output [6:0] y_out;

	// registers used to store x and y
	reg [7:0] x;
	reg [6:0] y;

	assign x_out = x + add_x;
	assign y_out = y + add_y;

	always @ (posedge clock) begin
		if (!resetn) begin
			x <= 0;
			y <= 0;
		end
		else if (ld_x)
			x <= {1'b0, data_in[6:0]};
		else if (ld_y)
			y <= data_in[6:0];
	end

endmodule

module control(
	input clock,
	input resetn,
	input load,
	input draw,

	output reg ld_x, ld_y,
	output reg [1:0] add_x, add_y,
	output reg plot
	);

	reg [3:0] county;

	reg [3:0] current_state, next_state;

	localparam  S_LOAD_X        = 4'd0,
							S_LOAD_X_WAIT   = 4'd1,
							S_LOAD_Y        = 4'd2,
							S_LOAD_Y_WAIT   = 4'd3,
							S_DRAW     			= 4'd4,
							S_DRAW_WAIT		 	= 4'd5,
							S_COUNT					= 4'd6;

	// state table
	always @ (*)
	begin: state_table
		case (current_state)
			S_LOAD_X: next_state = load ? S_LOAD_X_WAIT : S_LOAD_X;
			S_LOAD_X_WAIT: next_state = load ? S_LOAD_X_WAIT : S_LOAD_Y;
			S_LOAD_Y: next_state = load ? S_LOAD_Y_WAIT : S_LOAD_Y;
			S_LOAD_Y_WAIT: next_state = load ? S_LOAD_Y_WAIT : S_DRAW;
			S_DRAW: next_state = draw ? S_DRAW_WAIT : S_DRAW;
			S_DRAW_WAIT: next_state = draw ? S_DRAW_WAIT : S_COUNT;
			S_COUNT: next_state = (county == 4'b1111) ? S_LOAD_X : S_COUNT;
			default: next_state = S_LOAD_X;
		endcase
	end // state table

	// output logic
	always @ (*)begin
		// by defaul all should be 0
		ld_x = 0;
		ld_y = 0;
		plot = 0;
		add_x = 0;
		add_y = 0;

		case (current_state)
			S_LOAD_X: ld_x = 1'b1;
			S_LOAD_Y: ld_y = 1'b1;
			S_COUNT: begin
								plot = 1'b1;
								add_x[1:0] = county[1:0];
								add_y[1:0] = county[3:2];
							end
		endcase
	end

	// 4-bit counter to count the pixels being drawn
	always@ (posedge clock) begin
		if (!resetn)
			county <= 4'b0000;
		else if (plot)
			county <= county + 1;
	end


	// current_state registers
	always@ (posedge clock) begin
		if (!resetn)
			current_state <= S_LOAD_X;
		else
			current_state <= next_state;
	end

endmodule
