
function ShieldbearerAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	target_figure = undefined;
	target_cell = undefined;
	selected = false
	
	execute = function() {
		target_figure.start_move_animation(global.cell_click_callback, Settings.ability_animation_length)
		global.cell_click_callback.fill(target_figure);
		target_cell.clear();
	}
	
	draw = function() {
		if selected {
			draw_sprite_ext(target_figure.sprite_index, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if target_figure != undefined {
			draw_sprite_ext(S_Back_Action_Target, 0, target_figure.x, target_figure.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	set_target = function(new_target, new_cell) {
		if target_figure = undefined {
			target_figure = new_target;
			target_cell = new_cell
			check_ability_targets(0, 0)
		}
		else {
			selected = 1;
			O_EndTurn.active = 1;
		}
	}
	
	check_ability_targets = function(a, b) {
		O_EndTurn.active = 0;
		if target_figure = undefined {
			for (i = -1; i <= 1; i++) {
				for (m = -1; m <= 1; m++) {
					cell = O_GameField.get_cell(using_cell.xcord + i, using_cell.ycord + m)
					if cell != undefined {
						if cell.is_filled() and cell.filled_figure != using_cell.filled_figure and !cell.filled_figure.state.is_conquesting {
							cell.marked = 1;
						}
					}
				}
			}
		}
		else {
			O_GameField.clear_all_marks();
			O_GameField.check_clear_move_cells(using_cell.xcord, using_cell.ycord);
		}
	}
	
	cancel = function() {}
	back = function() {
		if target_figure != undefined {
			target_figure = undefined;
			O_GameField.clear_all_marks()
			check_ability_targets(0, 0);
			target_cell = undefined
			selected = false
		}
		else {
			if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
			O_GameField.clear_all_marks();
			sel_cell = global.selected_cell;
			global.cell_click_callback = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_SummonButton.go_away();
			global.using_ability = 0;
			O_GameLoopController.action = undefined;
		}
	}
}