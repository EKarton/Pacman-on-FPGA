module readwrite_datapath (
  input read,
  input write,


  output map_readwrite,
  output char_readwrite);



endmodule // readwrite_datapath

module Pacman_movement_test (
  input clock_50,
  input reset,
	input enable,
  input x,
  input y,

  input [7:0] pacman_x_read,
  input [7:0] pacman_y_read,
  input [2:0] curr_sprite_data,

  output able_to_damage,

  output [7:0] pacman_x_write,
  output [7:0] pacman_y_write,
  output reg [2:0] sprite_data_out,

  output reg [8:0] map_address_write，
  output read,
  output write);



  PacmanController pmc0(
    .enable(enable),
    .move_left(x),
    .move_up(y),
    .reset(reset),
    .clock(clock_50),
    .pacman_x_read(pacman_x_read),
    .pacman_y_read(pacman_y_read),
    .curr_sprite_data(curr_sprite_data),

    .able_to_damage(able_to_damage),
    .pacman_x_write(pacman_x_write),
    .pacman_y_write(pacman_y_write),
    .sprite_data_out(sprite_data_out),
    .map_address_write(map_address_write));


  readwrite_control rw_c(
    .clk(clock_50),
    .resetn(reset),
    .go(enable),
    .read(read),
    .write(write));

endmodule // Pacman_movement_test



module readwrite_control (
	input clk,
	input resetn,
	input go,
	output reg  read,
  output reg write
);

  reg current_state, next_state;

  localparam  S_READ_MEM    = 1'd0,
  						S_WRITE_MEM   = 1'd1,


  // Next state logic aka our state table
  always@(*)
  begin: state_table
  				case (current_state)
  						S_READ_MEM: next_state = go ? S_WRITE_MEM : S_READ_MEM; // Loop in current state until value is input
              S_WRITE_MEM: next_state = S_READ_MEM;
      				default:     next_state = S_READ_MEM;
  		endcase
  end // state_table


  // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
  		// By default make all our signals 0
      read = 1'b0;
      write = 1'b0;

  		case (current_state)
            S_READ_MEM :
              begin
                read = 1'b1;
                write = 1'b0;
              end
            S_WRITE_MEM :
              begin
                write = 1'b1;
                read = 1'b0;
              end
  		// default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
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
