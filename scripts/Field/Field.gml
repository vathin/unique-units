// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Field() constructor{
	field_height = 6;
	field_width = 6;
	scale = 0.75;
	size = 80*scale;
	map_sprite = Maps_list.get_map_sprite(global.map);
	map_scale = size*field_width/2126; //0,1467545
	start_x = (room_width/2) - size*2.5;
	start_y = (room_height/2) - size*3;
	field_x_size = size*field_width;
	field_y_size = size*field_width;
	selected_cell = undefined;
	player1_captured = new CapturedFiguresCounter(Game.Player1.player_id);
	player2_captured = new CapturedFiguresCounter(Game.Player2.player_id);
	player1_dropped = new DroppedFiguresCounter(Game.Player1.player_id);
	player2_dropped = new DroppedFiguresCounter(Game.Player2.player_id);
	movement_array = [];
	
	set_selected_cell = function(cell) {
		selected_cell = cell
	}
	
	create_figure = function(_behaviour, _xcord, _ycord, _is_figure_new, _owner = global.turn_owner) {
		new_figure = new Figure()
		new_figure.set_behaviour(_behaviour);
		new_figure.owner = _owner;
		Game.field.get_cell(_xcord, _ycord).fill(new_figure);
		if _is_figure_new {
			new_figure.figure_id = Game.game_loop_controller.figures_counter.get_figure_id();
			//Game.game_loop_controller.figures_counter.change_field_figures_amount(_owner, 1);
		}
	}
	
	find_figure_from_id = function(_id) {
		for (var h = 0; h < field_height; h++) 
		{
			for (var w = 0; w < field_width; w++) 
			{
				if cell_array[h][w].is_filled() {
					if cell_array[h][w].filled_figure.figure_id == _id {
						return cell_array[h][w].filled_figure
					}
				}
			}
		}
		return undefined
	}
	
	cell_array = []
	for (i = 0; i < field_height; i++) {
		for (m = 0; m < field_width; m++) {
			cell_array[i][m] = new Cell()
			cell_array[i][m].set_coordinates(m, i)
		}
	}
	update_cords = function() {
		start_x = (room_width/2) - size*2.5;
		start_y = (room_height/2) - size*3;
	}
	
	TEST_draw_cells = function() {
		draw_sprite_ext(map_sprite, 0, room_width/2, room_height/2-size/2, map_scale, map_scale, 0, c_white, 1);
		up_figures = [];
		for (var h = 0; h < field_height; h++) 
		{
			for (var w = 0; w < field_width; w++) 
			{
				//draw_sprite_ext(S_square, 0, start_x + size*w, start_y + size*h, scale, scale, 0, c_white, 1)
				if (cell_array[h][w].is_filled()) {
					draw_cell = cell_array[h][w]
					draw_figure = draw_cell.filled_figure;
					if draw_figure.have_animation() {
						//draw_figure.animate();
						array_push(up_figures, draw_figure)
					}
					else {
						draw_sprite_ext(Behaviours.get_sprite(draw_figure.behaviour), draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
						draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, draw_figure.draw_alpha);
						if draw_figure.state.is_conquesting {
							var _draw_alpha = 1
							if mouse_check_button(mb_left) and get_cell_from_coordinates(mouse_x, mouse_y) == draw_cell {_draw_alpha = 0.3}
							draw_sprite_ext(S_Conquesting, draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
							draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, _draw_alpha);
						}
					}
					
				}
				if (cell_array[h][w].is_marked() and cell_array[h][w].draw_mark == 1) {
					draw_sprite_ext(global.mark, 0, start_x + size*w, start_y + size*h, 0.6, 0.6, 0, c_white, 1)
				}
			}
		}
		other_figures = []
		for (i = 0; i < array_length(player1_dropped.figures); i++) {
			array_push(other_figures, player1_dropped.figures[i]);
		}
		for (i = 0; i < array_length(Game.field.player2_dropped.figures); i++) {
			array_push(other_figures, player2_dropped.figures[i]);
		}
		for (i = 0; i < array_length(Game.field.player1_captured.figures); i++) {
			array_push(other_figures, player1_captured.figures[i]);
		}
		for (i = 0; i < array_length(Game.field.player2_captured.figures); i++) {
			array_push(other_figures, player2_captured.figures[i]);
		} 
		for (i = 0; i < array_length(other_figures); i++) {
			draw_figure = other_figures[i]
			if draw_figure.have_animation() {
				//draw_figure.animate()
				array_push(up_figures, draw_figure)
			}
			else {
				draw_sprite_ext(Behaviours.get_sprite(draw_figure.behaviour), draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
				draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, draw_figure.draw_alpha);
				if (draw_figure.state.is_captured and draw_figure.owner == O_LoginController._id){
					var _draw_alpha = 1
					draw_sprite_ext(S_Conquesting, draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
					draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, _draw_alpha);
				}
			}
		}
		for (i = 0; i < array_length(up_figures); i++) {
			draw_figure = up_figures[i];
			draw_sprite_ext(Behaviours.get_sprite(draw_figure.behaviour), draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
			draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, draw_figure.draw_alpha);
			if draw_figure.state.is_conquesting and draw_figure.have_animation() 
			and draw_figure.get_current_animation_controller().anim_type == "overturn"{
				controller = draw_figure.get_current_animation_controller();
				if controller.draw_spr_2 {
					var _draw_alpha = 1
					draw_sprite_ext(S_Conquesting, draw_figure.image, draw_figure.draw_x, draw_figure.draw_y, 
					draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, _draw_alpha);
				}
			}
			if draw_figure.have_animation() {draw_figure.animate()}
		}
	}
	array_push(Game.do_every_step_list, TEST_draw_cells)
	
	get_cell_xy = function(cell) {
		return [start_x + size*cell.xcord, start_y + size*cell.ycord]
	}
	
	get_cell_from_coordinates = function(check_x, check_y) {
		xcord = (check_x - (start_x - size/2)) / size
		ycord = (check_y - (start_y - size/2)) / size
		if xcord > 0 and xcord < field_width and ycord > 0 and ycord < field_height {
				return get_cell((check_x - (start_x - size/2)) / size, (check_y - (start_y - size/2)) / size)
			}
		else return undefined
	
	}
	check_click = function() {
		return get_cell_from_coordinates(mouse_x, mouse_y)
	}
	
	get_cell = function(xcord, ycord) {
		if xcord >= 0 and xcord < field_width and ycord >= 0 and ycord < field_height{
			return cell_array[ycord][xcord];
		}
		else {
			return undefined
		}
	}

	place_figure = function(_xcord, _ycord, _behaviour ){
		cell = get_cell(_xcord, _ycord)
		cell.fill(new Figure())
		cell.filled_figure.set_behaviour(_behaviour)
	}

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
					if player = Game.Player1.player_id {
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
					if cell.is_under_control(Game.game_loop_controller.get_opponent(player)){
						cell.marked = 0
					}
					if cell.is_under_control(player) and cell.is_under_control(Game.game_loop_controller.get_opponent(player)) {
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
	
	check_if_any_cell_conquested = function() {
		_player1 = Maps_list.get_cells_for_conquest()[0]
		_player2 = Maps_list.get_cells_for_conquest()[1]
		for (i = 0; i < array_length(_player1); i++) {
			cell = get_cell(_player1[i][0], _player1[i][1])
			if cell.is_filled() {
				var _figure = cell.filled_figure
				if _figure.owner == Game.Player2.player_id and _figure.state.is_active {
					figure_animation = new OverturnAnimationController();
					figure_animation.start_animation(_figure.draw_x, _figure.draw_y, _figure.draw_x, _figure.draw_y, 30);
					_figure.add_animation(figure_animation)
					_figure.conquest();
					Game.game_loop_controller.add_captured_figure(Game.Player2.player_id);
				}
			}
		}
		for (i = 0; i < array_length(_player2); i++) {
			cell = get_cell(_player2[i][0], _player2[i][1])
			if cell.is_filled() {
				var _figure = cell.filled_figure
				if _figure.owner == Game.Player1.player_id and _figure.state.is_active {
					figure_animation = new OverturnAnimationController();
					figure_animation.start_animation(_figure.draw_x, _figure.draw_y, _figure.draw_x, _figure.draw_y, 30);
					_figure.add_animation(figure_animation)
					_figure.conquest();
					Game.game_loop_controller.add_captured_figure(Game.Player1.player_id);
				}
			}
		}
	}


	clear_all_marks = function() {
		for (i = 0; i < field_height; i++) {
			for (m = 0; m < field_width; m++) {
				cell_array[i][m].marked = false;
				cell_array[i][m].set_draw_marks(1);
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
		return neightbors
	}

	is_any_cell_marked = function() {
		for (i = 0; i < field_width; i++) {
			for (m = 0; m < field_height; m++) {
				if get_cell(m, i).is_marked() {
					return true
				}
			}
		}
		return false
	}

	get_place = function(type, player) {
		show_debug_message("0")
		if type = "drop" {
			if player = Game.Player1.player_id {
				return player1_dropped;
			}
			else {
				return player2_dropped;
			}
		}
		if type = "capture" {
			if player = Game.Player1.player_id {
				show_debug_message("1");
				return player1_captured;
			}
			else {
				show_debug_message("1");
				return player2_captured;
			}
		}
	}

	check_every_figure = function() {
		for (i = 0; i < field_width; i++) {
			for (m = 0; m < field_height; m++) {
				if get_cell(m, i).is_filled() {
					get_cell(m, i).update_filled_figure_state();
					if get_cell(m, i).filled_figure.state.is_dropped {get_cell(m, i).clear()}
				}
			}
		}
	}
	
	get_player_field_figures = function(_owner) {
		field_figures = []
		for (i = 0; i < field_width; i++) {
			for (m = 0; m < field_height; m++) {
				cell = get_cell(m, i);
				if cell.is_filled() and cell.filled_figure.owner == _owner {
					array_push(field_figures, cell.filled_figure)
				}
			}
		}
		return field_figures
	}
	
	get_active_player_field_figures = function(_owner) {
		figures = get_player_field_figures(_owner);
		active_figures = [];
		for (i = 0; i < array_length(figures); i++) {
			if figures[i].state.is_active {
				array_push(active_figures, figures[i]);
			}
		}
		return active_figures
	}

	get_filled_cells = function(_player) {
		cells = [];
		for (i = 0; i < field_width; i++) {
			for (m = 0; m < field_height; m++) {
				cell = get_cell(m, i)
				if cell.is_filled() and cell.filled_figure.owner == _player{
					array_push(cells, cell);
				}
			}
		}
		return cells
	}
	
	add_movement = function(cell_from, cell_to, _figure_id, _is_ability = 0) {
		array_push(movement_array, {from: [cell_from.xcord, cell_from.ycord], to: [cell_to.xcord, cell_to.ycord], figure_id: _figure_id, is_ability: _is_ability})
	}
	
	check_movement_array = function(_figure_id) {
		for (i = array_length(movement_array)-1; i >= 0; i--) {
			if movement_array[i].figure_id == _figure_id and movement_array[i].is_ability and array_length(movement_array) - i < 3{
				return get_cell(movement_array[i].from[0], movement_array[i].from[1])
			}
		}
		return undefined
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
	
}
