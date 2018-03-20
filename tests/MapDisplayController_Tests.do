vlib work
vlog -timescale 1ns/1ns "../src/MapDisplayController.v"
vsim MapDisplayController
log {/*}
add wave {/*}

#module MapDisplayController(
#	output reg [4:0] x_out, 
#	output reg [4:0] y_out, 
#	input [3:0] type, 
#	input en,
#	output reg vga_plot, 
#	output reg [7:0] vga_x,
#	output reg [6:0] vga_y,
#	output reg [2:0] vga_color,
#	input reset, 
#	input clock_50);

force {reset} 1 0ns, 0 10ns
force {clock_50} 0 0ns, 1 5ns -r 10ns
force {sprite_type} 3'b000
force {en} 1

run 3000ns