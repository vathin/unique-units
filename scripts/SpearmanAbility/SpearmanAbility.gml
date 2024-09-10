
function SpearmanAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	cell_for_move = undefined;
	target_figure = undefined;
	
	execute = function() {
		using_cell.filled_figure.start_move_animation(cell_for_move, Settings.ability_animation_length)
		cell_for_move.fill(using_cell.filled_figure, 1);
		using_cell.clear();
	}
	
	set_target = function(useless_data, useless_data2) {
		cell_for_move = global.cell_click_callback;
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
	
	
	back = function() {
		if global.cell_click_callback != global.selected_cell {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback = using_cell;
		}
		else {
			O_GameField.clear_all_marks();
			O_SummonButton.go_away();
			global.cell_click_callback = using_cell;
			global.using_ability = 0;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_GameLoopController.action = undefined;
		}
	}
	
	export = function() {
		export_data = {
			action : SpearmanAbility,
			type : "act_ability",
			ex_using_figure: using_figure,
			ex_using_cell: using_cell,
			ex_cell_for_move: cell_for_move
		}
		return export_data
	}
	
	import = function(import_data) {
		using_figure = import_data.ex_using_figure;
		using_cell = import_data.ex_using_cell;
		cell_for_move = import_data.ex_cell_for_move;
	}
}