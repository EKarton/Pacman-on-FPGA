/*
	A module which stores the x and y coordinates of Pacman.
	The output pins of x_out and y_out are the current x and y coordinates of Pacman.
	When en = 1 and readwrite = 1, it will set the coordinates of Pacman to (x_in, y_in).
	When readwrite = 0, anything set to x_in or y_in will not affect the saved x and y coordinates.
	When reset_n = 1, it will reset Pacman's coordinates to (2, 2).
*/
module PacmanRegister(
	output [4:0] x_out,
	output [4:0] y_out,
	input [4:0] x_in,
	input [4:0] y_in,
	input [2:0] type,
	input en,
	input readwrite,
	input clock_50,
	input reset_n
	);

	reg [4:0] pacman_x_coordinate;
	reg [4:0] pacman_y_coordinate;

	always @(posedge clock_50) 
	begin
		if (reset_n == 1'b1) 
		begin
			pacman_x_coordinate <= 5'd2;
			pacman_y_coordinate <= 5'd2;		
		end
		else if (en == 1'b1)
		begin
			if (readwrite == 1'b0) 
			begin
				pacman_x_coordinate <= x_in;
				pacman_y_coordinate <= y_in;				
			end	
		end		
	end

	assign x_out = pacman_x_coordinate;
	assign y_out = pacman_y_coordinate;

endmodule