module PacmanController(
   input move_left,
   input move_up,
	input reset,
	input clock,
	input able_to_move,
	input move_next,

   input [7:0] pacman_x_init,
   input [7:0] pacman_y_init,

	input [2:0] curr_sprite_data,

	output reg able_to_damage,

	//current location
	output reg [7:0] pacman_x_coordinate,
	output reg [7:0] pacman_y_coordinate,

	//location it is trying to move to
	output reg [1:0] pacman_dx,
	output reg [1:0] pacman_dy);


endmodule



	module col_datapath (
		input clock,
		input reset,
		
		input waiting0,
		input waiting1,
		input waiting2,
		input read_curr_sprite,
		input write_curr_to_map,
		input read_target_sprite,
		input collision_check,

		input [2:0] target_sprite,

		//current location
		input [7:0] pacman_x_coordinate_in,
		input [7:0] pacman_y_coordinate_in,
		
		
		input [7:0] target_x_coordinate,
		input [7:0] target_y_coordinate,

		//current location
		output reg [4:0] pacman_x_map,
		output reg [4:0] pacman_y_map,
		
		output reg [2:0] map_black_tile,
		output reg [2:0] curr_sprite_data,
		output reg readwrite,
		output reg able_to_move,
		output reg is_ready,
		output reg move_next);
		
		reg [2:0] target_sprite_data;
		initial begin
			map_black_tile = 3'd0;
			able_to_move = 1'b0;
			readwrite = 1'b0;
			is_ready = 1'b0;
			
		end

		always @ ( posedge clock ) begin
			if(reset)
					begin
						able_to_move <= 1'b0;
						readwrite <= 1'b0;
						is_ready <= 1'b0;
					end
				move_next <= 1'b0;
			if(read_curr_sprite)
				begin
					readwrite <= 1'b0;
					pacman_x_map <= pacman_x_coordinate_in / 5'd5;
					pacman_y_map <= pacman_y_coordinate_in / 5'd5;
				end
			else if (waiting0)
				begin
					curr_sprite_data<= target_sprite;
				end
			else if(write_curr_to_map)
				begin
					readwrite <= 1'b1;
					pacman_x_map <= pacman_x_coordinate_in / 5'd5;
					pacman_y_map <= pacman_y_coordinate_in / 5'd5;
				end
			else if (waiting1)
				begin
				end
			else if(read_target_sprite)
				begin
					readwrite <= 1'b0;
					pacman_x_map <= target_x_coordinate / 5'd5;
					pacman_y_map <= target_x_coordinate / 5'd5;
				end
			else if (waiting2)
				begin
					target_sprite_data<=target_sprite;
				end
			else if(collision_check)
				begin
					is_ready <= 1'b1;
					move_next <= 1'b1;
					if (target_sprite_data != 3'b011)
						able_to_move <= 1'b1;
					else
						able_to_move <= 1'b0;
				end
		end


	endmodule // col_datapath


	module col_control (
		input clk,
		input resetn,
		output reg waiting0,
		output reg waiting1,
		output reg waiting2,
		output reg read_curr_sprite,
		output reg write_curr_to_map,
		output reg read_target_sprite,
		output reg collision_check);

	  reg [2:0] current_state, next_state;

	localparam  S_READ_CURR_SPRITE   = 3'd0,
					S_READ_CURR_WAIT = 3'd1,
					S_WRITE_CURR_TO_MAP  = 3'd2,
					S_WRITE_CURR_WAIT = 3'd3,
					S_READ_TARGET_SPRITE = 3'd4,
					S_READ_TARGET_WAIT = 3'd5,
					S_COL_CHECK = 3'd6;


	  // Next state logic aka our state table
	  always@(posedge clk)
	  begin: state_table
			case (current_state)
				S_READ_CURR_SPRITE: next_state <= S_READ_CURR_WAIT; // Loop in current state until value is input
				S_READ_CURR_WAIT: next_state <= S_WRITE_CURR_TO_MAP;
				S_WRITE_CURR_TO_MAP: next_state <= S_WRITE_CURR_WAIT;
				S_WRITE_CURR_WAIT: next_state <= S_READ_TARGET_SPRITE;
				S_READ_TARGET_SPRITE: next_state <= S_READ_TARGET_WAIT;
				S_READ_TARGET_WAIT: next_state <= S_COL_CHECK;
				S_COL_CHECK: next_state <= S_READ_CURR_SPRITE;
	  		endcase
	  end // state_table


	  // Output logic aka all of our datapath control signals
	  always @(posedge clk)
	  begin: enable_signals
	  		// By default make all our signals 0
			read_curr_sprite <= 1'b0;
			write_curr_to_map <= 1'b0;
			read_target_sprite <= 1'b0;
			collision_check <= 1'b0;
			waiting0 <= 1'b0;
			waiting1 <= 1'b0;
			waiting2 <= 1'b0;
	  		case (current_state)
				S_READ_CURR_SPRITE :
					begin
						read_curr_sprite <= 1'b1;
					end
				S_READ_CURR_WAIT: waiting0 <= 1'b1;
				S_WRITE_CURR_TO_MAP :
					begin
						write_curr_to_map <= 1'b1;
					end
				S_WRITE_CURR_WAIT: waiting1 <= 1'b1;
				S_READ_TARGET_SPRITE:
					begin
						read_target_sprite <= 1'b1;
					end
				S_READ_TARGET_WAIT: waiting2 <= 1'b1;
				S_COL_CHECK:
					begin
						collision_check <= 1'b1;
					end
			endcase
	  end // enable_signals

	  // current_state registers
	  always@(posedge clk)
	  begin: state_FFs
	  		if(resetn)
				current_state <= S_READ_CURR_SPRITE;
	  		else
				current_state <= next_state;
	  end // state_FFS


	endmodule // control
