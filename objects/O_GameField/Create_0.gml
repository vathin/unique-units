global.cell_click_callback = undefined;
global.selected_cell = "";
global.able_to_summon = false;
global.moving_figure = false;
global.figure_to_summon = undefined;
global.cell_action = function(cell) {
	if (cell.is_filled() and cell.filled_figure.able_to_move) and
	cell.filled_figure.owner = global.turn_owner {
		global.cell_click_callback = cell;
		global.selected_cell = cell;
		cell.filled_figure.click();
	}
} 
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
	instance_create_depth(0, 0, 0, O_GameLoopController);
	instance_create_depth(1178, 1169, 0, O_EndTurn);
	instance_create_depth(502, 1169, 0, O_CancelButton);
}

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
	var is_on_player_side
	for (i = 0; i < h; i++) {
		for (m = 0; m < w; m++) {
			cell = field[m][i]
			if !cell.is_filled() {
				if player = "player1" {
					if m > 2 {
						is_on_player_side = 1
					}
					else {
						is_on_player_side = 0
					}
				}
				else {
					if m <= 2 {
						is_on_player_side = 1
					}
					else {
						is_on_player_side = 0
					}
				}
				if is_on_player_side or cell.is_under_control(player){
					cell.marked = 1
				}
				if cell.is_under_control(O_GameLoopController.get_opponent(player)) {
					cell.marked = 0
				}
			}
		}
	}
}


clear_all_marks = function() {
	for (i = 0; i < h; i++) {
		for (m = 0; m < w; m++) {
			field[i][m].marked = false;
			field[i][m].set_draw_marks(1);
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