module CharacterDisplayController(
	input en, 
	output [2:0] character_type, 
	input [7:0] char_x,
	input [7:0] char_y,
	output reg vga_plot, 
	output [7:0] vga_x,
	output [6:0] vga_y,
	output reg [2:0] vga_color,
	input reset, 
	input clock_50);

endmodule