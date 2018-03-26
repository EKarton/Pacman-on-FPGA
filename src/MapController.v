/*
	A controller used to read/write map data.
	When readwrite = 0, it is at read mode, and data at (x, y) is being outputted to data_out.
	When readwrite = 1, it is at write mode, and the data inputted in data_in gets saved at (x, y)
	When reset_n = 1, it will reset the map to default values; else it will not.
	The input pins (x, y) represents the x and y coordinates
 */
module MapController(
	input [4:0] map_x,
	input [4:0] map_y,
	input [2:0] sprite_data_in,
	output [2:0] sprite_data_out,
	input readwrite,
	input clock_50);

	wire [8:0] extended_map_x = {3'b000, map_x};

	wire [8:0] extended_map_y = {3'b000, map_y};


	wire [8:0] client_address;
	assign client_address = (9'd21 * extended_map_y) + extended_map_x;

	/*
	address,
	clock,
	data,
	wren,
	q;
	*/
	Map map(
		.address(client_address),
		.clock(clock_50),
		.data(sprite_data_in),
		.wren(readwrite),
		.q(sprite_data_out)
		);

endmodule
