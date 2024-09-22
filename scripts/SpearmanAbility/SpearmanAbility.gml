
function SpearmanAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	cell_for_move = undefined;
	target_figure = undefined;
	draw_previous_move_cell = false;
	
	execute = function() {
		using_cell.filled_figure.start_move_animation(cell_for_move, Settings.ability_animation_length)
		cell_for_move.fill(using_cell.filled_figure, 1);
		using_cell.clear();
	}
	
	set_target = function(useless_data, useless_data2) {
		cell_for_move = global.cell_click_callback;
		O_EndTurn.unblock();
	}
	
	draw = function() {
		if global.cell_click_callback != using_cell{
			draw_sprite_ext(using_figure.sprite_index, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			if using_figure.previous_ability_cell != undefined and !using_figure.previous_ability_cell.is_filled(){
				draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_ability_cell.x, using_figure.previous_ability_cell.y,
				Settings.figure_scale, Settings.figure_scale, 0, c_white, 1)
			}
		}
		if draw_previous_move_cell {
			draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_move_cell.x, using_figure.previous_move_cell.y,
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 1)
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
		if using_cell.filled_figure.previous_move_cell != undefined and using_cell.filled_figure.previous_move_cell.marked {
			draw_previous_move_cell = 1;
			using_cell.filled_figure.previous_move_cell.marked = 0;
		}
	}
	
	
	back = function() {
		if global.cell_click_callback != global.selected_cell {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback = using_cell;
			O_EndTurn.block();
		}
		else {
			O_GameLoopController.quit_from_action()
		}
	}
	
	export = function() {
		export_data = {
			ex_action : SpearmanAbility,
			ex_type : "act_ability",
			ex_using_figure: using_figure,
			ex_using_cell: using_cell,
			ex_cell_for_move: cell_for_move,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	
	import = function(import_data) {
		using_figure = import_data.ex_using_figure;
		using_cell = import_data.ex_using_cell;
		cell_for_move = import_data.ex_cell_for_move;
	}
}