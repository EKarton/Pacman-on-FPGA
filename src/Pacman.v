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

	wire slow_clock;
	
	RateDivider divider(
		.interval(27'd300),
		.reset(reset),
		.en(1'b1),
		.clock_50(CLOCK_50),
		.reduced_clock(slow_clock)
		);

	HexDisplay hex0(
		.hex_digit(beans_ate[3:0]),
		.segments(HEX0)
		);
	HexDisplay hex1(
		.hex_digit(beans_ate[6:3]),
		.segments(HEX1)
		);
		
	wire[6:0] beans_ate;

	MainModule main_module(
		.move_up(~KEY[1]),
		.move_down(~KEY[2]),
		.move_left(~KEY[0]),
		.move_right(~KEY[3]),
		.clock_50(CLOCK_50),
		.slow_clock(slow_clock),
		.reset(reset),
		.vga_colour(colour),
		.vga_x(x),
		.vga_y(y),
		.vga_plot(plot),
		.beans_ate(beans_ate),
		.debug_leds(LEDR));

endmodule

module MainModule(
	input move_up,
	input move_down,
	input move_left,
	input move_right,
	input clock_50,
	input slow_clock,
	input reset,
	output [2:0] vga_colour,
	output [7:0] vga_x,
	output [7:0] vga_y,
	output vga_plot,
	output reg [6:0] beans_ate,
	output [9:0] debug_leds);

		// The states in FSM
		
	localparam
				PACMAN_TRY_EAT = 6'd0,
				PACMAN_EAT_WAIT = 6'd1,
				PACMAN_EAT = 6'd2,
				PACMAN_GET_TARGET		= 6'd3,
				PACMAN_GET_MAP_SPRITE 	= 6'd4,
				PACMAN_WAIT				= 6'd5,
				PACMAN_SET_POS			= 6'd6,

				GHOST1_GET_TARGET		= 6'd7,
				GHOST1_GET_MAP_SPRITE	= 6'd8,
				GHOST1_WAIT				= 6'd9,
				GHOST1_SET_POS			= 6'd10,

				GHOST2_GET_TARGET		= 6'd11,
				GHOST2_GET_MAP_SPRITE	= 6'd12,
				GHOST2_WAIT				= 6'd13,
				GHOST2_SET_POS			= 6'd14,

				GHOST3_GET_TARGET		= 6'd15,
				GHOST3_GET_MAP_SPRITE	= 6'd16,
				GHOST3_WAIT				= 6'd17,
				GHOST3_SET_POS			= 6'd18,

				GHOST4_GET_TARGET		= 6'd19,
				GHOST4_GET_MAP_SPRITE	= 6'd20,
				GHOST4_WAIT				= 6'd21,
				GHOST4_SET_POS			= 6'd22,

				START_DISPLAY			= 6'd23,
				VIEW_DISPLAY			= 6'd24,
				STOP_DISPLAY			= 6'd25,
				
				END_GAME					= 6'd26;
	
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
		beans_ate = 7'd0;
		map_x = 1'b0;
		map_y = 1'b0;
		sprite_data_in = 3'b000;

		pacman_vga_x = 9'd10;
		pacman_vga_y = 9'd5;

		ghost1_vga_x = 9'd25; // Moves up and down on (5, 3)
		ghost1_vga_y = 9'd15;

		ghost2_vga_x = 9'd50; // Moves left and right on (10, 3)
		ghost2_vga_y = 9'd15;

		ghost3_vga_x = 9'd75; // Moves up and down on (15, 9)
		ghost3_vga_y = 9'd45;

		ghost4_vga_x = 9'd65; // Moves left and right on (13, 19)
		ghost4_vga_y = 9'd95;

		pacman_dx = 2'd0;
		pacman_dy = 2'd0;

		ghost1_dx = 2'b00;
		ghost1_dy = 2'b10;

		ghost2_dx = 2'b01;
		ghost2_dy = 2'b00;

		ghost3_dx = 2'b00;
		ghost3_dy = 2'b01;

		ghost4_dx = 2'b10;
		ghost4_dy = 2'b00;

		cur_state = PACMAN_GET_TARGET;
		target_x = 9'd0;
		target_y = 9'd0;
		is_hit_pacman = 1'b0;
		beans_ate = 7'd0;

		reset_display = 1'b1;
	end

	always @(posedge slow_clock, posedge reset) 
	begin
		if (reset == 1'b1) begin
			beans_ate <= 7'd0;
			sprite_data_in <= 3'b000;

			pacman_vga_x <= 9'd10;
			pacman_vga_y <= 9'd5;

			ghost1_vga_x <= 9'd25; // Moves up and down on (5, 3)
			ghost1_vga_y <= 9'd15;

			ghost2_vga_x <= 9'd50; // Moves left and right on (10, 3)
			ghost2_vga_y <= 9'd15;

			ghost3_vga_x <= 9'd75; // Moves up and down on (15, 9)
			ghost3_vga_y <= 9'd45;

			ghost4_vga_x <= 9'd65; // Moves left and right on (13, 19)
			ghost4_vga_y <= 9'd95;

			pacman_dx <= 2'd0;
			pacman_dy <= 2'd0;

			ghost1_dx <= 2'b00;
			ghost1_dy <= 2'b10;

			ghost2_dx <= 2'b01;
			ghost2_dy <= 2'b00;

			ghost3_dx <= 2'b00;
			ghost3_dy <= 2'b01;

			ghost4_dx <= 2'b10;
			ghost4_dy <= 2'b00;

			cur_state <= PACMAN_GET_TARGET;
			target_x <= 9'd0;
			target_y <= 9'd0;
			is_hit_pacman <= 1'b0;
		end
//		
//		else if (reset == 1'b0 && is_hit_pacman == 1'b1) begin
//			cur_state <= END_GAME;
//		end
		
		else begin
			case (cur_state)
				// ---------------------------------------------------------------------------
				// ============================ PACMAN ======================================
				// ---------------------------------------------------------------------------
				PACMAN_TRY_EAT:
					begin
						char_map_x <= pacman_vga_x / 9'd5;
						char_map_y <= pacman_vga_y / 9'd5;
						map_readwrite <= 1'b0;
						cur_state <= PACMAN_EAT_WAIT;
					end
				PACMAN_EAT_WAIT: cur_state <= PACMAN_EAT;
				PACMAN_EAT:
					begin
						case (sprite_data_out)
						3'b001: // Blue or gray tile
						begin
							beans_ate <= beans_ate + 7'd1;
							sprite_data_in <= 3'b000;
							map_readwrite <= 1'b1;
						end
						
						3'b010: // Blue or gray tile
						begin
							beans_ate <= beans_ate + 7'd1;	
							sprite_data_in <= 3'b000;
							map_readwrite <= 1'b1;					
						end	
						
						default:
						begin
							beans_ate <= beans_ate;	
						end
						endcase
						cur_state <= PACMAN_GET_TARGET; 
					end
				PACMAN_GET_TARGET:
				begin
					cur_state <= PACMAN_GET_MAP_SPRITE;
					if(move_up)
						pacman_dy <= 2'b10;
					else if(move_down)
						pacman_dy <= 2'b01;
					else if(move_left)
						pacman_dx <= 2'b10;
					else if(move_right)
						pacman_dx <= 2'b01;
					else
						begin
							pacman_dx <= 2'b00;
							pacman_dy <= 2'b00;
						end
						
					case (pacman_dx)
						2'b01: target_x <= pacman_vga_x + 9'd1;	
						2'b10: target_x <= pacman_vga_x - 9'd1;	
						default: target_x <= pacman_vga_x;	
					endcase
					
					case (pacman_dy)
						2'b01: target_y <= pacman_vga_y + 9'd1;
						2'b10: target_y <= pacman_vga_y - 9'd1;
						default: target_y <= pacman_vga_y;
					endcase
					
				end
				
				PACMAN_GET_MAP_SPRITE:
				begin
					case(pacman_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(pacman_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					
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
						3'b011: // Blue tile
						begin
							pacman_vga_x <= pacman_vga_x;
							pacman_vga_y <= pacman_vga_y;
							pacman_dx <= 2'd0;
							pacman_dy <= 2'd0;
						end
						
						3'b100: // Grey tile
						begin
							pacman_vga_x <= pacman_vga_x;
							pacman_vga_y <= pacman_vga_y;
							pacman_dx <= 2'd0;
							pacman_dy <= 2'd0;
						end
						
						default: // A black tile
						begin
							pacman_vga_x <= target_x;
							pacman_vga_y <= target_y;
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
						2'b01: target_x <= ghost1_vga_x + 9'd1;	
						2'b10: target_x <= ghost1_vga_x - 9'd1;	
						default: target_x <= ghost1_vga_x;	
					endcase
					
					case (ghost1_dy)
						2'b01: target_y <= ghost1_vga_y + 9'd1;
						2'b10: target_y <= ghost1_vga_y - 9'd1;
						default: target_y <= ghost1_vga_y;
					endcase
						cur_state <= GHOST1_GET_MAP_SPRITE;
					end
				GHOST1_GET_MAP_SPRITE:
				begin
				case(ghost1_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
				case(ghost1_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST1_WAIT;
				end
				
				GHOST1_WAIT:
				begin
					cur_state <= GHOST1_SET_POS;
				end
				
				GHOST1_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost1_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost1_vga_y / 9'd5) 
					begin // If hit pacman
						is_hit_pacman <= 1'b1;
					end
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions
						ghost1_dx <= ~ghost1_dx;
						ghost1_dy <= ~ghost1_dy;
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
						2'b01: target_x <= ghost2_vga_x + 9'd1;	
						2'b10: target_x <= ghost2_vga_x - 9'd1;	
						default: target_x <= ghost2_vga_x;	
					endcase
					
					case (ghost2_dy)
						2'b01: target_y <= ghost2_vga_y + 9'd1;
						2'b10: target_y <= ghost2_vga_y - 9'd1;
						default: target_y <= ghost2_vga_y;
					endcase
				end
				GHOST2_GET_MAP_SPRITE:
				begin
					case(ghost2_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost2_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST2_WAIT;
				end			
				
				GHOST2_WAIT:
				begin
					cur_state <= GHOST2_SET_POS;
				end

				GHOST2_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost2_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost2_vga_y / 9'd5) 
					begin // If hit pacman
						is_hit_pacman <= 1'b1;
					end
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions
						ghost2_dx <= ~ghost2_dx;
						ghost2_dy <= ~ghost2_dy;
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
						2'b01: target_x <= ghost3_vga_x + 9'd1;	
						2'b10: target_x <= ghost3_vga_x - 9'd1;	
						default: target_x <= ghost3_vga_x;	
					endcase
					
					case (ghost3_dy)
						2'b01: target_y <= ghost3_vga_y + 9'd1;
						2'b10: target_y <= ghost3_vga_y - 9'd1;
						default: target_y <= ghost3_vga_y;
					endcase
				end
				GHOST3_GET_MAP_SPRITE:
				begin
				begin
					case(ghost3_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost3_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST3_WAIT;
				end			

				end
				GHOST3_WAIT:
				begin
					cur_state <= GHOST3_SET_POS;
				end
				GHOST3_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost3_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost3_vga_y / 9'd5) 
					begin // If hit pacman
						is_hit_pacman <= 1'b1;
					end
					else if (sprite_data_out == 3'b011) begin // A grey tile, negate directions
						ghost3_dx <= ~ghost3_dx;
						ghost3_dy <= ~ghost3_dy;
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
						2'b01: target_x <= ghost4_vga_x + 9'd1;	
						2'b10: target_x <= ghost4_vga_x - 9'd1;	
						default: target_x <= ghost4_vga_x;	
					endcase
					
					case (ghost4_dy)
						2'b01: target_y <= ghost4_vga_y + 9'd1;
						2'b10: target_y <= ghost4_vga_y - 9'd1;
						default: target_y <= ghost4_vga_y;
					endcase
				end
				GHOST4_GET_MAP_SPRITE:
				begin
					case(ghost4_dx)
						2'b01: char_map_x <= (target_x + 9'd4) / 9'd5;
						default: char_map_x <= target_x / 9'd5;
					endcase
					case(ghost4_dy)
						2'b01: char_map_y <= (target_y + 9'd4)/ 9'd5;
						default: char_map_y <= target_y / 9'd5;
					endcase
					map_readwrite <= 1'b0;
					cur_state <= GHOST4_WAIT;
				end			
				
				GHOST4_WAIT:
				begin
					cur_state <= GHOST4_SET_POS;
				end
				GHOST4_SET_POS:
				begin
					if (pacman_vga_x / 9'd5 == ghost4_vga_x / 9'd5 && pacman_vga_y / 9'd5 == ghost4_vga_y / 9'd5) 
					begin // If hit pacman
						is_hit_pacman <= 1'b1;
					end
					else if (sprite_data_out == 3'b011) begin // A blue tile, negate directions
						ghost4_dx <= ~ghost4_dx;
						ghost4_dy <= ~ghost4_dy;
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
					else if (start_display == 1'b0 && counter <= 28'd11300) begin
						counter <= counter + 28'd1;
						cur_state <= VIEW_DISPLAY;
					end
					else if (start_display == 1'b0 && counter > 28'd11300)begin
						counter <= 28'd0;
						cur_state <= STOP_DISPLAY;
					end
				end
				STOP_DISPLAY:
				begin
					reset_display <= 1'b1;
					counter <= 28'd0;
					
					if (is_hit_pacman == 1'b1) begin
						cur_state <= END_GAME;
					end
					else begin
						cur_state <= PACMAN_TRY_EAT;
					end
				end
				
				END_GAME:
				begin
					reset_display <= 1'b1;
					counter <= 28'd0;
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
		
		.pacman_orientation(move_left),		
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
		.reset(reset_display || reset),
		.clock_50(clock_50),
		.is_display_running(is_display_running));

endmodule
