
# 9 represents valid pacman and ghost positions; 8 means valid for only ghost positions; 
# 7 means only pacman
# 1 means invalid for both pacman and the ghost.
map = [
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], 
	[1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1],
	[1, 1, 9, 1, 1, 9, 1, 1, 1, 9, 1, 9, 1, 1, 1, 9, 1, 1, 9, 1, 1],
	[1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1],
	[1, 1, 9, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 9, 1, 1],
	[1, 1, 9, 9, 9, 9, 1, 9, 9, 9, 1, 9, 9, 9, 1, 9, 9, 9, 9, 1, 1],
	[1, 1, 1, 1, 1, 9, 1, 1, 1, 9, 1, 9, 1, 1, 1, 9, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 9, 1, 9, 9, 9, 9, 9, 9, 9, 1, 9, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 8, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1],
	[7, 9, 9, 9, 9, 9, 9, 9, 1, 1, 8, 1, 1, 9, 9, 9, 9, 9, 9, 9, 7],
	[1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 9, 1, 9, 9, 9, 9, 9, 9, 9, 1, 9, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1],
	[1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1],
	[1, 1, 9, 1, 1, 9, 1, 1, 1, 9, 1, 9, 1, 1, 1, 9, 1, 1, 9, 1, 1],
	[1, 1, 9, 9, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 9, 9, 1, 1],
	[1, 1, 1, 9, 1, 9, 1, 9, 1, 1, 1, 1, 1, 9, 1, 9, 1, 9, 1, 1, 1],
	[1, 1, 9, 9, 9, 9, 1, 9, 9, 9, 1, 9, 9, 9, 1, 9, 9, 9, 9, 1, 1],
	[1, 1, 9, 1, 1, 1, 1, 1, 1, 9, 1, 9, 1, 1, 1, 1, 1, 1, 9, 1, 1],
	[1, 1, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
];

valid_positions = []
num_searches = 0

class Queue:
    def __init__(self):
        self.items = []

    def isEmpty(self):
        return self.items == []

    def enqueue(self, item):
        self.items.insert(0,item)

    def dequeue(self):
        return self.items.pop()

    def size(self):
        return len(self.items)

def bfs_generator(ghost_position, pacman_position):
	global valid_positions

	# In python, the "x" are the rows, and the "y" are the columns
	visited_coords = [
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0], 
		[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
		[0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0],
		[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
		[0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0],
		[0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0],
		[0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0],
		[0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0],
		[1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 4, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
		[1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 4, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1],
		[0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0],
		[0, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 0],
		[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
		[0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 0],
		[0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0],
		[0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0],
		[0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0],
		[0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0],
		[0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]
	];

	queue = Queue()
	queue.enqueue(ghost_position)
	parent = {}
	parent[ghost_position] = None

	# Make a BFS tree
	while not queue.isEmpty():
		cur_pos = queue.dequeue()
		visited_coords[cur_pos[0]][cur_pos[1]] = 1

		if cur_pos == pacman_position:
			break

		for dx in range(-1, 2, 1):
			for dy in range(-1, 2, 1):
				if dx != 0 and dy != 0:
					continue
				next_x = cur_pos[0] + dx
				next_y = cur_pos[1] + dy

				if next_x < 0 or next_x > 20:
					continue
				if next_y < 0 or next_y > 20:
					continue

				if visited_coords[next_x][next_y] != 1:
					queue.enqueue((next_x, next_y))
					parent[(next_x, next_y)] = cur_pos
					visited_coords[next_x][next_y] = 1

	# Go back to the parent from the pacman position
	cur_position = pacman_position;
	while parent[cur_position] != ghost_position:
		cur_position = parent[cur_position]

	# Determine what direction to take
	next_direction = (cur_position[0] - ghost_position[0], cur_position[1] - ghost_position[1])
	valid_positions.append((ghost_position, pacman_position, next_direction))

def is_far(ghost_position, pacman_position):
	next_direction = (pacman_position[0] - ghost_position[0], pacman_position[1] - ghost_position[1])
	if abs(next_direction[0]) == 1 and abs(next_direction[1]) == 0:
		return False
	elif abs(next_direction[0]) == 0 and abs(next_direction[1]) == 1:
		return False
	return True

def generate_bfs_tree(pacman_position, ghost_position):
	global num_searches

	if map[pacman_position[0]][pacman_position[1]] != 9:
		if map[pacman_position[0]][pacman_position[1]] != 7:
			return

	if map[ghost_position[0]][ghost_position[1]] != 9:
		if map[ghost_position[0]][ghost_position[1]] != 8:
			return

	if pacman_position == ghost_position:
		return

	if is_far(ghost_position, pacman_position) == False:
		return

	bfs_generator(ghost_position, pacman_position)
	num_searches += 1

def output_to_mif_file():
	global valid_positions
	max_index = 655365

	output = "WIDTH=3;\n"
	output += "DEPTH=512;\n"
	output += "\n"
	output += "ADDRESS_RADIX=BIN;\n"
	output += "DATA_RADIX=BIN;\n"
	output += "\n"

	output += "CONTENT BEGIN\n"

	for result in valid_positions:
		ghost_position = result[0]
		pacman_position = result[1]
		ghost_direction = result[2]

		ghost_position_binary = '{0:08b}'.format(ghost_position[0] * 21 + ghost_position[1])
		pacman_position_binary = '{0:08b}'.format(pacman_position[0] * 21 + pacman_position[1])
		ghost_direction_binary = "00"

		if ghost_direction[0] != 0:
			if ghost_direction[1] == -1:
				ghost_direction_binary = "00"
			else:
				ghost_direction_binary = "01"
		else:
			if ghost_direction[0] == -1:
				ghost_direction_binary = "10"
			else:
				ghost_direction_binary = "11"

		output += "\t" + str(ghost_position_binary) + str(pacman_position_binary) + "\t : \t" + str(ghost_direction_binary) + ";\n";

	output += "END;\n"

	text_file = open("BFSTreeData.mif", "w")
	text_file.write(output)
	text_file.close()


def main():
	global num_searches, valid_positions
	for i in range(0, 21):
		for j in range(0, 21):
			for k in range(0, 21):
				for l in range(0, 21):
					pacman_position = (i, j)
					ghost_position = (k, l)
					generate_bfs_tree(ghost_position, pacman_position)

	output_to_mif_file()

main()




