vlib work
vlog -timescale 1ns/1ns "../src/RateDivider.v"
vsim RateDivider
log {/*}
add wave {/*}

#module RateDivider(
#	input [27:0] interval,
#	input reset,
#	input en,
#	input clock_50,
#	output reg reduced_clock);

force {reset} 1 0ns, 0 10ns
force {clock_50} 0 0ns, 1 5ns -r 10ns
force {interval} 27'd4
force {en} 1

run 3000ns