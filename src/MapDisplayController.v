/*
	A controller used to display the map to the screen
 */
module MapDisplayController(
	input plot, 
	output reg [4:0] x_out, 
	output reg [4:0] y_out, 
	input [3:0] type, 
	input en,
	output reg vga_plot, 
	output reg [7:0] vga_x,
	output reg [6:0] vga_y,
	output reg [2:0] vga_color,
	input reset, 
	input clock_50);

	// Getting the x and y coordinates of the blocks (note that the grid is 21 x 21!)
	always @(posedge clock_50) 
	begin
		if (reset == 1'b1 || y_out == 5'd21) 
		begin
			x_out <= 5'd0;
			y_out <= 5'd0;	
			vga_plot <= 1'b0;
		end
		else 
		begin
			if (x_out == 5'd21 && y_out < 5'd21)
			begin
				x_out <= 5'd0;
				y_out <= y_out + 5'd1;
				vga_plot <= 1'b1;
			end
			else 
			begin
				x_out <= x_out + 5'd1;				
				vga_plot <= 1'b1;
			end			
		end
	end	
	
	// Handle the colors
	always @(posedge clock_50)
	begin
		if (reset == 1'b1)
		begin
			vga_color <= 3'b00;
		end
		else
		begin
			vga_x <= x_out;
			vga_y <= y_out;
			case (type)
				3'd0: vga_color <= 3'b010; // Black tile
				3'd3: vga_color <= 3'b001; // Blue tile
				3'd2: vga_color <= 3'b111; // Small orb tile
				3'd1: vga_color <= 3'b111; // Big orb tile
				3'd4: vga_color <= 3'b100; // Grey tile
			endcase
		end
	end
endmodule
