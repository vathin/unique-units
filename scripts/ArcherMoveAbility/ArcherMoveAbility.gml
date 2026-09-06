

enum ArcherMoveAbility_Cell {
	uncalculated,
	calculated,
	available
}

function ArcherMoveAbility(_from_x, _from_y, _to_x, _to_y, _figure_sprite) constructor{
	from_x = _from_x;
	from_y = _from_y;
	figure_sprite = S_Archer;
	to_x = _to_x;
	to_y = _to_y;
	moving_figure = undefined;
	found_move_cells = false;
	cells_to_check = [];
	if from_x != undefined {
		figure_color = Game.field.get_cell(from_x, from_y).filled_figure.image;
		using_figure = Game.field.get_cell(_from_x, _from_y).filled_figure;
	}
	if Game.move_input_controller != undefined {O_BoardDraw.unblock_end_button()}
	_found_id = []
	previous_move_cell = undefined;
	draw_previous_cell = false;
	
	init = function() {
		if to_x != undefined {
			Game.field.get_cell(to_x, to_y).set_draw_marks(0);
		}
		clear();
	}
	
	execute = function() {
		using_cell = Game.field.get_cell(from_x, from_y);
		cell_for_move = Game.field.get_cell(to_x, to_y);
		FindArcherTrajectory(from_x, from_y, to_x, to_y)
		Game.field.add_movement(using_cell, cell_for_move, using_cell.filled_figure.figure_id);
		cell_for_move.fill(using_figure, 1);
		var _trajectory = FindArcherTrajectory(from_x, from_y, to_x, to_y);
		for (var i = 0; i < array_length(_trajectory)-1; i++) {
			figure_animation = new MoveAnimationController();
			var _from = Game.field.get_cell_xy(Game.field.get_cell(_trajectory[i][0], _trajectory[i][1]));
			var _to = Game.field.get_cell_xy(Game.field.get_cell(_trajectory[i+1][0], _trajectory[i+1][1]))
			figure_animation.start_animation(_from[0], _from[1], _to[0], _to[1], 
			Settings.move_animation_length*array_length(_trajectory)/array_length(_trajectory));
			using_figure.add_animation(figure_animation);
		}
		using_cell.clear();
		_found_id = [];
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(figure_sprite, figure_color, Game.field.get_cell_xy(Game.field.get_cell(to_x, to_y))[0],
			Game.field.get_cell_xy(Game.field.get_cell(to_x, to_y))[1], Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
		}
		if draw_previous_cell and previous_move_cell != undefined{
			var _draw_x = Game.field.get_cell_xy(previous_move_cell)[0];
			var _draw_y = Game.field.get_cell_xy(previous_move_cell)[1];
			draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.7);
		}
	}
	set_new_target_coordinates = function(new_x, new_y) {
		if to_x != undefined {
			Game.field.get_cell(to_x, to_y).set_draw_marks(1);
			Game.field.get_cell(to_x, to_y).remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
			}
		self.to_x = new_x;
		self.to_y = new_y;
		Game.field.get_cell(to_x, to_y).add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
		Game.field.get_cell(new_x, new_y).set_draw_marks(0);
		O_BoardDraw.unblock_end_button()
	}
	
	check_clear_cells = function(cell_x, cell_y) {
		found_cells = false;
		closed = 0;
		if cell_x == undefined or cell_y == undefined {
			cell_x = from_x;
			cell_y = from_y;
		}
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = Game.field.get_cell(cell_x + i, cell_y + m);
				if cell != undefined {
					if cell.is_filled() and cell != Game.field.get_cell(from_x, from_y){
						found_cells = 1
					}
				}
			}
		}
		if Game.field.get_cell(cell_x + 1, cell_y) != undefined and Game.field.get_cell(cell_x + 1, cell_y).is_filled() {closed ++}
		if Game.field.get_cell(cell_x - 1, cell_y) != undefined and Game.field.get_cell(cell_x - 1, cell_y).is_filled() {closed ++}
		if Game.field.get_cell(cell_x, cell_y + 1) != undefined and Game.field.get_cell(cell_x, cell_y + 1).is_filled() {closed ++}
		if Game.field.get_cell(cell_x, cell_y - 1) != undefined and Game.field.get_cell(cell_x, cell_y - 1).is_filled() {closed ++}
		if closed == 4 {return false}
		return found_cells
	}
	
	check_previous_cell = function() {
		var _previous_cell = Game.field.check_movement_array(using_figure.figure_id)
		if _previous_cell != undefined and _previous_cell.is_marked() {
			draw_previous_cell = 1;
			_previous_cell.marked = 0;
			previous_move_cell = _previous_cell;
		}
	}
	
	check_all_cells = function() {
		var start_cell = Game.field.get_cell(from_x, from_y);
		Game.field.clear_all_marks();
		add_neighbor_cells_to_queue(start_cell);
		
		while (array_length(cells_to_check) != 0) { 
			check_cell_for_move(start_cell, array_pop(cells_to_check))
		}
		mark_cells_from_array();
	}
	mark_cells_from_array = function() {
		for (i = 0; i < 6; i++) {
			for (m = 0; m < 6; m++) {
				if cell_array[m][i] = ArcherMoveAbility_Cell.available {
					Game.field.get_cell(m, i).marked = 1;
				}
			}
		}
	}
	check_cell_for_move = function(from_cell, new_cell) {
		if (new_cell == undefined) return;
		if (from_cell == new_cell) return;
		if (not check_cell_not_yet_calculated(new_cell)) return;
		if (new_cell.is_filled()) return;
		
		
		if (is_cell_have_neighbor(new_cell, from_cell)) {
			mark_cell_as_available(new_cell);
			add_neighbor_cells_to_queue(new_cell);
		}
	}
	
	check_cell_not_yet_calculated = function(cell) {
		if cell_array[cell.xcord][cell.ycord] = ArcherMoveAbility_Cell.uncalculated {
			cell_array[cell.xcord][cell.ycord] = ArcherMoveAbility_Cell.calculated
			return true
		}
		else {
			return false
		}
	}
	is_cell_have_neighbor = function(cell, except_of = undefined) {
		var _array = []
		
		if (is_cell_filled(cell.xcord - 1, cell.ycord - 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord - 1, cell.ycord - 1).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord + 0, cell.ycord - 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord + 0, cell.ycord - 1).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord + 1, cell.ycord - 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord + 1, cell.ycord - 1).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord - 1, cell.ycord + 0, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord - 1, cell.ycord + 0).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord + 1, cell.ycord + 0, except_of))
		{array_push(_array, Game.field.get_cell(cell.xcord + 1, cell.ycord + 0).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord - 1, cell.ycord + 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord - 1, cell.ycord + 1).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord + 0, cell.ycord + 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord + 0, cell.ycord + 1).filled_figure.figure_id)};
		if (is_cell_filled(cell.xcord + 1, cell.ycord + 1, except_of)) 
		{array_push(_array, Game.field.get_cell(cell.xcord + 1, cell.ycord + 1).filled_figure.figure_id)};
		
		if array_length(_array) > 0 and array_length(_found_id) == 0 {
			for (i = 0; i < array_length(_array); i++) {array_push(_found_id, _array[i])}
			return true
			}
			var _found_figure = 0
		for (m = 0; m < array_length(_array); m ++) {
			for (n = 0; n < array_length(_found_id); n++) {
				if _array[m] == _found_id[n] {_found_figure = 1}
			}
		}
		if _found_figure {
			for (m = 0; m < array_length(_array); m ++) {
				if (array_get_index(_found_id, _array[m]) == -1) {array_push(_found_id, _array[m])}
			}
			return true
		}
		
		return false
	}
	is_cell_filled = function(x, y, except_of = undefined) {
		var cell = Game.field.get_cell(x, y);
		
		if (cell == undefined)
			return false;
			
		if (cell == except_of)
			return false;
			
		return cell.is_filled();
	}
	add_neighbor_cells_to_queue = function(from_cell) {
		add_cell_to_queue(Game.field.get_cell(from_cell.xcord - 1, from_cell.ycord));
		add_cell_to_queue(Game.field.get_cell(from_cell.xcord + 1, from_cell.ycord));
		add_cell_to_queue(Game.field.get_cell(from_cell.xcord, from_cell.ycord + 1));
		add_cell_to_queue(Game.field.get_cell(from_cell.xcord, from_cell.ycord - 1));
	}
	add_cell_to_queue = function(new_cell) {
		if (new_cell == undefined)
			return;
			
		array_push(cells_to_check, new_cell);
	}
	
	clear = function() {
		_found_id = [];
		for (i = 0; i <= 5; i++) {
			for (m = 0; m <= 5; m++) {
				cell_array[m][i] = ArcherMoveAbility_Cell.uncalculated;
			}
		}
	}

	
	get_and_check_cell = function(old_cell, cell_x, cell_y) {
		new_cell = Game.field.get_cell(cell_x, cell_y)
		if new_cell != undefined and new_cell != old_cell and check_cell(new_cell){
			if new_cell.is_filled() {
				array_push(cells_to_check, new_cell);
				}
			else {
				cell_array[new_cell.xcord][new_cell.ycord] = 2;
				if old_cell == Game.field.get_cell(from_x, from_y) {
					cell_array[cell_x][cell_y] = 1;
				}
				for (j = -1; j <= 1; j++) {
					for (k = -1; k <= 1; k++) {
						hook_cell = Game.field.get_cell(new_cell.xcord + j, new_cell.ycord + k);
						if hook_cell != undefined and cell_array[hook_cell.xcord][hook_cell.ycord] = 0 and hook_cell.is_filled(){
							array_push(cells_to_check, hook_cell)
							check_cell(hook_cell);
						}
					}
				}
			}
		}
	}

	mark_cell_as_uncalculated = function(new_cell) {
		cell_array[new_cell.xcord][new_cell.ycord] = ArcherMoveAbility_Cell.uncalculated;
	}
	mark_cell_as_calculated = function(new_cell) {
		cell_array[new_cell.xcord][new_cell.ycord] = ArcherMoveAbility_Cell.calculated;
	}
	mark_cell_as_available = function(new_cell) {
		cell_array[new_cell.xcord][new_cell.ycord] = ArcherMoveAbility_Cell.available;

	}
	
	
	
	back = function() {
		if to_x != undefined {
			Game.field.get_cell(to_x, to_y).set_draw_marks(1);
			Game.field.get_cell(to_x, to_y).remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
			to_x = undefined;
			to_y = undefined;
			O_BoardDraw.block_end_button();
		}
		else {
			Game.game_loop_controller.quit_from_action();
		}
	}
	
	
	init();
	
	export = function() {
		export_data = {
			ex_action: ArcherMoveAbility,
			ex_type: "move_ability",
			ex_from_x: from_x,
			ex_from_y: from_y,
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_using_figure: undefined,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(_import_data) {
		from_x = _import_data.ex_from_x;
		from_y = _import_data.ex_from_y;
		to_x = _import_data.ex_to_x;
		to_y = _import_data.ex_to_y;
		using_figure = (Game.field.get_cell(_import_data.ex_from_x, _import_data.ex_from_y)).filled_figure;
	}
}

