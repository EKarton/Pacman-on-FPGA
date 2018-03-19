/*
	A controller used to display the map to the screen
 */
module MapDisplayController(
	input plot, 
	output reg [4:0] x_out, 
	output reg [4:0] y_out, 
	input [3:0] type, 
	input en,
	output vga_plot, 
	output [7:0] vga_x,
	output [7:0] vga_y,
	output [2:0] vga_color,
	input reset, 
	input clock_50);

	// Getting the x and y coordinates of the blocks (note that the grid is 21 x 21!)
	always @(posedge clock_50) 
	begin
		if (reset == 1'b1 || y_out == 5'd20) 
		begin
			x_out <= 5'd0;
			y_out <= 5'd0;			
		end
		else 
		begin
			if (x_out == 5'd20 && y_out < 5'd20)
			begin
				x_out <= 5'd0;
				y_out <= y_out + 5'd1;
			end
			else 
			begin
				x_out <= x_out + 5'd1;				
				y_out <= y_out;
			end			
		end
	end
endmodule

module DrawSquare(
	input [4:0] left_x,
	input [4:0] top_y, 
	input [4:0] size, 
	input en,
	input reset, 
	input clock_50, 
	output reg [7:0] vga_x, 
	output reg [6:0] vga_y, 
	output reg vga_plot,
	output reg done);

	reg [4:0] offset_x;
	reg [4:0] offset_y;

	always @(posedge clock_50) 
	begin
		if (en == 1'b0 || reset == 1'b1) 
		begin
			offset_x <= 5'd0;
			offset_y <= 5'd0;
			vga_plot <= 1'b1;
			done <= 1'b0;
		end
		else if (en == 1'b1)
		begin
			// When it has finished iterating through the pixels of the square
			if (offset_y == size)
			begin
				offset_x <= 5'd0;
				offset_y <= 5'd0;
				done <= 1'b1;
			end

			// Incrememting the offset_y
			else if (offset_x == size && offset_y < size)
			begin
				offset_x <= 5'd0;
				offset_y <= offset_y + 5'd1;
			end

			// Incrementing the offset_x
			else 
			begin
				offset_x <= offset_x + 5'd1;				
				offset_y <= offset_y;
			end	
		end
	end
	
endmodule

module DrawSmallCircle(
	input [4:0] left_x,
	input [4:0] top_y,
	input en,
	input reset, 
	input clock_50, 
	output reg [7:0] vga_x, 
	output reg [6:0] vga_y, 
	output reg vga_plot,
	output reg done);

	reg [6:0] pixel_0;
	reg [6:0] pixel_1;
	reg [6:0] pixel_2;
	reg [6:0] pixel_3;
	reg [6:0] pixel_4;
	reg [6:0] pixel_5;
	reg [6:0] pixel_6;

	always @(posedge clock_50) 
	begin
		if (reset == 1'b1) 
		begin
			pixel_0 <= 7'b0000000;
			pixel_1 <= 7'b0000000;
			pixel_2 <= 7'b0000000;
			pixel_3 <= 7'b0000000;
			pixel_4 <= 7'b0000000;
			pixel_5 <= 7'b0000000;
			pixel_6 <= 7'b0000000;			
		end
	end

endmodule
