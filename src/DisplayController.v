
module DisplayController(
	input en, 
	output [4:0] map_x, 
	output [4:0] map_y, 
	input [2:0] sprite_type, 
	
	input pacman_orientation,
	input [7:0] pacman_vga_x,
	input [7:0] pacman_vga_y,
	
	input [7:0] ghost1_vga_x,
	input [7:0] ghost1_vga_y,
	
	input [7:0] ghost2_vga_x,
	input [7:0] ghost2_vga_y,
	
	input [7:0] ghost3_vga_x,
	input [7:0] ghost3_vga_y,
	
	input [7:0] ghost4_vga_x,
	input [7:0] ghost4_vga_y,
	
	output reg vga_plot, 
	output reg [7:0] vga_x,
	output reg [7:0] vga_y,
	output reg [2:0] vga_color,
	
	input reset, 
	input clock_50,
	output reg is_display_running);
	
	// A clock, used to determine which display controller to use.
	reg unsigned selected_display_controller;
	reg unsigned [14:0] current_time;
	
	// Determines what the character controller is currently displaying
	wire [2:0] character_type;
	reg unsigned [7:0] x_out, y_out;
	
	initial
	begin
		selected_display_controller = 1'b0;
		current_time = 15'd0;
		x_out = 8'd0;
		y_out = 8'd0;
	end

	always @(posedge clock_50)
	begin
		if (reset == 1'b1) begin
			current_time = 15'd0;
			selected_display_controller = 1'b0;
			is_display_running <= 1'b0;
		end
		
		else begin
			if (current_time < 15'd11025)
			begin
				is_display_running <= 1'b1;
				current_time <= current_time + 15'd1;
				selected_display_controller <= 1'b0;
			end
			else if (current_time >= 15'd11025 && current_time <= 15'd11125)
			begin
				is_display_running <= 1'b1;
				current_time <= current_time + 15'd1;
				selected_display_controller <= 1'b1;
			end
			else 
			begin
				is_display_running <= 1'b0;
				current_time <= 15'd0;
				selected_display_controller <= 1'b0;    			
			end
		end		
	end
	
	// A mux used to control which character to select
	always @(*)
	begin
		case (character_type)
			// Pacman
			3'd0: begin 
				x_out = pacman_vga_x;
				y_out = pacman_vga_y;
			end
			
			// Ghost 1
			3'd1: begin
				x_out = ghost1_vga_x;
				y_out = ghost1_vga_y;
			end
			
			// Ghost 2
			3'd2: begin
				x_out = ghost2_vga_x;
				y_out = ghost2_vga_y;
			end
			
			// Ghost 3
			3'd3: begin
				x_out = ghost3_vga_x;
				y_out = ghost3_vga_y;
			end
			
			// Ghost 4
			3'b100: begin
				x_out = ghost4_vga_x;
				y_out = ghost4_vga_y;
			end
			
			default: begin
				x_out = 8'd0;
				y_out = 8'd0;
			end
		endcase
	end

	// The VGA output pins from the various controllers.
	wire [7:0] vga_x_cdc;
	wire [7:0] vga_y_cdc;
	wire [7:0] vga_x_mdc;
	wire [7:0] vga_y_mdc;
	wire [2:0] vga_color_cdc;
	wire [2:0] vga_color_mdc;
	wire vga_plot_cdc;
	wire vga_plot_mdc;

	CharacterDisplayController cdc_controller(
		.en(en),
		.pacman_orientation(pacman_orientation),
		.character_type(character_type),
		.char_x(x_out),
		.char_y(y_out),
		.vga_plot(vga_plot_cdc),
		.vga_x(vga_x_cdc),
		.vga_y(vga_y_cdc),
		.vga_color(vga_color_cdc),
		.reset(reset),
		.clock_50(clock_50)
	);

	MapDisplayController mdc_controller(
		.en(en), 
		.map_x(map_x), 
		.map_y(map_y), 
		.sprite_type(sprite_type), 
		.vga_plot(vga_plot_mdc), 
		.vga_x(vga_x_mdc), 
		.vga_y(vga_y_mdc), 
		.vga_color(vga_color_mdc),
		.reset(reset), 
		.clock_50(clock_50), 
		.debug_leds(debug_leds)
	);
	
	// The mux, used to select which vga pins to use
	always @(*)
	begin		
		if (selected_display_controller == 1'b0)
		begin
			vga_x = vga_x_mdc;
			vga_y = vga_y_mdc;
			vga_color = vga_color_mdc;
			vga_plot = vga_plot_mdc;	
		end
		else 
		begin
			vga_x = vga_x_cdc;
			vga_y = vga_y_cdc;
			vga_color = vga_color_cdc;
			vga_plot = vga_plot_cdc;	
		end
	end

endmodule