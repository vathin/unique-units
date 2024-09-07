

enum ArcherMoveAbility_Cell {
	uncalculated,
	calculated,
	available
}

function ArcherMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) constructor{
	self.from_x = from_x;
	self.from_y = from_y;
	self.figure_sprite = S_Archer;
	self.to_x = to_x;
	self.to_y = to_y;
	moving_figure = undefined;
	found_move_cells = false;
	cells_to_check = [];
	using_figure = global.selected_cell.filled_figure;
	
	init = function() {
		if to_x != undefined {
			O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
		}
		clear();
	}
	execute = function() {
		O_GameField.get_cell(to_x, to_y).fill(using_figure)
		O_GameField.get_cell(from_x, from_y).clear();
	}
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	set_new_target_coordinates = function(new_x, new_y) {
		if to_x != undefined {O_GameField.get_cell(to_x, to_y).set_draw_marks(1)}
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0)
	}
	
	check_clear_cells = function(cell_x, cell_y) {
		found_cells = false;
		closed = 0;
		if cell_x = undefined or cell_y = undefined {
			cell_x = from_x;
			cell_y = from_y;
		}
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = O_GameField.get_cell(cell_x + i, cell_y + m);
				if cell != undefined {
					if cell.is_filled() and cell != O_GameField.get_cell(from_x, from_y){
						found_cells = 1
					}
				}
			}
		}
		if O_GameField.get_cell(cell_x + 1, cell_y) != undefined and O_GameField.get_cell(cell_x + 1, cell_y).is_filled() {closed ++}
		if O_GameField.get_cell(cell_x - 1, cell_y) != undefined and O_GameField.get_cell(cell_x - 1, cell_y).is_filled() {closed ++}
		if O_GameField.get_cell(cell_x, cell_y + 1) != undefined and O_GameField.get_cell(cell_x, cell_y + 1).is_filled() {closed ++}
		if O_GameField.get_cell(cell_x, cell_y - 1) != undefined and O_GameField.get_cell(cell_x, cell_y - 1).is_filled() {closed ++}
		if closed = 4 {return false}
		return found_cells
	}
	
	check_all_cells = function() {
		var start_cell = O_GameField.get_cell(from_x, from_y);
		O_GameField.clear_all_marks();
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
					O_GameField.get_cell(m, i).marked = 1;
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
		if (is_cell_filled(cell.xcord - 1, cell.ycord - 1, except_of)) return true;
		if (is_cell_filled(cell.xcord + 0, cell.ycord - 1, except_of)) return true;
		if (is_cell_filled(cell.xcord + 1, cell.ycord - 1, except_of)) return true;
		if (is_cell_filled(cell.xcord - 1, cell.ycord + 0, except_of)) return true;
		if (is_cell_filled(cell.xcord + 1, cell.ycord + 0, except_of)) return true;
		if (is_cell_filled(cell.xcord - 1, cell.ycord + 1, except_of)) return true;
		if (is_cell_filled(cell.xcord + 0, cell.ycord + 1, except_of)) return true;
		if (is_cell_filled(cell.xcord + 1, cell.ycord + 1, except_of)) return true;
		
		return false
	}
	is_cell_filled = function(x, y, except_of = undefined) {
		var cell = O_GameField.get_cell(x, y);
		
		if (cell == undefined)
			return false;
			
		if (cell == except_of)
			return false;
			
		return cell.is_filled();
	}
	add_neighbor_cells_to_queue = function(from_cell) {
		add_cell_to_queue(O_GameField.get_cell(from_cell.xcord - 1, from_cell.ycord));
		add_cell_to_queue(O_GameField.get_cell(from_cell.xcord + 1, from_cell.ycord));
		add_cell_to_queue(O_GameField.get_cell(from_cell.xcord, from_cell.ycord + 1));
		add_cell_to_queue(O_GameField.get_cell(from_cell.xcord, from_cell.ycord - 1));
	}
	add_cell_to_queue = function(new_cell) {
		if (new_cell == undefined)
			return;
			
		array_push(cells_to_check, new_cell);
	}
	
	clear = function() {
		for (i = 0; i <= 5; i++) {
			for (m = 0; m <= 5; m++) {
				cell_array[m][i] = ArcherMoveAbility_Cell.uncalculated;
			}
		}
	}

	
	get_and_check_cell = function(old_cell, cell_x, cell_y) {
		new_cell = O_GameField.get_cell(cell_x, cell_y)
		if new_cell != undefined and new_cell != old_cell and check_cell(new_cell){
			if new_cell.is_filled() {
				array_push(cells_to_check, new_cell);
				}
			else {
				cell_array[new_cell.xcord][new_cell.ycord] = 2;
				if old_cell = O_GameField.get_cell(from_x, from_y) {
					cell_array[cell_x][cell_y] = 0;
				}
				for (j = -1; j <= 1; j++) {
					for (k = -1; k <= 1; k++) {
						hook_cell = O_GameField.get_cell(new_cell.xcord + j, new_cell.ycord + k);
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
	
	
	cancel = function() {}
	
	back = function() {
		if to_x != undefined {
			O_GameField.field[to_y][to_x].set_draw_marks(1)
			to_x = undefined;
			to_y = undefined;
		}
		else {
			if instance_exists(O_MoveInputController) {instance_destroy(O_MoveInputController)}
			O_GameField.clear_all_marks();
			global.cell_click_callback = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_SummonButton.go_away();
			global.moving_figure = 0;
			O_GameLoopController.action = undefined;
		}
	}
	
	
	init();
	
	export = function() {
		export_data = {
			ex_from_x: from_x,
			ex_from_y: from_y,
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_using_figure: global.selected_cell.filled_figure
		}
	}
	
}

