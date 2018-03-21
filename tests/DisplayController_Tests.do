vlib work
vlog -timescale 1ns/1ns "../src/DisplayController.v" "../src/MapDisplayController.v" "../src/CharacterDisplayController.v"
vsim DisplayController
log {/*}
add wave -r /*

force {reset} 1 0ns, 0 1ns
force {clock_50} 0 0ns, 1 1ns -r 2ns
force {pacman_orientation} 0
force {character_type} 3'b000
force {char_x} 8'd20
force {char_y} 8'd21
force {sprite_type} 3'b000
force {en} 1

run 393500