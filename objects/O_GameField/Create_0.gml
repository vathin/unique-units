global.able_to_summon = false;
global.moving_figure = false;
global.selected_cell = "";
global.figure_to_summon = "warrior";
cell_for_move = ""

h = 6;
w = 6;
size = 90
depth = 1;

generate_new_game_field = function(w, h, cell_size) {
for (i = 0; i < h; i++) {
	for (m = 0; m < w; m++) {
		field[i][m] = instance_create_depth(self.x+size/2+m*size, self.y+size/2+i*size, -1, O_GF_Square);
		field[i][m].xcord = m;
		field[i][m].ycord = i;
		}
	}
}
instance_create_depth(0, 0, 0, O_GameLoopController);
generate_new_game_field(w, h, size);

check_clear_move_cells = function(xcord, ycord) {
	for (i = -1; i <= 1; i++) {
		for (m = -1; m <= 1; m++) {
			try {
				cell = field[ycord+m][xcord+i]
				if !cell.is_filled() {
					cell.marked = true;
				}}
		
			catch(_exception) {
			}
		}
	}
}

check_controlled_summon_cells = function(player){
	for (i = 0; i < h; i++) {
		for (m = 0; m < w; m++) {
			cell = field[m][i]
			if !cell.is_filled() {
				if m > 2  {
					cell.marked = 1
				}
				if cell.is_under_control(player) {
					cell.marked = 1
				}
				
			}
		}
	}
}


clear_all_marks = function() {
	for (i = 0; i < h; i++) {
		for (m = 0; m < w; m++) {
			field[i][m].marked = false;
		}
	}
}

get_cell = function(xcord, ycord) {
	if xcord >= 0 and xcord < w and ycord >= 0 and ycord < h{
		return field[ycord][xcord];
	}
	else {
		return undefined
	}
}

cell_get_neightbors = function(cell) {
	neightbors = [];
	if (get_cell(cell.xcord -1, cell.ycord) != undefined) {
		array_push(neightbors, get_cell(cell.xcord -1, cell.ycord))
	}
	if (get_cell(cell.xcord +1, cell.ycord) != undefined) {
		array_push(neightbors, get_cell(cell.xcord +1, cell.ycord))
	}
	if (get_cell(cell.xcord , cell.ycord -1) != undefined) {
		array_push(neightbors, get_cell(cell.xcord , cell.ycord -1))
	}
	if (get_cell(cell.xcord , cell.ycord +1) != undefined) {
		array_push(neightbors, get_cell(cell.xcord , cell.ycord +1))
	}
	show_debug_message(neightbors)
	return neightbors
}