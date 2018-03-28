module Ghost(
	input [7:0] ghost_x_init,		// The initial ghost x coordinate
	input [7:0] ghost_y_init,		// The initial ghost y coordinate
	input [2:0] ghost_dx_init,		// The initial ghost x direction 
	input [2:0] ghost_dy_init,		// The initial ghost y direction
	input reset_position,			// If set to 1, it will reset the ghost's position
	input [4:0] pacman_map_x,		// Pacman's x coordinate
	input [4:0] pacman_map_y,		// Pacman's y coordinate
	output reg [7:0] ghost_x,		// The current ghost x coordinate
	output reg [7:0] ghost_y,		// The current ghost y coordinate
	output reg [4:0] map_x,			// Should go to the map
	output reg [4:0] map_y,			// Should go to the map
	input [2:0] map_sprite_type,	// Sprite type from the map
	output reg map_readwrite,		// Performing read/write to map
	output reg has_hit_pacman,		// If 1, it has hit pacman; else 0.
	input clock_50,					// The clock
	input reset,					// Performs computations
	output reg is_ready);			// If 0, it is still doing computations; else 1

	reg [2:0] dx;
	reg [2:0] dy;

	reg [7:0] target_x;
	reg [7:0] target_y;

	reg [2:0] cur_state;

	localparam 	COMPUTE_NEW_POSITIONS 	= 3'd0,
				WAIT_FOR_MAP_UPDATE		= 3'd1,
				UPDATE_POSITION			= 3'd2,
				END 					= 3'd3;
	
	initial begin
		target_x = 8'd0;
		target_y = 8'd0;
		ghost_x = 8'd0;
		ghost_y = 8'd0;
		dx = 2'd0;
		dy = 2'd1;
		map_x = 5'd0;
		map_y = 5'd0;
		map_readwrite = 1'b0;
		has_hit_pacman = 1'b0;
		is_ready = 1'b1;
		cur_state = COMPUTE_NEW_POSITIONS;
	end

	always @(posedge clock_50, posedge reset) 
	begin
		if (reset == 1'b1) begin
			is_ready <= 1'b1;	
			target_x <= ghost_x;
			target_y <= ghost_y;
			cur_state <= COMPUTE_NEW_POSITIONS;	
		end

		else if (reset_position == 1'b1) begin
			ghost_x <= ghost_x_init;
			ghost_y <= ghost_y_init;
			dx <= ghost_dx_init;
			dy <= ghost_dy_init;
			is_ready <= 1'b1;
		end
		else begin
			case (cur_state)
				COMPUTE_NEW_POSITIONS: 
				begin
					is_ready <= 1'b0;
					if (dx == 2'b1) begin
						target_x <= ghost_x + 8'd1;
						target_y <= ghost_y;
					end
						
					else if (dx == 2'd2) begin
						target_x <= ghost_x - 8'd1;
						target_y <= ghost_y;
					end
						
					if (dy == 2'b1) begin
						target_x <= ghost_x;
						target_y <= ghost_y + 8'd1;
					end
						
					else if (dy == 2'd2) begin
						target_x <= ghost_x;
						target_y <= ghost_y - 8'd1;
					end						

					map_x <= target_x / 8'd21;
					map_y <= target_y / 8'd21;
					cur_state <= WAIT_FOR_MAP_UPDATE;
				end

				WAIT_FOR_MAP_UPDATE:
				begin
					is_ready <= 1'b0;
					cur_state <= UPDATE_POSITION;
				end

				UPDATE_POSITION: 
				begin
					$display ("%d %d", ghost_x / 8'd21, pacman_map_x);
					is_ready <= 1'b1;
					
					// If it has hit pacman
					if (ghost_x / 8'd21 == pacman_map_x && ghost_y / 8'd21 == pacman_map_y / 8'd21) begin
						has_hit_pacman <= 1'b1;
						cur_state <= END;
					end

					// Check if it hit a wall
					else if (map_sprite_type == 3'b011) begin

						// Reverse the direction
						if (dx == 2'd1)
							dx <= 2'd2;
						else if (dx == 2'd2)
							dx <= 2'd1;

						if (dy == 2'd1)
							dy <= 2'd2;
						else if (dy == 2'd2)
							dy <= 2'd1;

						cur_state <= COMPUTE_NEW_POSITIONS;
					end

					else begin
						ghost_x <= target_x;
						ghost_y <= target_y;
						cur_state <= END;
					end					
				end

				END:
				begin
					cur_state <= END;
				end
			endcase	
		end
	end
endmodule