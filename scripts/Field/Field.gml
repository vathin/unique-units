// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Field() constructor{
	
	field_height = 6;
	field_width = 6;
	scale = 0.7
	size = 90*scale
	start_x = (room_width/2) - size*3
	start_y = (room_height/2) - size*3
	
	cell_array = []
	for (i = 0; i < field_height; i++) {
		for (m = 0; m < field_width; m++) {
			cell_array[i][m] = new Cell()
			cell_array[i][m].set_coordinates(m, i)
		}
	}
	
	TEST_draw_cells = function() {
		for (var h = 0; h < field_height; h++) 
		{
			for (var w = 0; w < field_width; w++) 
			{
				draw_sprite_ext(S_square, 0, start_x + size*w, start_y + size*h, scale, scale, 0, c_white, 1)
				if (cell_array[h][w].is_filled()) {
					draw_text(start_x + cell_array[h][w].get_coordinates()[0]*90, start_y + cell_array[h][w].get_coordinates()[1]*90, cell_array[h][w].filled_figure.behaviour.index[1, 2])
				}
			}
		}
	} 
	array_push(Game.do_every_step_list, self.TEST_draw_cells())
	
	/*generate_new_game_field = function(w, h, cell_size) {
		player2_dropped.facing = -1;
		player2_captured.facing = -1;
	
	}*/

	get_cell = function(xcord, ycord) {
		if xcord >= 0 and xcord < field_width and ycord >= 0 and ycord < field_height{
			return cell_array[ycord][xcord];
		}
		else {
			return undefined
		}
	}

	//generate_new_game_field(field_width, field_height, size);

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
				cell = cell_array[m][i]
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
	
	create_figure = function(figure_behaviour, cell) 
	{
		filled_figure = instance_create_depth(cell.x, cell.y, -1, O_Figure);
		filled_figure.set_behaviour(figure_behaviour);
		O_Figures_counter.change_field_figures_amount(global.turn_owner, +1);
	}
}