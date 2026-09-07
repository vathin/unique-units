// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Field() constructor{
	gui_base_width = room_width;
	gui_base_height = room_height;
	gui_width = display_get_gui_width();
	gui_height = display_get_gui_height();
	field_height = 6;
	field_width = 6;
	scale = 0.7;
	size = 80*scale*(gui_height/max(1, gui_base_height));
	map_sprite = Maps_list.get_map_sprite(global.map);
	map_scale = size*field_width/2126; //0,1467545
	start_x = gui_width/2 - size*2.5;
	start_y = gui_height/2 - size*3;
	field_x_size = size*field_width;
	field_y_size = size*field_width;
	selected_cell = undefined;
	player1_captured = new CapturedFiguresCounter(Game.Player1.player_id);
	player2_captured = new CapturedFiguresCounter(Game.Player2.player_id);
	player1_dropped = new DroppedFiguresCounter(Game.Player1.player_id);
	player2_dropped = new DroppedFiguresCounter(Game.Player2.player_id);
	movement_array = [];

	field_cord = {
		top: start_y,
		bottom: start_y + size*field_height,
		left: start_x,
		right: start_x + size*field_width,
		x_center: start_x + size*field_width/2,
		y_center: start_y + size*field_height/2
	}

	status_draw_offsets = [[0, 0], [-10, 0, 10, 0], [-10, -10, 10, -10, 0, 10], [-10, -10, -10, 10, 10, -10, 10, 10]]

	if Game.role == "host" {
		player2_captured.set_position(2);
		player2_dropped.set_position(2);
	}
	else {
		player1_captured.set_position(2);
		player1_dropped.set_position(2);
	}

	set_selected_cell = function(cell) {
		selected_cell = cell
	}

	create_figure = function(_behaviour, _xcord, _ycord, _is_figure_new, _owner = global.turn_owner) {
		var _cell = Game.field.get_cell(_xcord, _ycord);
		if _cell == undefined {
			show_debug_message("Field.create_figure failed: invalid cell x=" + string(_xcord) + ", y=" + string(_ycord) + ", behaviour=" + string(_behaviour));
			return undefined;
		}
		new_figure = new Figure()
		new_figure.set_behaviour(_behaviour);
		new_figure.owner = _owner;
		new_figure.draw_xscale = get_figure_scale();
		new_figure.draw_yscale = get_figure_scale();
		_cell.fill(new_figure);
		if _is_figure_new {
			new_figure.figure_id = Game.game_loop_controller.figures_counter.get_figure_id();
			//Game.game_loop_controller.figures_counter.change_field_figures_amount(_owner, 1);
		}
		return new_figure;
	}

	find_figure_from_id = function(_id) {
		for (var h = 0; h < field_height; h++)
		{
			for (var w = 0; w < field_width; w++)
			{
				if get_cell(w, h).is_filled() {
					if get_cell(w, h).filled_figure.figure_id == _id {
						return get_cell(w, h).filled_figure;
					}
				}
			}
		}
		return undefined
	}

	cell_array = []
	for (i = 0; i < field_height; i++) {
		for (m = 0; m < field_width; m++) {
			cell_array[i][m] = new Cell();
			cell_array[i][m].set_coordinates(m, i);
			if Game.role != "host" {
				cell_array[i][m].set_coordinates(field_width - 1 - m, field_height - 1 - i);
			}
		}
	}

	update_cords = function() {
		var _old_gui_width = gui_width;
		var _old_gui_height = gui_height;
		gui_width = display_get_gui_width();
		gui_height = display_get_gui_height();
		size = 80*scale*(gui_height/max(1, gui_base_height));
		map_scale = size*field_width/2126;
		field_x_size = size*field_width;
		field_y_size = size*field_height;
		start_x = gui_width/2 - size*2.5;
		start_y = gui_height/2 - size*3;
		field_cord = {
			top: start_y,
			bottom: start_y + size*field_height,
			left: start_x,
			right: start_x + size*field_width,
			x_center: start_x + size*field_width/2,
			y_center: start_y + size*field_height/2
		}
		if _old_gui_width != gui_width or _old_gui_height != gui_height {
			player1_captured.sort(false);
			player2_captured.sort(false);
			player1_dropped.sort(false);
			player2_dropped.sort(false);
		}
	}

	get_gui_scale = function() {
		return gui_height/max(1, gui_base_height);
	}

	get_figure_scale = function() {
		return Settings.figure_scale*get_gui_scale();
	}

	TEST_draw_cells = function() {
		update_cords();
		draw_sprite_ext(map_sprite, 0, gui_width/2, gui_height/2-size/2, map_scale, map_scale, 180*(Game.role == "guest"), c_white, 1);
		up_figures = [];
		if Game.game_loop_controller.have_action() {
			Game.game_loop_controller.action.draw();
		}
		for (var h = 0; h < field_height; h++)
		{
			for (var w = 0; w < field_width; w++)
			{
				draw_cell = get_cell(w, h);
				if (get_cell(w, h).is_filled()) {
					draw_figure = draw_cell.filled_figure;
					if draw_figure.have_animation() {
						array_push(up_figures, draw_figure);
					}
					else {
						var _cell_xy = get_cell_xy(draw_cell);
						draw_figure.draw_x = _cell_xy[0];
						draw_figure.draw_y = _cell_xy[1];
						draw_figure.draw_xscale = get_figure_scale();
						draw_figure.draw_yscale = get_figure_scale();
						draw_sprite_ext(Behaviours.get_sprite(draw_figure.behaviour), draw_figure.image, draw_figure.draw_x, draw_figure.draw_y,
						draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, draw_figure.draw_alpha);
						if draw_figure.state.is_conquesting {
							var _draw_alpha = 1
							if mouse_check_button(mb_left) and check_click() == draw_cell {
								O_BoardDraw.set_button_overlay(Behaviours.get_sprite(draw_figure.behaviour),
								(draw_figure.owner == Game.opponent));
								_draw_alpha = 0.3
								}
							draw_sprite_ext(S_Conquesting, draw_figure.image, draw_figure.draw_x, draw_figure.draw_y,
							draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, _draw_alpha);
						}
					}

				}
				if (draw_cell.is_marked() and draw_cell.draw_mark == 1) {
					draw_sprite_ext(global.mark, 0, get_cell_xy(draw_cell)[0], get_cell_xy(draw_cell)[1],
					0.6*get_gui_scale(), 0.6*get_gui_scale(), 0, c_white, 1)
				}
				var _statuses = draw_cell.filled_figure_status.get_active_draw_statuses();
				var _st_amount = array_length(_statuses);
				var _scale = scale*0.8*get_gui_scale();
				if _st_amount > 1 {_scale*= 0.7}
				var _draw_num = 0;
				for (var i = 0; i < _st_amount; i++) {
					draw_sprite_ext(FigureStatusList.get_status_sprite(_statuses[i]), 0,
					get_cell_xy(draw_cell)[0] + status_draw_offsets[_st_amount-1][_draw_num], get_cell_xy(draw_cell)[1] + status_draw_offsets[_st_amount-1][_draw_num+1],
					_scale, _scale, 0, c_white, 0.9);
					_draw_num += 2;
				}
			}
		}
		other_figures = []

		for (var i = 0; i < array_length(player1_dropped.figures); i++) {
			array_push(other_figures, player1_dropped.figures[i]);
		}
		for (var i = 0; i < array_length(Game.field.player2_dropped.figures); i++) {
			array_push(other_figures, player2_dropped.figures[i]);
		}
		for (var i = 0; i < array_length(Game.field.player1_captured.figures); i++) {
			array_push(other_figures, player1_captured.figures[i]);
		}
		for (var i = 0; i < array_length(Game.field.player2_captured.figures); i++) {
			array_push(other_figures, player2_captured.figures[i]);
		}
		for (var i = 0; i < array_length(other_figures); i++) {
			draw_figure = other_figures[i]
			if draw_figure.have_animation() {
				array_push(up_figures, draw_figure)
			}
			else {
				draw_sprite_ext(Behaviours.get_sprite(draw_figure.behaviour), draw_figure.image, draw_figure.draw_x, draw_figure.draw_y,
				draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, draw_figure.draw_alpha);
				if (draw_figure.state.is_captured and Game.local_player != undefined and draw_figure.owner == Game.local_player.player_id){
					var _draw_alpha = 1
					draw_sprite_ext(S_Conquesting, draw_figure.image, draw_figure.draw_x, draw_figure.draw_y,
					draw_figure.draw_xscale, draw_figure.draw_yscale, 0, c_white, _draw_alpha);
				}
			}
		}
		for (var i = 0; i < array_length(up_figures); i++) {
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
		var _xcord = cell.xcord;
		var _ycord = cell.ycord;
		if Game.role == "guest" {
			_xcord = field_height - 1 - cell.xcord;
			_ycord = field_width - 1 - cell.ycord;
		}
		return [start_x + size*_xcord, start_y + size*_ycord];
	}

	get_cell_from_coordinates = function(check_x, check_y) {
		var xcord = floor((check_x - (start_x - size/2)) / size);
		var ycord = floor((check_y - (start_y - size/2)) / size);
		if Game.role == "guest" {
			xcord = field_height - 1 - xcord;
			ycord = field_width - 1 - ycord;
		}
		if xcord >= 0 and xcord < field_width and ycord >= 0 and ycord < field_height {
				return get_cell(xcord, ycord);
			}
		else return undefined

	}
	check_click = function() {
		return get_cell_from_coordinates(UI_controller.gui_mouse_x(), UI_controller.gui_mouse_y())
	}

	get_cell = function(_xcord, _ycord) {
		if _xcord >= 0 and _xcord < field_width and _ycord >= 0 and _ycord < field_height{
			if Game.role == "host" {
				return cell_array[_ycord][_xcord]
			}
			else {
				return cell_array[field_height - 1 - _ycord][field_width - 1 - _xcord]
			}
		}
		return undefined;
	}

	place_figure = function(_xcord, _ycord, _behaviour ){
		cell = get_cell(_xcord, _ycord)
		cell.fill(new Figure())
		cell.filled_figure.set_behaviour(_behaviour)
	}

	check_clear_move_cells = function(_xcord, _ycord) {
		var _cells = get_clear_move_cells(_xcord, _ycord);
		mark_cells(_cells);
	}

	mark_cells = function(_cells) {
		for (i = 0; i < array_length(_cells); i++) {
			_cells[i].marked = true;
		}
	}

	get_clear_move_cells = function(_xcord, _ycord) {
		return check_clear_cells(_xcord, _ycord);
	}

	get_controlled_summon_cells = function(player) {
		var _cells = [];
		var is_on_player_side;
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				cell = get_cell(i, m);
				if !cell.is_filled() {
					if player == Game.Player1.player_id {
						is_on_player_side = (cell.ycord > 2);
					}
					else {
						is_on_player_side = (cell.ycord <= 2);
					}
					if is_on_player_side or cell.is_under_control(player){
						array_push(_cells, cell);
					}
					if cell.is_under_control(Game.game_loop_controller.get_opponent(player)){
						var _cell_index = array_get_index(_cells, cell);
						if _cell_index != -1 {array_delete(_cells, _cell_index, 1);}
					}
					if cell.is_under_control(player) and cell.is_under_control(Game.game_loop_controller.get_opponent(player)) {
						if ((cell.xcord == 2 or cell.xcord == 3) and (cell.ycord == 2 or cell.ycord == 3)) {
							if array_get_index(_cells, cell) == -1 {array_push(_cells, cell);}
						}
					}
					if is_on_player_side and ((cell.xcord = 2 or cell.xcord = 3) and (cell.ycord = 2 or cell.ycord = 3)) {
						if array_get_index(_cells, cell) == -1 {array_push(_cells, cell);}
					}
				}
			}
		}
		return _cells;
	}

	check_controlled_summon_cells = function(player){
		mark_cells(get_controlled_summon_cells(player));
	}

	check_conquested_cells = function() {
		var _cells = get_conquested_cells(0);
		for (var i = 0; i < array_length(_cells); i++) {
			var _figure = _cells[i].filled_figure;
			var figure_animation = new OverturnAnimationController();
			figure_animation.start_animation(_figure.draw_x, _figure.draw_y, _figure.draw_x, _figure.draw_y, 30);
			_figure.add_animation(figure_animation)
			_figure.conquest();
			if _figure.owner == Game.Player1.player_id {
				Game.game_loop_controller.add_captured_figure(Game.Player2.player_id);
			}
			else {
				Game.game_loop_controller.add_captured_figure(Game.Player1.player_id);
			}
		}
	}

	get_conquested_cells = function(_check_state = false) {
		var _player1 = Maps_list.get_cells_for_conquest()[0]
		var _player2 = Maps_list.get_cells_for_conquest()[1]
		var _conquested_cells = [];
		for (var i = 0; i < array_length(_player1); i++) {
			var cell = get_cell(_player1[i][0], _player1[i][1])
			if (cell.is_filled() and (cell.filled_figure.state.is_active or cell.filled_figure.state.is_dropped)
			and cell.filled_figure.owner == Game.Player2.player_id) or (_check_state and global.turn_owner == Game.Player2.player_id
			and (cell.filled_figure_status.will_be_moved or cell.filled_figure_status.will_be_summoned)) {
				array_push(_conquested_cells, cell);
			}
		}
		for (var i = 0; i < array_length(_player2); i++) {
			var cell = get_cell(_player2[i][0], _player2[i][1])
			if (cell.is_filled() and (cell.filled_figure.state.is_active or cell.filled_figure.state.is_dropped)
			and cell.filled_figure.owner == Game.Player1.player_id) or (_check_state and global.turn_owner == Game.Player1.player_id
			and (cell.filled_figure_status.will_be_moved or cell.filled_figure_status.will_be_summoned)) {
				array_push(_conquested_cells, cell);
			}
		}
		return _conquested_cells;
	}

	get_marked_cells = function() {
		var _cells = []
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				if get_cell(m, i).is_marked() {array_push(_cells, get_cell(m, i))}
			}
		}
		return _cells
	}

	export_marks = function() {
		var _marks = [];
		for (var m = 0; m < field_width; m++) {
			_marks[m] = [];
		}
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				var _cell = get_cell(m, i);
				_marks[m][i] = {
					marked: _cell.marked,
					draw_mark: _cell.draw_mark
				};
			}
		}
		return _marks;
	}

	import_marks = function(_marks) {
		if !is_array(_marks) {
			return;
		}
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				var _cell = get_cell(m, i);
				if array_length(_marks) > m and is_array(_marks[m]) and array_length(_marks[m]) > i {
					_cell.marked = _marks[m][i].marked;
					_cell.draw_mark = _marks[m][i].draw_mark;
				}
			}
		}
	}

	clear_all_marks = function() {
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				get_cell(m, i).marked = false;
				get_cell(m, i).set_draw_marks(1);
			}
		}
	}

	cell_get_neightbors = function(cell) {
		neightbors = [];
		if (get_cell(cell.xcord -1, cell.ycord) != undefined) {
			array_push(neightbors, get_cell(cell.xcord -1, cell.ycord));
		}
		if (get_cell(cell.xcord +1, cell.ycord) != undefined) {
			array_push(neightbors, get_cell(cell.xcord +1, cell.ycord));
		}
		if (get_cell(cell.xcord , cell.ycord -1) != undefined) {
			array_push(neightbors, get_cell(cell.xcord , cell.ycord -1));
		}
		if (get_cell(cell.xcord , cell.ycord +1) != undefined) {
			array_push(neightbors, get_cell(cell.xcord , cell.ycord +1))
		}
		return neightbors
	}

	is_any_cell_marked = function() {
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
				if get_cell(m, i).is_marked() {
					return true
				}
			}
		}
		return false
	}

	get_place = function(type, player) {
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
				return player1_captured;
			}
			else {
				return player2_captured;
			}
		}
	}

	has_active_animations = function() {
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				var _cell = get_cell(m, i);
				if _cell.is_filled() and _cell.filled_figure.have_animation() {
					return true;
				}
			}
		}
		var _places = [player1_dropped, player2_dropped, player1_captured, player2_captured];
		for (var p = 0; p < array_length(_places); p++) {
			for (var f = 0; f < array_length(_places[p].figures); f++) {
				if _places[p].figures[f].have_animation() {
					return true;
				}
			}
		}
		return false;
	}

	check_status = function() {
		var _surrounded_cells = check_every_figure(0);
		var _conquested_cells = get_conquested_cells(1);
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				get_cell(m, i).remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_captured));
				get_cell(m, i).remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_conquest));
			}
		}
		for (var i = 0; i < array_length(_surrounded_cells); i++) {
			_surrounded_cells[i].add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_captured));
		}
		for (var i = 0; i < array_length(_conquested_cells); i++) {
			_conquested_cells[i].add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_conquest));
		}
	}

	clear_every_status = function() {
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				get_cell(m, i).clear_figure_status();
			}
		}
	}

	check_every_figure = function(_drop = 1) {
		var _surrounded_cells_array = []
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
				var _cell = get_cell(m, i);
				if _cell.is_filled() or _cell.filled_figure_status.will_be_summoned
				or _cell.filled_figure_status.will_be_filled {
					if check_if_cell_is_surrounded(_cell) {
						array_push(_surrounded_cells_array, _cell);
						if _drop {Game.game_loop_controller.figures_counter.add_figure_to_capture(_cell.filled_figure, _cell);}
					}
				}
			}
		}
		return _surrounded_cells_array;
	}

	check_if_cell_is_surrounded = function(_cell) {
		if array_length(check_clear_cells(_cell.xcord, _cell.ycord)) == 0 {
			return true
		}
		return false;
	}

	check_clear_cells = function(_xcord, _ycord) {
		var found_clear_cells = [];
		for (var i = -1; i <= 1; i++) {
			for (var m = -1; m <=1; m++) {
				var cell = Game.field.get_cell(_xcord + i, _ycord +m);
				if cell != undefined{
					if cell != Game.field.get_cell(_xcord, _ycord) {
						if !(cell.is_filled() or cell.filled_figure_status.will_be_moved
						or cell.filled_figure_status.will_be_summoned) {array_push(found_clear_cells, cell);}
					}
				}
			}
		}
		return found_clear_cells;
	}

	check_dropped_figures = function() {
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
				if get_cell(m, i).is_filled() and get_cell(m, i).filled_figure.state.is_dropped {
					get_cell(m, i).clear();
				}
			}
		}
	}

	get_player_field_figures = function(_owner) {
		var field_figures = [];
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
				cell = get_cell(m, i);
				if cell.is_filled() and cell.filled_figure.owner == _owner {
					array_push(field_figures, cell.filled_figure);
				}
			}
		}
		return field_figures
	}

	get_active_player_field_figures = function(_owner) {
		figures = get_player_field_figures(_owner);
		active_figures = [];
		for (var i = 0; i < array_length(figures); i++) {
			if figures[i].state.is_active {
				array_push(active_figures, figures[i]);
			}
		}
		return active_figures
	}

	get_filled_cells = function(_player) {
		cells = [];
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
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
		for (var i = 0; i < field_height; i++) {
			for (var m = 0; m < field_width; m++) {
				export_cells[m][i] = cell_array[m][i].export();
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

	import = function(import_data, _other_player = true) {
		for (var i = 0; i < field_width; i++) {
			for (var m = 0; m < field_height; m++) {
				//cell_array[m][i].import(import_data.ex_cells[m][i]);
				var _xcord = import_data.ex_cells[m][i].ex_xcord;
				var _ycord = import_data.ex_cells[m][i].ex_ycord;
				//if _other_player {
				//	_xcord = field_width - 1 - import_data.ex_cells[m][i].ex_xcord;
				//	_ycord = field_height - 1 - import_data.ex_cells[m][i].ex_ycord;
				//}
				get_cell(_xcord, _ycord).import(import_data.ex_cells[m][i])
			}
		}
		player1_dropped.import(import_data.ex_player1_dropped);
		player2_dropped.import(import_data.ex_player2_dropped);
		player1_captured.import(import_data.ex_player1_captured);
		player2_captured.import(import_data.ex_player2_captured);
		global.map = import_data.ex_map;
	}

}
