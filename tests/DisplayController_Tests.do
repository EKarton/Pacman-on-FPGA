vlib work
vlog -timescale 1ns/1ns "../src/DisplayController.v" "../src/MapDisplayController.v" "../src/CharacterDisplayController.v"
vsim DisplayController
log {/*}
add wave -r /*

force {reset} 1 0ns, 0 1ns
force {clock_50} 0 0ns, 1 1ns -r 2ns
force {pacman_orientation} 0
force {en} 1
force {sprite_type} 3'd0

force {pacman_orientation} 8'd
force {pacman_vga_x} 8'd0
force {pacman_vga_y} 8'd0

force {ghost1_vga_x} 8'd1
force {ghost1_vga_y} 8'd0

force {ghost2_vga_x} 8'd2
force {ghost2_vga_y} 8'd0

force {ghost3_vga_x} 8'd3
force {ghost3_vga_y} 8'd0

force {ghost4_vga_x} 8'd4
force {ghost4_vga_y} 8'd0

run 393500ns