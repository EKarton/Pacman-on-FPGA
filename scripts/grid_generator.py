map = [
	[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0], 
	[0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 3, 0],
	[0, 3, 1, 3, 3, 2, 3, 3, 3, 2, 3, 2, 3, 3, 3, 2, 3, 3, 1, 3, 0],
	[0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 0],
	[0, 3, 2, 3, 3, 2, 3, 2, 3, 3, 3, 3, 3, 2, 3, 2, 3, 3, 2, 3, 0],
	[0, 3, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 3, 0],
	[0, 3, 3, 3, 3, 2, 3, 3, 3, 0, 3, 0, 3, 3, 3, 2, 3, 3, 3, 3, 0],
	[0, 0, 0, 0, 3, 2, 3, 0, 0, 0, 0, 0, 0, 0, 3, 2, 3, 0, 0, 0, 0],
	[3, 3, 3, 3, 3, 2, 3, 0, 3, 3, 4, 3, 3, 0, 3, 2, 3, 3, 3, 3, 3],
	[0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 0],
	[3, 3, 3, 3, 3, 2, 3, 0, 3, 3, 4, 3, 3, 0, 3, 2, 3, 3, 3, 3, 3],
	[0, 0, 0, 0, 3, 2, 3, 0, 0, 0, 0, 0, 0, 0, 3, 2, 3, 0, 0, 0, 0],
	[0, 3, 3, 3, 3, 2, 3, 0, 3, 3, 3, 3, 3, 0, 3, 2, 3, 3, 3, 3, 0],
	[0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 3, 0],
	[0, 3, 2, 3, 3, 2, 3, 3, 3, 2, 3, 2, 3, 3, 3, 2, 3, 3, 2, 3, 0],
	[0, 3, 1, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 1, 3, 0],
	[0, 3, 3, 2, 3, 2, 3, 2, 3, 3, 3, 3, 3, 2, 3, 2, 3, 2, 3, 3, 0],
	[0, 3, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 2, 3, 0],
	[0, 3, 2, 3, 3, 3, 3, 3, 3, 0, 3, 0, 3, 3, 3, 3, 3, 3, 2, 3, 0],
	[0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 0],
	[0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0]
];

def genrerate_mif():
	output = "WIDTH=3;\n"
	output += "DEPTH=512;\n"
	output += "\n"
	output += "ADDRESS_RADIX=BIN;\n"
	output += "DATA_RADIX=BIN;\n"
	output += "\n"

	output += "CONTENT BEGIN\n"
	cur_address = 0;
	for i in range(0, 21):
		for j in range(0, 21):
			type_binary = '{0:03b}'.format(map[i][j])
			address_binary = '{0:09b}'.format(cur_address)
			output += "\t" + str(address_binary) + "\t : \t" + str(type_binary) + ";\n";
			cur_address += 1

	output += "END;\n"


	text_file = open("MapData.mif", "w")
	text_file.write(output)
	text_file.close()


def run_verlog():
	output = "reg [8:0] next_state\n"
	output += "always @(*)\n"
	output += "begin\n"
	output += "\tif(reset_n == 1'b1)\n"
	output += "\tbegin\n"

	cur_address = 0;
	cur_ifstatement = 0
	for i in range(0, 21):
		for j in range(0, 21):
			type_binary = '{0:03b}'.format(map[i][j])

			if cur_ifstatement == 0:
				output += "\t\tif(cur_reset_state == 8'd" + str(cur_ifstatement) + ")\n"
			else:
				output += "\t\telse if(cur_reset_state == 8'd" + str(cur_ifstatement) + ")\n"

			output += "\t\tbegin\n"
			output += "\t\t\tcur_reset_address = 8'd" + str(cur_address) + ";\n"
			output += "\t\t\tcur_reset_type = 3'b" + str(type_binary) + ";\n"
			output += "\t\t\tnext_reset_state = cur_reset_state + 1;\n"
			output += "\t\tend\n"

			cur_address += 1
			cur_ifstatement += 1
			

	output += "\tend\n"
	output += "end\n"
	output += "\n"
	output += "always @(posedge clock_50)\n"
	output += "begin\n"

	output += "\tif(reset_n == 1'b1)\n"
	output += "\tbegin\n"
	output += "\t\tcur_reset_state <= next_reset_state;\n"
	output += "\tend\n"

	output += "\telse\n"
	output += "\tbegin\n"
	output += "\t\tcur_reset_state <= 8'd0;\n"
	output += "\t\tnext_reset_state <= 8'd0;\n"
	output += "\tend\n"

	output += "end\n"


	text_file = open("Output.txt", "w")
	text_file.write(output)
	text_file.close()


genrerate_mif()