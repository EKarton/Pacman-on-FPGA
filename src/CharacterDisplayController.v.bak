/*
	A module used to display the characters.

	When en = 1, pacman_orientation is specified, reset was turned from 1 to 0, 
	clock_50 is set to the 50mhz clock; vga_color, vga_plot, vga_x, vga_y goes to VGA adapter;
	char_x, char_y, and character_type goes to the CharacterRegisters,

	It will iterate through all the characters, drawing each character one step at a time
	(one pixel is drawn per clock cycle)
 */
module CharacterDisplayController(
	input en, 
	input pacman_orientation;
	output reg [2:0] character_type, 
	input [7:0] char_x,
	input [7:0] char_y,
	output reg vga_plot, 
	output [7:0] vga_x,
	output [7:0] vga_y,
	output reg [2:0] vga_color,
	input reset, 
	input clock_50);

	// Drawing the pixels of each character and of each of their bitmaps
	reg [3:0] cur_sprite_x;
	reg [3:0] cur_sprite_y;

	always @(posedge clock_50) 
	begin
		if (reset == 1'b1 || character_type == 3'd4) 
		begin
			character_type <= 3'd0;
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
				character_type <= character_type + 3'd1;		
			end		
		end
	end	

	// Determine the absolute pixel coordinates on the screen
	assign vga_x = (char_x * 8'd7) + {5'd00000, cur_sprite_x} + 8'd1;
	assign vga_y = (char_y * 8'd7) + {5'd00000, cur_sprite_y} + 8'd1;

	// Determining the bitmap of the characters
	reg [6:0] row0;
	reg [6:0] row1;
	reg [6:0] row2;
	reg [6:0] row3;
	reg [6:0] row4;
	reg [6:0] row5;
	reg [6:0] row6;

	always @(*)
	begin
		if (character_type == 3'b000) // Pacman
		begin
			if (pacman_orientation == 1'b0) // Facing left
			begin
				row0 = 7'b0111100;
				row1 = 7'b1111110;
				row2 = 7'b0011111;
				row3 = 7'b0001111;
				row4 = 7'b0011111;
				row5 = 7'b1111110;
				row6 = 7'b0111100;
			end
			else // Facing right
			begin
				row0 = 7'b0011110;
				row1 = 7'b0111111;
				row2 = 7'b1111100;
				row3 = 7'b1111000;
				row4 = 7'b1111100;
				row5 = 7'b0111111;
				row6 = 7'b0011110;
			end
			
			vga_color = 3'b000;
		end
		else if (character_type) // Ghosts
		begin
			row0 = 7'b0000000;
			row1 = 7'b0011100;
			row2 = 7'b0101010;
			row3 = 7'b0111110;
			row4 = 7'b0111110;
			row5 = 7'b0101010;
			row6 = 7'b0000000;			

			case (character_type)
				3'b001: vga_color = 3'b001;
				3'b010: vga_color = 3'b100;
				3'b011: vga_color = 3'b010;
				3'b100: vga_color = 3'b110;
			endcase
		end
	end

endmodule