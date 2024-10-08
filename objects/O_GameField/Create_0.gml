global.cell_click_callback = undefined;
global.selected_cell = "";
global.able_to_summon = false;
global.moving_figure = false;
global.using_ability = false;
global.figure_to_summon = undefined;
global.input = true;
global.map = "map1";

cell_click_action = undefined;

set_cell_click_action = function(_action) {
	cell_click_action = _action;
}
clear_cell_click_action = function() {
	set_cell_click_action(undefined);
}
execute_cell_click_action = function(cell_obj) {
	if (cell_click_action == undefined)
		return;
		
	cell_click_action(cell_obj);
}

h = 6;
w = 6;
size = 90
depth = 1;
image_xscale = 0.25399;
image_yscale = 0.25399;

generate_new_game_field = function(w, h, cell_size) {
	for (i = 0; i < h; i++) {
	for (m = 0; m < w; m++) {
		field[i][m] = instance_create_depth(self.x+size/2+m*size, self.y+size/2+i*size, -1, O_GF_Square);
		field[i][m].xcord = m;
		field[i][m].ycord = i;
		}
	}
	
	/*instance_create_depth(0, 0, 0, O_App)
	instance_create_depth(0, 0, 0, O_Figures_counter)
	instance_create_depth(0, 0, 0, O_Turn_timer);
	instance_create_depth(0, 0, 0, O_GameLoopController);
	instance_create_depth(1084, 1169, 0, O_EndTurn);
	instance_create_depth(596, 1169, 0, O_CancelButton);
	instance_create_depth(840, 1169, 0, O_SummonButton);*/
	player1_dropped = instance_create_depth(526, 574, 0, O_DroppedFigurePlace);
	player2_dropped = instance_create_depth(526, 480, 0, O_DroppedFigurePlace);
	player1_captured = instance_create_depth(1146, 574, 0, O_CapturedFigurePlace);
	player2_captured = instance_create_depth(1146, 480, 0, O_CapturedFigurePlace);
	player2_dropped.facing = -1;
	player2_captured.facing = -1;
	card_x = 560;
	
	for (i = 0; i < array_length(Player_figure_list.player_figure_list); i++) {
		new_card = instance_create_depth(card_x, 890, 0, O_Card_display);
		new_card.set_sprite(Behaviours.get_figure_card(Player_figure_list.player_figure_list[i]))
		card_x += (700 / array_length(Player_figure_list.player_figure_list))
	}
}

generate_new_game_field(w, h, size);
O_Figures_counter.update_turn()

check_clear_move_cells = function(xcord, ycord) {
	for (i = -1; i <= 1; i++) {
		for (m = -1; m <= 1; m++) {
			try {
				cell = field[ycord+m][xcord+i]
				if !cell.is_filled() {
					cell.marked = true;
				}
			}
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
				if cell.is_under_control(O_GameLoopController.get_opponent(player)){
					cell.marked = 0
				}
				if cell.is_under_control(player) and cell.is_under_control(O_GameLoopController.get_opponent(player)) {
					if ((cell.xcord = 2 or cell.xcord = 3) and (cell.ycord = 2 or cell.ycord = 3)) {
						cell.marked = 1;
					}
				}
				if is_on_player_side and ((cell.xcord = 2 or cell.xcord = 3) and (cell.ycord = 2 or cell.ycord = 3)) {
					cell.marked = 1;
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

is_any_cell_marked = function() {
	for (i = 0; i < w; i++) {
		for (m = 0; m < h; m++) {
			if get_cell(m, i).marked {
				return true
			}
		}
	}
	return false
}

get_place = function(type, player) {
	if type = "drop" {
		if player = "player1" {
			return player1_dropped;
		}
		else {
			return player2_dropped;
		}
	}
	if type = "capture" {
		if player = "player1" {
			return player1_captured;
		}
		else {
			return player2_captured;
		}
	}
}

check_every_figure = function() {
	for (i = 0; i < w; i++) {
		for (m = 0; m < h; m++) {
			if get_cell(m, i).is_filled() {
				get_cell(m, i).update_filled_figure_state();
			}
		}
	}
}

get_filled_cells = function(player) {
	cells = [];
	for (i = 0; i < w; i++) {
		for (m = 0; m < h; m++) {
			cell = get_cell(m, i)
			if cell.is_filled() and cell.filled_figure.owner = player{
				array_push(cells, cell);
			}
		}
	}
	return cells
}

Maps_list.start(global.map);