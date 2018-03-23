module PacmanController(
	input enable,
  input move_left,
  input move_up,
	input reset,
	input clock,
  input [7:0] pacman_x_read,
  input [7:0] pacman_y_read,
  output [7:0] pacman_x_write,
  output [7:0] pacman_y_write,
  output reg [2:0] sprite_data_out,
  output reg [8:0] map_address_write,
  output map_write,
  output char_reg_write);

  always @ ( posedge clock ) begin
    if(reset == 1'b1)
      begin
        pacman_x_write = pacman_x_read;
        pacman_y_write = pacman_y_read;
        sprite_data_out = 3'd0;
        map_address_write = 9'd0;
        map_write = 1'b0;
        char_reg_write = 1'b0;
      end
    if(enable == 1'b1)
      begin
      //before moving, make the current block all black
      map_read = 1'b1;
      map_address_write <= (5'd 21 * pacman_y_read) + pacman_x_read;
      sprite_data_out <= 3'b000;
      char_reg_write = 1'b1;
        if (move_left == 1'b1)
          begin
            pacman_x_write <= pacman_x_read - 1'b1;
          end
        else if(move_left == 1'b0)
          begin
          pacman_x_write <= pacman_x_read + 1'b1;
          end
        else if (move_up == 1'b1)
          begin
          pacman_y_write <= pacman_y_read + 1'b1;
          end
        else if (move_up == 1'b0)
          begin
          pacman_y_write <= pacman_y_read - 1'b1;
          end
        end
  end
  endmodule
