// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function ArcherMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) constructor{
	self.from_x = from_x;
	self.from_y = from_y;
	self.figure_sprite = figure_sprite;
	self.to_x = to_x;
	self.to_y = to_y;
	moving_figure = undefined;
	found_move_cells = false;
	cells_to_check = [];
	if to_x != undefined{
		O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
	}
	for (i = 0; i <= 5; i++) {
		for (m = 0; m <= 5; m++) {
			cell_array[m][i] = 0;
		}
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
	
	check_cell = function(cell) {
		if cell_array[cell.xcord][cell.ycord] = 0 {
			cell_array[cell.xcord][cell.ycord] = 1
			return true
		}
		else {
			return false
		}
	}
	
	mark_cells_from_array = function() {
		for (i = 0; i < 6; i++) {
			for (m = 0; m < 6; m++) {
				if cell_array[m][i] = 2 {
					O_GameField.get_cell(m, i).marked = 1;
				}
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
	
	check_move_cells = function(cell) {
		if !cell.is_filled {return}
		get_and_check_cell(cell, cell.xcord + 1, cell.ycord);
		get_and_check_cell(cell, cell.xcord, cell.ycord + 1);
		get_and_check_cell(cell, cell.xcord - 1, cell.ycord);
		get_and_check_cell(cell, cell.xcord, cell.ycord - 1);
	}
	
	check_all_cells = function() {
		O_GameField.clear_all_marks();
		check_move_cells(O_GameField.get_cell(from_x, from_y));
		while (array_length(cells_to_check) != 0) { 
			check_move_cells(array_pop(cells_to_check))
		}
		mark_cells_from_array();
	}
	
	cancel = function() {}
	
}