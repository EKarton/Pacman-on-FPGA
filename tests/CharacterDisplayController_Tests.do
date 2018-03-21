vlib work
vlog -timescale 1ns/1ns "../src/CharacterDisplayController.v"
vsim CharacterDisplayController
log {/*}
add wave {/*}

#module CharacterDisplayController(
#	input en, 
#	input pacman_orientation,
#	output reg [2:0] character_type, 
#	input [7:0] char_x,
#	input [7:0] char_y,
#	output reg vga_plot, 
#	output [7:0] vga_x,
#	output [7:0] vga_y,
#	output reg [2:0] vga_color,
#	input reset, 
#	input clock_50);

force {reset} 1 0ns, 0 100ns
force {clock_50} 0 0ns, 1 5ns -r 10ns
force {pacman_orientation} 0
force {character_type} 3'b000
force {char_x} 8'd20
force {char_y} 8'd21
force {en} 1

run 3000ns