/*
	A register used to hold the different types of player scores
	Depending on the type, it will write/read the score.

	The types definition (for the score_type pin):
	- The player's score: 			0
	- The number of lives left: 	1

	When readwrite = 0 and en = 1, the score can be read from data_out.
	When readwrite = 1 and en = 1, the new score from data_in is saved.

	When reset_n = 1, it will reset the scores to its default values, i.e,
	- The player's score:		0
	- The number of lives left:	3

	The action of reading and writing will only happen when clock_50 reaches a 
	positive edge (i.e, value of clock_50 goes from 0 to 1.)
 */
module PlayerScores(
	input [7:0] data_in,
	output reg [7:0] data_out, 
	input score_type,
	input en,
	input readwrite,
	input clock_50,
	input reset_n);

	reg [7:0] player_score;
	reg [1:0] num_lives_left;

	always @(posedge clock_50) 
	begin
		if (reset_n)
		 begin
			player_score <= 8'd0;
			num_lives_left <= 2'd3;			
		end
		else if (en == 1'b1) 
		begin
			// When we are on read mode
			if (readwrite == 1'b0)
			begin
				if (score_type == 1'b0)
				begin
					data_out <= player_score;
				end
				else 
				begin
					data_out <= num_lives_left;					
				end					
			end

			// When we are on write mode
			else 
			begin
				if (score_type == 1'b0)
				begin
					player_score <= data_in;
				end
				else 
				begin
					num_lives_left <= data_in;					
				end				
			end			
		end
	end

endmodule