vlib work
vlog -timescale 1ns/1ns "../src/Pacman.v" "../src/DisplayController.v" "../src/MapDisplayController.v" "../src/DummyMapController.v"
vsim MainModule
log {/*}
add wave -r {/*}
	
force {reset} 1 0ns, 0 10ns
force {clock_50} 0 0ns, 1 5ns -r 10ns

run 300000ns
