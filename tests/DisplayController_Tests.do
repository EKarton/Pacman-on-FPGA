vlib work
vlog -timescale 1ns/1ns "../src/*.v"
vsim DisplayController
log {/*}
add wave {/*}

#module DisplayController(
#	input en, 
#
#	output reg [4:0] map_x, 
#	output reg [4:0] map_y, 
#	input [2:0] sprite_type, 
#
#	input pacman_orientation,
#	output reg [2:0] character_type, 
#	input [7:0] char_x,
#	input [7:0] char_y,
#
#	output reg vga_plot, 
#	output reg [7:0] vga_x,
#	output reg [7:0] vga_y,
#	output reg [2:0] vga_color,
#
#	input reset, 
#	input clock_50,
#	output [7:0] debug_leds
#	);

force {reset} 1 0ns, 0 1ns
force {clock_50} 0 0ns, 1 1ns -r 2ns
force {pacman_orientation} 0
force {character_type} 3'b000
force {char_x} 8'd20
force {char_y} 8'd21
force {sprite_type} 3'b000
force {en} 1

run 166666ns