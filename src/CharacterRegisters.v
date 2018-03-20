/*
	A register used to store the coordinates (x, y) of pacman and the four ghosts.
	Depending on the character_type, it will write/read coordinates of a character.

	NOTE: The (x, y) coordinates stored are pixel coordinates! 
	To use them in object collision, perform the % operator!

	The character_types definition (for the character_type pin):
	- Pacman: 000
	- Ghost1: 001
	- Ghost2: 010
	- Ghost3: 011
	- Ghost4: 100

	When readwrite = 0 and en = 1, coordinates of a character can be read from (x_out, y_out).
	When readwrite = 1 and en = 1, new coordinates at (x_in, y_in) can be saved to a character.

	When reset_n = 1, it will reset the characters to its default positions, i.e,
	- Pacman: (2, 2)
	- Ghost1: (2, 2)
	- Ghost2: (2, 2)
	- Ghost3: (2, 2)
	- Ghost4: (2, 2)

	The action of reading and writing will only happen when clock_50 reaches a 
	positive edge (i.e, value of clock_50 goes from 0 to 1.)
 */
module CharacterRegisters(
	input [7:0] x_in,
	input [7:0] y_in,
	output reg [7:0] x_out,
	output reg [7:0] y_out,
	input [2:0] character_type,
	input readwrite,
	input clock_50,
	input reset
	);

	reg [7:0] pacman_x_coordinate;
	reg [7:0] pacman_y_coordinate;

	reg [7:0] ghost1_x_coordinate;
	reg [7:0] ghost1_y_coordinate;

	reg [7:0] ghost2_x_coordinate;
	reg [7:0] ghost2_y_coordinate;

	reg [7:0] ghost3_x_coordinate;
	reg [7:0] ghost3_y_coordinate;

	reg [7:0] ghost4_x_coordinate;
	reg [7:0] ghost4_y_coordinate;

	always @(posedge clock_50) 
	begin
		// If we are performing a reset
		if (reset == 1'b1) 
		begin
			pacman_x_coordinate <= 8'd2;
			pacman_y_coordinate <= 8'd2;

			ghost1_x_coordinate <= 8'd2;
			ghost1_y_coordinate <= 8'd2;

			ghost2_x_coordinate <= 8'd2;
			ghost2_y_coordinate <= 8'd2;

			ghost3_x_coordinate <= 8'd2;
			ghost3_y_coordinate <= 8'd2;

			ghost4_x_coordinate <= 8'd2;
			ghost4_y_coordinate <= 8'd2;
		end

		// If we are performing a read/write operation
		else
		begin
			// If we are writing to the registers
			if (readwrite == 1'b1) 
			begin
				if (character_type == 3'd0)
				begin
					pacman_x_coordinate <= x_in;
					pacman_y_coordinate <= y_in;
				end
				else if (character_type == 3'd1)
				begin
					ghost1_x_coordinate <= x_in;
					ghost1_y_coordinate <= y_in;
				end
				else if (character_type == 3'd2)
				begin
					ghost2_x_coordinate <= x_in;
					ghost2_y_coordinate <= y_in;
				end
				else if (character_type == 3'd3)
				begin
					ghost3_x_coordinate <= x_in;
					ghost3_y_coordinate <= y_in;
				end
				else if (character_type == 3'd4)
				begin
					ghost4_x_coordinate <= x_in;
					ghost4_y_coordinate <= y_in;
				end
			end

			// If we are reading from the registers
			else 
			begin
				if (character_type == 3'd0)
				begin
					x_out <= pacman_x_coordinate;
					y_out <= pacman_y_coordinate;
				end
				else if (character_type == 3'd1)
				begin
					x_out <= ghost1_x_coordinate;
					y_out <= ghost1_y_coordinate;
				end
				else if (character_type == 3'd2)
				begin
					x_out <= ghost2_x_coordinate;
					y_out <= ghost2_y_coordinate;
				end
				else if (character_type == 3'd3)
				begin
					x_out <= ghost3_x_coordinate;
					y_out <= ghost3_y_coordinate;
				end
				else if (character_type == 3'd4)
				begin
					x_out <= ghost4_x_coordinate;
					y_out <= ghost4_y_coordinate;
				end
				else 
				begin
					pacman_x_coordinate <= x_in;
					pacman_y_coordinate <= y_in;
				end				
			end
		end		
	end

endmodule