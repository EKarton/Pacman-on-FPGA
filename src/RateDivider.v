/*
	A rate dividor which slows down the clock signal by an interval, i.e,
	the rate dividor ticks (i.e, flips from 1 to 0, 0 to 1, etc.) 
	when the clock signal ellapsed for a certain interval amount.

	When reset_n = 1, it resets the rate dividor.
	The reduced_clock is the slowed down clock signal.
	When en = 1 and reset_n = 0, it will output a slower clock signal.
 */
module RateDivider(
	input [27:0] interval,
	input reset,
	input en,
	input clock_50,
	output reg reduced_clock);

	reg [27:0] cur_time;

	always @(posedge clock_50)
	begin
		if (reset == 1'b1)
		begin
			cur_time <= interval;
			reduced_clock <= 1'b0;
		end
		else if (en == 1'b1)
		begin
			if (cur_time == 27'd1) // Prevent going to negative #s
			begin
				cur_time <= interval;
				reduced_clock <= ~reduced_clock;
			end
			else
			begin
				cur_time <= cur_time - 1'b1;
			end
		end
	end
endmodule