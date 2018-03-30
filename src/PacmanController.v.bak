module PacmanController(
	input enable,
  input move_left,
  input move_up,
	input reset,
	input clock,
	input able_to_move,

  input [7:0] pacman_x_init,
  input [7:0] pacman_y_init,

	input [2:0] curr_sprite_data,

	output able_to_damage,

	//current location
	output reg [7:0] pacman_x_coordinate,
	output reg [7:0] pacman_y_coordinate,

	//location it is trying to move to
	output reg [7:0] target_x_coordinate,
	output reg [7:0] target_y_coordinate);


	wire enable_counter;
	wire reset_counter;


	reg [27:0] counter_time;

	reg curr_moving_x;
	reg curr_moving_y;
	reg curr_dir;//current moving direction, 0 is up/down , 1 is sideways

	Counter invinsible_counter(
		.interval(4'd5),
		//5seconds of invinsible time after consuming the big white blob
		.reset(reset_counter),
		.en(enable_counter),
		.clock_50(clock),
		.cur_time(counter_time));

  always @ ( posedge clock ) begin
    if(reset == 1'b1)
      begin
				//initializing counter
				reset_counter = 1'b1;
				enable_counter = 1'b0;
				able_to_damage = 1'b1;

				pacman_x_coordinate <= pacman_x_init;
				pacman_y_coordinate <= pacman_y_init;

				curr_moving_x <= move_left;
				curr_moving_y <= move_up;
				curr_dir = 1'b0;//defualt moving up/down
      end
    else if(enable == 1'b1)      begin

				if(curr_sprite_data == 3'b001)
				//currently on the big blob
					begin
					enable_counter = 1'b1;//enable invinsible
					if(counter_time < 4'd5)
							able_to_damage = 1'b0;//invinsible
					else
						begin
							reset_counter = 1'b1;
							enable_counter = 1'b0;
							able_to_damage = 1'b1;
						end
					end
					//detect which direction to move from the changing of swithes
					if(curr_moving_x != move_left)
						begin
							curr_moving_x <= move_left;
							curr_dir <= 1'b1;
						end
					else if (curr_moving_y != move_up)
						begin
							curr_moving_y <= move_up;
							curr_dir <= 1'b0;
						end
					end

					//moving
				if(curr_dir == 1'b0 && move_up == 1'b1)
					target_y_coordinate <= pacman_y_coordinate + 1'b1;
				else if (curr_dir == 1'b0 && move_up == 1'b0)
					target_y_coordinate <= pacman_y_coordinate - 1'b1;
				else if (curr_dir == 1'b1 && move_left == 1'b0)
					target_x_coordinate <= pacman_x_coordinate - 1'b1;
				else if (curr_dir == 1'b1 && move_left == 1'b1)
					target_x_coordinate <= pacman_x_coordinate + 1'b1;
			end
  	end

		always @ ( posedge clock ) begin
			if (able_to_move)
				begin
					pacman_x_coordinate <= target_x_coordinate;
					pacman_y_coordinate <= target_y_coordinate;
				end
		end
  endmodule



	module col_datapath (
		input clock,
		input reset,

		input read_curr_sprite,
		input write_curr_to_map,
		input read_target_sprite,
		input write_target_to_map,

		input [2:0] target_sprite,

		//current location
		input [7:0] pacman_x_coordinate_in,
		input [7:0] pacman_y_coordinate_in,

		//current location
		output reg [7:0] pacman_x_coordinate_out,
		output reg [7:0] pacman_y_coordinate_out,

		output readwrite,
		output able_to_move);

		always @ ( posedge clock ) begin
			if(read_curr_sprite)
				begin
					readwrite = 1'b0;
					pacman_x_coordinate_out <= pacman_x_coordinate_in;
					pacman_y_coordinate_out <= pacman_y_coordinate_in;
				end
			else if(write_curr_to_map)
			else if(read_target_sprite)
			else if(write_target_to_map)
		end




	endmodule // col_datapath


	module col_control (
		input clk,
		input resetn,
		output read_curr_sprite,
		output write_curr_to_map,
		output read_target_sprite,
		output write_target_to_map);

	  reg current_state, next_state;

		localparam  S_READ_CURR_SPRITE   = 1'd0,
	  						S_WRITE_CURR_TO_MAP  = 1'd1,
								S_READ_TARGET_SPRITE = 1'd2,
								S_WRITE_TARGET_TO_MAP = 1'd3;


	  // Next state logic aka our state table
	  always@(*)
	  begin: state_table
	  				case (current_state)
	  						S_READ_CURR_SPRITE: next_state = S_WRITE_CURR_TO_MAP; // Loop in current state until value is input
	              S_WRITE_CURR_TO_MAP: next_state = S_READ_TARGET_SPRITE;
								S_READ_TARGET_SPRITE: next_state = S_WRITE_TARGET_TO_MAP
								S_WRITE_TARGET_TO_MAP: next_state = S_READ_CURR_SPRITE;
	      				default:     next_state = S_READ_MEM;
	  		endcase
	  end // state_table


	  // Output logic aka all of our datapath control signals
	  always @(*)
	  begin: enable_signals
	  		// By default make all our signals 0
				read_curr_sprite = 1'b0;
				write_curr_to_map = 1'b0;
				read_target_sprite = 1'b0;
				write_target_to_map = = 1'b0;

	  		case (current_state)
	            S_READ_CURR_SPRITE :
								begin
									read_curr_sprite = 1'b1;
									write_curr_to_map = 1'b0;
									read_target_sprite = 1'b0;
									write_target_to_map = = 1'b0;
								end
	            S_WRITE_CURR_TO_MAP :
								begin
									read_curr_sprite = 1'b0;
									write_curr_to_map = 1'b1;
									read_target_sprite = 1'b0;
									write_target_to_map = = 1'b0;
								end
							S_READ_TARGET_SPRITE:
								begin
									read_curr_sprite = 1'b0;
									write_curr_to_map = 1'b0;
									read_target_sprite = 1'b1;
									write_target_to_map = = 1'b0;
								end
							S_WRITE_TARGET_TO_MAP:
								begin
									read_curr_sprite = 1'b0;
									write_curr_to_map = 1'b0;
									read_target_sprite = 1'b0;
									write_target_to_map = = 1'b1;
								end
	  	endcase
	  end // enable_signals

	  // current_state registers
	  always@(posedge clk)
	  begin: state_FFs
	  		if(!resetn)
	  				current_state <= S_READ_MEM;
	  		else
	  				current_state <= next_state;
	  end // state_FFS


	endmodule // control
