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
	input clock_50);

	// Going through the grid (note that the grid is 21 x 21!)
	reg [3:0] cur_sprite_x;
	reg [3:0] cur_sprite_y;

	always @(posedge clock_50) 
	begin
		if (reset == 1'b1 || map_y == 5'd21) 
		begin
			map_x <= 5'd0;
			map_y <= 5'd0;
			cur_sprite_x <= 3'd0;
			cur_sprite_y <= 3'd0;	
			vga_plot <= 1'b1;
		end
		else if (en == 1'b1)
		begin
			// If we are currently drawing the sprite
			if (cur_sprite_x < 3'd7 || cur_sprite_y < 3'd7)
			begin

				// If we have finished drawing one row, go to next row
				if (cur_sprite_x == 3'd7)
				begin
					cur_sprite_x <= 3'd0;
					cur_sprite_y <= cur_sprite_y + 3'd1;									
				end				

				// if we are not finished drawing a row, continue on the row
				else 
				begin
					cur_sprite_x <= cur_sprite_x + 3'd1;					
				end
			end

			// If we have finished drawing the sprite
			else 
			begin
				// Reset the current sprite coordinates
				cur_sprite_x <= 3'd0;
				cur_sprite_y <= 3'd0;			

				if (map_x == 5'd21 && map_y < 5'd21)
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
	assign vga_x = ({3'b000, map_x} * 8'd7) + {5'd00000, cur_sprite_x} + 8'd1;
	assign vga_y = ({3'b000, map_y} * 8'd7) + {5'd00000, cur_sprite_y} + 8'd1;

	// Determining the sprite
	reg [6:0] row0;
	reg [6:0] row1;
	reg [6:0] row2;
	reg [6:0] row3;
	reg [6:0] row4;
	reg [6:0] row5;
	reg [6:0] row6;

	always @(*)
	begin
		if (sprite_type == 3'b000) // A black tile
		begin
			row0 = 7'b0000000;
			row1 = 7'b0000000;
			row2 = 7'b0000000;
			row3 = 7'b0000000;
			row4 = 7'b0000000;
			row5 = 7'b0000000;
			row6 = 7'b0000000;
			vga_color = 3'b000;
		end
		else if (sprite_type == 3'b001) // A big orb
		begin
			row0 = 7'b0000000;
			row1 = 7'b0011100;
			row2 = 7'b0111110;
			row3 = 7'b0111110;
			row4 = 7'b0111110;
			row5 = 7'b0011100;
			row6 = 7'b0000000;
			vga_color = 3'b111;
		end
		else if (sprite_type == 3'b010) // A small orb
		begin
			row0 = 7'b0000000;
			row1 = 7'b0000000;
			row2 = 7'b0011100;
			row3 = 7'b0011100;
			row4 = 7'b0011100;
			row5 = 7'b0000000;
			row6 = 7'b0000000;
			vga_color = 3'b111;
		end
		else if (sprite_type == 3'b011) // A blue tile
		begin
			row0 = 7'b1111111;
			row1 = 7'b1111111;
			row2 = 7'b1111111;
			row3 = 7'b1111111;
			row4 = 7'b1111111;
			row5 = 7'b1111111;
			row6 = 7'b1111111;
			vga_color = 3'b001;
		end
		else if (sprite_type == 3'b100) // A grey tile
		begin
			row0 = 7'b1111111;
			row1 = 7'b1111111;
			row2 = 7'b1111111;
			row3 = 7'b1111111;
			row4 = 7'b1111111;
			row5 = 7'b1111111;
			row6 = 7'b1111111;
			vga_color = 3'b010;
		end
	end
endmodule
