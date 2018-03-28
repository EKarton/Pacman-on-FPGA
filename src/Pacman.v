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

	wire slow_clock;
	/*
		input [27:0] interval,
	input reset,
	input en,
	input clock_50,
	output reg reduced_clock);

	*/
	RateDivider divider(
		.interval(27'd5000),
		.reset(reset),
		.en(1'b1),
		.clock_50(CLOCK_50),
		.reduced_clock(slow_clock)
		);

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
		.clock_50(slow_clock),
		.slow_clock(slow_clock),
		.reset(reset),
		.vga_colour(colour),
		.vga_x(x),
		.vga_y(y),
		.vga_plot(plot),
		.debug_leds(LEDR));

endmodule

module MainModule(
	input move_up,
	input move_left,
	input clock_50,
	input slow_clock,
	input reset,
	output [2:0] vga_colour,
	output [7:0] vga_x,
	output [7:0] vga_y,
	output vga_plot,
	output [9:0] debug_leds);

		// The states in FSM
	localparam 	PACMAN_GET_TARGET		= 6'd0,
				PACMAN_GET_MAP_SPRITE 	= 6'd1,
				PACMAN_WAIT				= 6'd2,
				PACMAN_SET_POS			= 6'd3,

				GHOST1_GET_TARGET		= 6'd4,
				GHOST1_GET_MAP_SPRITE	= 6'd5,
				GHOST1_WAIT				= 6'd6,
				GHOST1_SET_POS			= 6'd7,

				GHOST2_GET_TARGET		= 6'd8,
				GHOST2_GET_MAP_SPRITE	= 6'd9,
				GHOST2_WAIT				= 6'd10,
				GHOST2_SET_POS			= 6'd11,

				GHOST3_GET_TARGET		= 6'd12,
				GHOST3_GET_MAP_SPRITE	= 6'd13,
				GHOST3_WAIT				= 6'd14,
				GHOST3_SET_POS			= 6'd15,

				GHOST4_GET_TARGET		= 6'd16,
				GHOST4_GET_MAP_SPRITE	= 6'd17,
				GHOST4_WAIT				= 6'd18,
				GHOST4_SET_POS			= 6'd19,

				START_DISPLAY			= 6'd20,
				VIEW_DISPLAY			= 6'd21,
				STOP_DISPLAY			= 6'd22;
	
	// The coordinates of each character (it is 9 bit so that it can do signed operations)
	reg [8:0] pacman_vga_x, ghost1_vga_x, ghost2_vga_x, ghost3_vga_x, ghost4_vga_x; 
	reg [8:0] pacman_vga_y, ghost1_vga_y, ghost2_vga_y, ghost3_vga_y, ghost4_vga_y; 

	// The directions of each character
	reg [1:0] pacman_dx, ghost1_dx, ghost2_dx, ghost3_dx, ghost4_dx; 
	reg [1:0] pacman_dy, ghost1_dy, ghost2_dy, ghost3_dy, ghost4_dy; 

	// The target x and y coordinates for a character (it is 9 bit so that it can do signed operations)
	reg [8:0] target_x;
	reg [8:0] target_y;
	
	reg [4:0] char_map_x;
	reg [4:0] char_map_y;
	
	reg is_hit_pacman;
	
	// The pins that go to the map
	reg [4:0] map_x;
	reg [4:0] map_y;
	reg [2:0] sprite_data_in;
	wire [2:0] sprite_data_out;
	reg map_readwrite; //0 for read, 1 for write

	// To start/stop the display controller
	reg reset_display;
	reg start_display = 1'b0;
	reg finished_display = 1'b0;
	reg [27:0] counter = 28'd0;
	wire is_display_running;
	wire [4:0] display_map_x, display_map_y;

	// The current state in FSM
	reg [5:0] cur_state;
	
	assign debug_leds[5:0] = cur_state;

	initial begin
		map_x = 1'b0;
		map_y = 1'b0;
		sprite_data_in = 3'b000;

		pacman_vga_x = 9'd15;
		pacman_vga_y = 9'd10;

		ghost1_vga_x = 9'd20;
		ghost1_vga_y = 9'd10;

		ghost2_vga_x = 9'd25;
		ghost2_vga_y = 9'd10;

		ghost3_vga_x = 9'd30;
		ghost3_vga_y = 9'd10;

		ghost4_vga_x = 9'd30;
		ghost4_vga_y = 9'd10;

		pacman_dx = 2'd0;
		pacman_dy = 2'd0;

		ghost1_dx = 2'd1;
		ghost1_dy = 2'd0;

		ghost2_dx = 2'd1;
		ghost2_dy = 2'd0;

		ghost3_dx = 2'd1;
		ghost3_dy = 2'd0;

		ghost4_dx = 2'd1;
		ghost4_dy = 2'd0;

		cur_state = PACMAN_GET_TARGET;
		target_x = 9'd0;
		target_y = 9'd0;
		is_hit_pacman = 1'b0;

		reset_display = 1'b1;
	end

	always @(posedge slow_clock) 
	begin
		if (reset == 1'b1) begin
			cur_state <= PACMAN_GET_TARGET;			
		end
		else begin
			case (cur_state)
				// ---------------------------------------------------------------------------
				// ============================ PACMAN ======================================
				// ---------------------------------------------------------------------------
				PACMAN_GET_TARGET:
				begin
					cur_state <= PACMAN_GET_MAP_SPRITE;
					case (pacman_dx)
						2'd1: begin
							target_x <= pacman_vga_x + 9'd1;	
							case (pacman_dy)
								2'd1: target_y <= pacman_vga_y + 9'd1;
								2'd2: target_y <= pacman_vga_y - 9'd1;
								default: target_y <= pacman_vga_y;
							endcase
						end

						2'd2: begin
							target_x <= pacman_vga_x - 9'd1;	
							case (pacman_dy)
								2'd1: target_y <= pacman_vga_y + 9'd1;
								2'd2: target_y <= pacman_vga_y - 9'd1;
								default: target_y <= pacman_vga_y;
							endcase
						end

						default: begin
							target_x <= pacman_vga_x;	
							case (pacman_dy)
								2'd1: target_y <= pacman_vga_y + 9'd1;
								2'd2: target_y <= pacman_vga_y - 9'd1;
								default: target_y <= pacman_vga_y;
							endcase
						end
					endcase					
				end
				PACMAN_GET_MAP_SPRITE:
				begin
					char_map_x <= target_x / 9'd5;
					char_map_y <= target_y / 9'd5;	
					map_readwrite <= 1'b0;
					cur_state <= PACMAN_WAIT;				
				end
				PACMAN_WAIT:
				begin
					cur_state <= PACMAN_SET_POS;
				end

				PACMAN_SET_POS:
				begin
					cur_state <= GHOST1_GET_TARGET;
					case (sprite_data_out)
						3'b000: // A black tile
						begin
							pacman_vga_x <= target_x;
							pacman_vga_y <= target_y;
						end
						3'b001: // A big orb
						begin
							pacman_vga_x <= target_x;
							pacman_vga_y <= target_y;
						end


						3'b010: // A small orb
						begin
							pacman_vga_x <= target_x;
							pacman_vga_y <= target_y;
						end

						default: // Blue or gray tile
						begin
							pacman_vga_x <= pacman_vga_x;
							pacman_vga_y <= pacman_vga_y;
							pacman_dx <= 2'd0;
							pacman_dy <= 2'd0;
						end
					endcase
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 1 ======================================
				// ---------------------------------------------------------------------------
				GHOST1_GET_TARGET:
				begin
					cur_state <= GHOST1_GET_MAP_SPRITE;
					case (ghost1_dx)
						2'd1: begin
							target_x <= ghost1_vga_x + 9'd1;	
							case (ghost1_dy)
								2'd1: target_y <= ghost1_vga_y + 9'd1;
								2'd2: target_y <= ghost1_vga_y - 9'd1;
								default: target_y <= ghost1_vga_y;
							endcase
						end

						2'd2: begin
							target_x <= ghost1_vga_x - 9'd1;	
							case (ghost1_dy)
								2'd1: target_y <= ghost1_vga_y + 9'd1;
								2'd2: target_y <= ghost1_vga_y - 9'd1;
								default: target_y <= ghost1_vga_y;
							endcase
						end

						default: begin
							target_x <= ghost1_vga_x;	
							case (ghost1_dy)
								2'd1: target_y <= ghost1_vga_y + 9'd1;
								2'd2: target_y <= ghost1_vga_y - 9'd1;
								default: target_y <= ghost1_vga_y;
							endcase
						end
					endcase
				end
				GHOST1_GET_MAP_SPRITE:
				begin
					char_map_x <= target_x / 9'd5;
					char_map_y <= target_y / 9'd5;
					map_readwrite <= 1'b0;
					cur_state <= GHOST1_WAIT;
				end
				GHOST1_WAIT:
				begin
					cur_state <= GHOST1_SET_POS;
				end
				GHOST1_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost1_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost1_vga_y / 9'd5) begin // If hit pacman
						is_hit_pacman = 1'b1;
					end

					else if (sprite_data_out == 3'b100) begin // A grey tile, negate directions
						ghost1_dx <= -ghost1_dx;
						ghost1_dy <= -ghost1_dy;
					end

					else begin
						ghost1_vga_x <= target_x;
						ghost1_vga_y <= target_y;						
					end
					cur_state <= GHOST2_GET_TARGET;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 2 ======================================
				// ---------------------------------------------------------------------------
				GHOST2_GET_TARGET:
				begin
					cur_state <= GHOST2_GET_MAP_SPRITE;
					case (ghost2_dx)
						2'd1: begin
							target_x <= ghost2_vga_x + 9'd1;	
							case (ghost2_dy)
								2'd1: target_y <= ghost2_vga_y + 9'd1;
								2'd2: target_y <= ghost2_vga_y - 9'd1;
								default: target_y <= ghost2_vga_y;
							endcase
						end

						2'd2: begin
							target_x <= ghost2_vga_x - 9'd1;	
							case (ghost2_dy)
								2'd1: target_y <= ghost2_vga_y + 9'd1;
								2'd2: target_y <= ghost2_vga_y - 9'd1;
								default: target_y <= ghost2_vga_y;
							endcase
						end

						default: begin
							target_x <= ghost2_vga_x;	
							case (ghost2_dy)
								2'd1: target_y <= ghost2_vga_y + 9'd1;
								2'd2: target_y <= ghost2_vga_y - 9'd1;
								default: target_y <= ghost2_vga_y;
							endcase
						end
					endcase
				end
				GHOST2_GET_MAP_SPRITE:
				begin
					char_map_x <= target_x / 9'd5;
					char_map_y <= target_y / 9'd5;
					map_readwrite <= 1'b0;
					cur_state <= GHOST2_WAIT;
				end
				GHOST2_WAIT:
				begin
					cur_state <= GHOST2_SET_POS;
				end

				GHOST2_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost2_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost2_vga_y / 9'd5) begin // If hit pacman
						is_hit_pacman = 1'b1;
					end

					else if (sprite_data_out == 3'b100) begin // A grey tile, negate directions
						ghost2_dx <= -ghost2_dx;
						ghost2_dy <= -ghost2_dy;
					end

					else begin
						ghost2_vga_x <= target_x;
						ghost2_vga_y <= target_y;						
					end
					cur_state <= GHOST3_GET_TARGET;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 3 ======================================
				// ---------------------------------------------------------------------------
				GHOST3_GET_TARGET:
				begin
					cur_state <= GHOST3_GET_MAP_SPRITE;
					case (ghost3_dx)
						2'd1: begin
							target_x <= ghost3_vga_x + 9'd1;	
							case (ghost3_dy)
								2'd1: target_y <= ghost3_vga_y + 9'd1;
								2'd2: target_y <= ghost3_vga_y - 9'd1;
								default: target_y <= ghost3_vga_y;
							endcase
						end

						2'd2: begin
							target_x <= ghost3_vga_x - 9'd1;	
							case (ghost3_dy)
								2'd1: target_y <= ghost3_vga_y + 9'd1;
								2'd2: target_y <= ghost3_vga_y - 9'd1;
								default: target_y <= ghost3_vga_y;
							endcase
						end

						default: begin
							target_x <= ghost3_vga_x;	
							case (ghost3_dy)
								2'd1: target_y <= ghost3_vga_y + 9'd1;
								2'd2: target_y <= ghost3_vga_y - 9'd1;
								default: target_y <= ghost3_vga_y;
							endcase
						end
					endcase
				end
				GHOST3_GET_MAP_SPRITE:
				begin
					char_map_x <= target_x / 9'd5;
					char_map_y <= target_y / 9'd5;
					map_readwrite <= 1'b0;
					cur_state <= GHOST3_WAIT;
				end
				GHOST3_WAIT:
				begin
					cur_state <= GHOST3_SET_POS;
				end
				GHOST3_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost3_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost3_vga_y / 9'd5) begin // If hit pacman
						is_hit_pacman = 1'b1;
					end

					else if (sprite_data_out == 3'b100) begin // A grey tile, negate directions
						ghost3_dx <= -ghost3_dx;
						ghost3_dy <= -ghost3_dy;
					end

					else begin
						ghost3_vga_x <= target_x;
						ghost3_vga_y <= target_y;						
					end
					cur_state <= GHOST4_GET_TARGET;
				end

				// ---------------------------------------------------------------------------
				// ============================ GHOST 4 ======================================
				// ---------------------------------------------------------------------------
				GHOST4_GET_TARGET:
				begin
					cur_state <= GHOST4_GET_MAP_SPRITE;
					case (ghost4_dx)
						2'd1: begin
							target_x <= ghost4_vga_x + 9'd1;	
							case (ghost4_dy)
								2'd1: target_y <= ghost4_vga_y + 9'd1;
								2'd2: target_y <= ghost4_vga_y - 9'd1;
								default: target_y <= ghost4_vga_y;
							endcase
						end

						2'd2: begin
							target_x <= ghost4_vga_x - 9'd1;	
							case (ghost4_dy)
								2'd1: target_y <= ghost4_vga_y + 9'd1;
								2'd2: target_y <= ghost4_vga_y - 9'd1;
								default: target_y <= ghost4_vga_y;
							endcase
						end

						default: begin
							target_x <= ghost4_vga_x;	
							case (ghost4_dy)
								2'd1: target_y <= ghost4_vga_y + 9'd1;
								2'd2: target_y <= ghost4_vga_y - 9'd1;
								default: target_y <= ghost4_vga_y;
							endcase
						end
					endcase
				end
				GHOST4_GET_MAP_SPRITE:
				begin
					char_map_x <= target_x / 9'd5;
					char_map_y <= target_y / 9'd5;
					map_readwrite <= 1'b0;
					cur_state <= GHOST4_WAIT;
				end
				GHOST4_WAIT:
				begin
					cur_state <= GHOST4_SET_POS;
				end
				GHOST4_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost4_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost4_vga_y / 9'd5) begin // If hit pacman
						is_hit_pacman = 1'b1;
					end

					else if (sprite_data_out == 3'b100) begin // A grey tile, negate directions
						ghost4_dx <= -ghost4_dx;
						ghost4_dy <= -ghost4_dy;
					end

					else begin
						ghost4_vga_x <= target_x;
						ghost4_vga_y <= target_y;						
					end
					cur_state <= START_DISPLAY;
				end

				// ---------------------------------------------------------------------------
				// ============================ DISPLAY ======================================
				// ---------------------------------------------------------------------------
				START_DISPLAY:
				begin
					reset_display <= 1'b0;
					start_display <= 1'b1;
					counter <= 28'd0;
					cur_state <= VIEW_DISPLAY;
				end
				VIEW_DISPLAY:
				begin
					reset_display <= 1'b0;
					
					if (start_display == 1'b1) begin
						counter <= counter + 28'd1;
						start_display <= 1'b0;
						cur_state <= VIEW_DISPLAY;
					end
					else if (start_display == 1'b0 && counter < 28'd11200) begin
						counter <= counter + 28'd1;
						cur_state <= VIEW_DISPLAY;
					end
					else if (start_display == 1'b0 && counter >= 28'd11200)begin
						counter <= 28'd0;
						cur_state <= STOP_DISPLAY;
					end
				end
				STOP_DISPLAY:
				begin
					reset_display <= 1'b1;
					counter <= 28'd0;
					cur_state <= PACMAN_GET_TARGET;
				end
			endcase			
		end
	end
	
	always @(*)
	begin
		if (cur_state == VIEW_DISPLAY) begin
			map_x = display_map_x;
			map_y = display_map_y;
		end
		else begin
			map_x = char_map_x;
			map_y = char_map_y;
		end
	end
		
	// The map, containing map data
	MapController map(
		.map_x(map_x),
		.map_y(map_y),
		.sprite_data_in(sprite_data_in),
		.sprite_data_out(sprite_data_out),
		.readwrite(map_readwrite),
		.clock_50(clock_50));

	DisplayController display_controller(
		.en(1'b1),
		.map_x(display_map_x),
		.map_y(display_map_y),
		.sprite_type(sprite_data_out),
		
		.pacman_orientation(~move_left),		
		.pacman_vga_x(pacman_vga_x[7:0]),
		.pacman_vga_y(pacman_vga_y[7:0]),
		
		.ghost1_vga_x(ghost1_vga_x[7:0]),
		.ghost1_vga_y(ghost1_vga_y[7:0]),
		
		.ghost2_vga_x(ghost2_vga_x[7:0]),
		.ghost2_vga_y(ghost2_vga_y[7:0]),
		
		.ghost3_vga_x(ghost3_vga_x[7:0]),
		.ghost3_vga_y(ghost3_vga_y[7:0]),
		
		.ghost4_vga_x(ghost4_vga_x[7:0]),
		.ghost4_vga_y(ghost4_vga_y[7:0]),
		
		.vga_plot(vga_plot),
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_color(vga_colour),
		.reset(reset_display),
		.clock_50(clock_50),
		.is_display_running(is_display_running));

endmodule
