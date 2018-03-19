/*
	A module which stores the x and y coordinates of Ghost4.
	The output pins of x_out and y_out are the current x and y coordinates of Ghost4.
	When en = 1 and readwrite = 1, it will set the coordinates of Ghost4 to (x_in, y_in).
	When readwrite = 0, anything set to x_in or y_in will not affect the saved x and y coordinates.
	When reset_n = 1, it will reset Ghost4's coordinates to (2, 2).
*/
module Ghost4Register(
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

	reg [4:0] ghost4_x_coordinate;
	reg [4:0] ghost4_y_coordinate;

	always @(posedge clock_50) 
	begin
		if (reset_n == 1'b1) 
		begin
			ghost4_x_coordinate <= 5'd2;
			ghost4_y_coordinate <= 5'd2;		
		end
		else if (en == 1'b1)
		begin
			if (readwrite == 1'b0) 
			begin
				ghost4_x_coordinate <= x_in;
				ghost4_y_coordinate <= y_in;				
			end	
		end		
	end

	assign x_out = ghost4_x_coordinate;
	assign y_out = ghost4_y_coordinate;

endmodule