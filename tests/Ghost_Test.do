vlib work
vlog -timescale 1ns/1ns "../src/Ghost.v"
vsim Ghost
log {/*}
add wave {/*}

force {ghost_x_init} 8'd21		
force {ghost_y_init} 8'd0
force {ghost_dx_init} 2'd1
force {ghost_dy_init} 2'd0		
force {reset_position} 1 0ns, 0 20ns
force {pacman_map_x} 5'd3
force {pacman_map_y} 5'd0
force {map_sprite_type} 3'b000
force {clock_50} 0 0ns, 1 10ns -r 20ns
force {reset} 1 0ns, 0 20ns -r 60ns
run 4000ns