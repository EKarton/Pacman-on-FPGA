/*
	A controller used to read/write map data.
	When readwrite = 0, it is at read mode, and data at (x, y) is being outputted to data_out.
	When readwrite = 1, it is at write mode, and the data inputted in data_in gets saved at (x, y)
	When reset_n = 1, it will reset the map to default values; else it will not.
	The input pins (x, y) represents the x and y coordinates
 */
module GridRegister(
	input [4:0] x, 
	input [4:0] y, 
	input [2:0] data_in, 
	output reg [2:0] data_out, 
	input readwrite, 
	input clock_50, 
	input reset_n);

	wire [8:0] address;
	assign address = 20 * {15'd0, y} + {15'd0, x};

	Grid grid(address, clock_50, data_in, readwrite, data_out);	

endmodule