// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377

enum ArcherMoveAbility_Cell {
	uncalculated,
	calculated,
	available
}

function ArcherMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) constructor{
	self.from_x = from_x;
	self.from_y = from_y;
	self.figure_sprite = figure_sprite;
	self.to_x = to_x;
	self.to_y = to_y;
	moving_figure = undefined;
	found_move_cells = false;
	cells_to_check = [];
	
	
	init = function() {
		if to_x != undefined {
			O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
		}
		clear();
	}
	execute = function() {
		O_GameField.get_cell(to_x, to_y).fill(global.selected_cell.filled_figure)
		O_GameField.get_cell(from_x, from_y).clear();
	}
	draw = function() {
			draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
	}
	set_new_target_coordinates = function(new_x, new_y) {
		O_GameField.get_cell(to_x, to_y).set_draw_marks(1)
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0)
	}
	
	check_clear_cells = function(cell_x, cell_y) {
		found_cells = false;
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
	
	
	init();
}