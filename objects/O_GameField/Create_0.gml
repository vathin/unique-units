global.able_to_summon = false;
global.moving_figure = false;
global.chosen_figure = "";
global.selected_cell = "";
global.figure_to_summon = "warrior";
cell_for_move = ""

h = 6;
w = 6;
size = 90

generate_new_game_field = function(w, h, cell_size) {
for (i = 0; i < h; i++) {
	for (m = 0; m < w; m++) {
		field[i][m] = instance_create_depth(self.x+size/2+m*size, self.y+size/2+i*size, -1, O_GF_Square);
		field[i][m].xcord = i;
		field[i][m].ycord = m;
		}
	}
}
instance_create_depth(0, 0, 0, O_GameLoopController);
generate_new_game_field(w, h, size);

figure_place_set = function(new_x, new_y) {
	if (cell_for_move = "") {
		cell_for_move = field[new_x][new_y]
		cell_for_move.ready_for_move = 1
	}
	else {
		cell_for_move.ready_for_move = 0;
		cell_for_move = field[new_x][new_y]
		cell_for_move.ready_for_move = 1
	}
}
move_figure = function(from_x, from_y, to_x, to_y, figure_type) {
	new_sq = field[to_x][to_y];
	field[from_x][from_y].clear();
	new_sq.filled_figure = figure_type;
	new_sq.filled = 1;
	figure_type.x = new_sq.x;
	figure_type.y = new_sq.y;
	
}


check_clear_move_cells = function(xcord, ycord) {
	for (i = -1; i <= 1; i++) {
		for (m = -1; m <= 1; m++) {
			try {
				cell = field[xcord+m][ycord+i]
				if !cell.is_filled() {
					cell.marked_for_move = true;
				}}
		
			catch(_exception) {
				
			}
		}
	}
}


clear_all_marks = function() {
	for (i = 0; i < h; i++) {
		for (m = 0; m < w; m++) {
			field[i][m].marked_for_move = false;
			field[i][m].ready_for_move = false;
		}
	}
}