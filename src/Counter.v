module Counter(
	input [27:0] interval,
	input reset,
	input en,
	input clock_50,
	output [27:0] cur_time);
	
	
	reg [27:0] now_time;

	always @(posedge clock_50)
	begin
		if (reset == 1'b1)
		begin
			now_time <= 28'd0;
		end
		else if (en == 1'b1)
		begin
			if (now_time == interval) // Prevent going to negative #s
			begin
				now_time <= 28'd0;
			end
			else
			begin
				now_time <= now_time + 28'd1;
			end
		end
	end
	
	assign cur_time = now_time;
	
endmodule