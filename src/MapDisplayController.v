/*
	A controller used to display the map to the screen
	To display data to the screen, set en = 1, reset first to 1, then to 0, 
	attach map_x, map_y, sprite_type to the MapController (to get data),
	attach the vga_plot, vga_x, vga_y, and vga_color to the VGA adapter.
 */
module MapDisplayController(
	input en, 
	output reg [4:0] map_x, 
	output reg [4:0] map_y, 
	input [2:0] sprite_type, 
	output reg vga_plot, 
	output [7:0] vga_x,
	output [7:0] vga_y,
	output reg [2:0] vga_color,
	input reset, 
	input clock_50,
	output [7:0] debug_leds);
	
	reg [2:0] cur_sprite_x;
	reg [2:0] cur_sprite_y;

	assign debug_leds[4:0] = map_x;

	always @(posedge clock_50) 
	begin
		if (reset == 1'b1 || map_y == 5'd21) 
		begin
			map_x <= 5'd0;
			map_y <= 5'd0;
			cur_sprite_x <= 3'd0;
			cur_sprite_y <= 3'd0;	
		end
		else //if (en == 1'b1)
		begin

			// If we are currently drawing the sprite
			if (cur_sprite_y != 3'd4 || cur_sprite_x != 3'd4)
			begin			
				if(cur_sprite_x < 3'd4)
				begin
					cur_sprite_x <= cur_sprite_x + 3'd1;
				end
					
				else if (cur_sprite_x == 3'd4)
				begin
					cur_sprite_x <= 3'd0;
					cur_sprite_y <= cur_sprite_y + 3'd1;
				end
			end
			
			// If we have finished drawing the sprite
			else 
			begin
				// Reset the current sprite coordinates
				cur_sprite_x <= 3'd0;
				cur_sprite_y <= 3'd0;

				if (map_x == 5'd20)
				begin
					map_x <= 5'd0;
					map_y <= map_y + 5'd1;	
				end
				else 
				begin
					map_x <= map_x + 5'd1;					
				end	
			end		
		end
	end	
	
	

	// Determine the absolute pixel coordinates on the screen
	assign vga_x = ({3'b000, map_x} * 8'd5) + {4'd0, cur_sprite_x};
	assign vga_y = ({3'b000, map_y} * 8'd5) + {4'd0, cur_sprite_y};

	// Determining the sprite
	reg [4:0] row0;
	reg [4:0] row1;
	reg [4:0] row2;
	reg [4:0] row3;
	reg [4:0] row4;

	reg [2:0] sprite_color;

	always @(*)
	begin
		if (sprite_type == 3'b000) // A black tile
		begin
			row0 = 5'b00000;
			row1 = 5'b00000;
			row2 = 5'b00000;
			row3 = 5'b00000;
			row4 = 5'b00000;

			sprite_color = 3'b000;
		end
		else if (sprite_type == 3'b001) // A big orb
		begin
			row0 = 5'b00000;
			row1 = 5'b01110;
			row2 = 5'b01110;
			row3 = 5'b01110;
			row4 = 5'b00000;

			sprite_color = 3'b111;
		end
		else if (sprite_type == 3'b010) // A small orb
		begin
			row0 = 5'b00000;
			row1 = 5'b01100;
			row2 = 5'b01100;
			row3 = 5'b00000;
			row4 = 5'b00000;
			sprite_color = 3'b111;
		end
		else if (sprite_type == 3'b011) // A blue tile
		begin
			row0 = 5'b11111;
			row1 = 5'b11111;
			row2 = 5'b11111;
			row3 = 5'b11111;
			row4 = 5'b11111;

			sprite_color = 3'b001;
		end
		else if (sprite_type == 3'b100) // A grey tile
		begin
			row0 = 5'b11111;
			row1 = 5'b11111;
			row2 = 5'b11111;
			row3 = 5'b11111;
			row4 = 5'b11111;

			sprite_color = 3'b010;
		end
		else
		begin
			row0 = 5'b11111;
			row1 = 5'b11111;
			row2 = 5'b11111;
			row3 = 5'b11111;
			row4 = 5'b11111;

			sprite_color = 3'b010;
		end
	end
	
	reg [6:0] selected_row;
	always @(*)
	begin
		case (cur_sprite_y)
			4'd0: selected_row = row0;
			4'd1: selected_row = row1;
			4'd2: selected_row = row2;
			4'd3: selected_row = row3;
			4'd4: selected_row = row4;

			default: selected_row = row0;
		endcase
	end
	
	reg selected_col;
	always @(*)
	begin
		case (cur_sprite_x)
			4'd0: selected_col = selected_row[0];
			4'd1: selected_col = selected_row[1];
			4'd2: selected_col = selected_row[2];
			4'd3: selected_col = selected_row[3];
			4'd4: selected_col = selected_row[4];

			default: selected_col = selected_row[0];
		endcase
	end
	
	always @(*)
	begin
		vga_color = sprite_color;
		
		if (selected_col == 1'b1 && reset == 1'b0)
		begin
			vga_plot = 1'b1;
		end
		else
		begin
			vga_plot = 1'b0;
		end
	end
endmodule
