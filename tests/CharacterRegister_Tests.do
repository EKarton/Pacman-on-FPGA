vlib work
vlog -timescale 1ns/1ns "../src/CharacterRegisters.v"
vsim CharacterRegisters
log {/*}
add wave {/*}

#module CharacterRegisters(
#	input [7:0] x_in,
#	input [7:0] y_in,
#	output reg [7:0] x_out,
#	output reg [7:0] y_out,
#	input [2:0] character_type,
#	input readwrite,
#	input clock_50,
#	input reset
#	);

force {reset} 1 0ns, 0 10ns
force {clock_50} 0 0ns, 1 5ns -r 10ns
force {character_type} 3'd0
force {readwrite} 0 20ns, 1 40ns, 0 60ns, 1 80ns, 0 100ns
force {x_in} 8'd50 40ns, 8'd20 80ns
force {y_in} 8'd20 40ns, 8'd30 80ns

run 300ns