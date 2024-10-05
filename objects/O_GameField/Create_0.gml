global.cell_click_callback = undefined;
global.selected_cell = undefined;
global.able_to_summon = false;
global.moving_figure = false;
global.using_ability = false;
global.figure_to_summon = undefined;
global.map = "map1";
global.input = 1;

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

field_height = 6;
field_width = 6;
size = 90
depth = 1;
standart_scale = 0.25399;
image_xscale = standart_scale;
image_yscale = standart_scale;

generate_new_game_field = function(w, h, cell_size) {
	for (i = 0; i < field_height; i++) {
	for (m = 0; m < field_width; m++) {
		field[i][m] = instance_create_depth(self.x-(sprite_width/2)+size/2+m*size, self.y-(sprite_width/2)+size/2+i*size, -1, O_GF_Square);
		field[i][m].xcord = m;
		field[i][m].ycord = i;
		}
	}
	
	player1_dropped = instance_create_depth(526, 574, 0, O_DroppedFigurePlace);
	player2_dropped = instance_create_depth(526, 480, 0, O_DroppedFigurePlace);
	player1_captured = instance_create_depth(1146, 574, 0, O_CapturedFigurePlace);
	player2_captured = instance_create_depth(1146, 480, 0, O_CapturedFigurePlace);
	player2_dropped.facing = -1;
	player2_captured.facing = -1;
	
	generate_cards();
}

generate_cards = function() {
	card_x = 560;
	for (i = 0; i < array_length(Player_figure_list.player_figure_list); i++) {
		new_card = instance_create_depth(card_x, 890, 0, O_Card_display);
		new_card.set_sprite(Behaviours.get_figure_card(Player_figure_list.player_figure_list[i]));
		card_x += (700 / array_length(Player_figure_list.player_figure_list));
	}
}
get_cell = function(xcord, ycord) {
	if xcord >= 0 and xcord < field_width and ycord >= 0 and ycord < field_height{
		return field[ycord][xcord];
	}
	else {
		return undefined
	}
}

generate_new_game_field(field_width, field_height, size);
O_Figures_counter.update_turn()

check_clear_move_cells = function(xcord, ycord) {
	for (i = -1; i <= 1; i++) {
		for (m = -1; m <= 1; m++) {
			try {
				cell = get_cell(xcord + i, ycord + m);
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
	for (i = 0; i < field_height; i++) {
		for (m = 0; m < field_width; m++) {
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
	for (i = 0; i < field_height; i++) {
		for (m = 0; m < field_width; m++) {
			field[i][m].marked = false;
			field[i][m].set_draw_marks(1);
		}
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
	for (i = 0; i < field_width; i++) {
		for (m = 0; m < field_height; m++) {
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
	for (i = 0; i < field_width; i++) {
		for (m = 0; m < field_height; m++) {
			if get_cell(m, i).is_filled() {
				get_cell(m, i).update_filled_figure_state();
			}
		}
	}
}

get_filled_cells = function(player) {
	cells = [];
	for (i = 0; i < field_width; i++) {
		for (m = 0; m < field_height; m++) {
			cell = get_cell(m, i)
			if cell.is_filled() and cell.filled_figure.owner = player{
				array_push(cells, cell);
			}
		}
	}
	return cells
}

export_cell = function(cell_x, cell_y) {
	cell = get_cell(cell_x, cell_y);
	return cell.export()
}

export = function() {
	for (i = 0; i < field_width; i++) {
		for (m = 0; m < field_height; m++) {
			export_cells[m][i] = get_cell(m, i).export();
		}
	}
	export_data = {
		ex_cells: export_cells,
		ex_player1_dropped: player1_dropped.export(),
		ex_player2_dropped: player2_dropped.export(),
		ex_player1_captured: player1_captured.export(),
		ex_player2_captured: player2_captured.export(),
		ex_map: global.map,
	}
	return export_data
}

import = function(import_data) {
	for (i = 0; i < field_width; i++) {
		for (m = 0; m < field_height; m++) {
			get_cell(m, i).import(import_data.ex_cells[m][i]);
		}
	}
	player1_dropped.import(import_data.ex_player1_dropped);
	player2_dropped.import(import_data.ex_player2_dropped);
	player1_captured.import(import_data.ex_player1_captured);
	player2_captured.import(import_data.ex_player2_captured);
	global.map = import_data.ex_map;
}

Maps_list.start(global.map);