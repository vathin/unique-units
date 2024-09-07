
function SpearmanAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	cell_for_move = undefined;
	target_figure = undefined;
	
	execute = function() {
		global.selected_cell.filled_figure.start_move_animation(global.cell_click_callback, Settings.ability_animation_length)
		global.cell_click_callback.fill(global.selected_cell.filled_figure, 1);
		global.selected_cell.clear();
	}
	
	set_target = function(f, new_cell) {
		cell_for_move = new_cell;
	}
	
	draw = function() {
		if global.cell_click_callback != using_cell{
			draw_sprite_ext(using_figure.sprite_index, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	
	check_ability_targets = function(a, b) {
		if O_GameField.get_cell(using_cell.xcord + 1, using_cell.ycord) != undefined and 
		O_GameField.get_cell(using_cell.xcord + 2, using_cell.ycord) != undefined {
			if !O_GameField.get_cell(using_cell.xcord + 1, using_cell.ycord).is_filled() and 
			!O_GameField.get_cell(using_cell.xcord + 2, using_cell.ycord).is_filled() {
				O_GameField.get_cell(using_cell.xcord + 2, using_cell.ycord).marked = 1;
			}
		}
		if O_GameField.get_cell(using_cell.xcord - 1, using_cell.ycord) != undefined and 
		O_GameField.get_cell(using_cell.xcord - 2, using_cell.ycord) != undefined {
			if !O_GameField.get_cell(using_cell.xcord - 1, using_cell.ycord).is_filled() and 
			!O_GameField.get_cell(using_cell.xcord - 2, using_cell.ycord).is_filled() {
				O_GameField.get_cell(using_cell.xcord - 2, using_cell.ycord).marked = 1;
			}
		}	
		if O_GameField.get_cell(using_cell.xcord, using_cell.ycord + 1) != undefined and 
		O_GameField.get_cell(using_cell.xcord, using_cell.ycord + 2) != undefined {
			if !O_GameField.get_cell(using_cell.xcord, using_cell.ycord + 1).is_filled() and 
			!O_GameField.get_cell(using_cell.xcord, using_cell.ycord + 2).is_filled() {
				O_GameField.get_cell(using_cell.xcord, using_cell.ycord + 2).marked = 1;
			}
		}
		if O_GameField.get_cell(using_cell.xcord, using_cell.ycord - 1) != undefined and 
		O_GameField.get_cell(using_cell.xcord, using_cell.ycord - 2) != undefined {
			if !O_GameField.get_cell(using_cell.xcord, using_cell.ycord - 1).is_filled() and 
			!O_GameField.get_cell(using_cell.xcord, using_cell.ycord - 2).is_filled() {
				O_GameField.get_cell(using_cell.xcord, using_cell.ycord - 2).marked = 1;
			}
		}	
		
	}
	
	cancel = function() {}
	
	back = function() {
		if cell_for_move != undefined {
			cell_for_move = undefined;
			global.cell_click_callback = global.selected_cell;
		}
		else {
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_GameField.clear_all_marks();
			O_SummonButton.go_away();
			global.cell_click_callback = global.selected_cell;
			O_GameLoopController.action = undefined;
		}
	}
}