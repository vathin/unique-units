
function ShieldbearerAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	target_figure = undefined;
	target_cell = undefined;
	fill_cell = undefined;
	selected = false
	
	execute = function() {
		target_figure.start_move_animation(fill_cell, Settings.ability_animation_length)
		fill_cell.fill(target_figure);
		target_cell.clear();
	}
	
	draw = function() {
		if selected {
			draw_sprite_ext(target_figure.sprite_index, 0, fill_cell.x, fill_cell.y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if target_figure != undefined {
			draw_sprite_ext(S_Back_Action_Target, 0, target_figure.x, target_figure.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	set_target = function(new_target, new_cell) {
		if target_figure == undefined {
			target_figure = new_target;
			target_cell = new_cell;
			check_ability_targets(0, 0)
		}
		else {
			selected = 1;
			O_EndTurn.active = 1;
			fill_cell = global.cell_click_callback;
			O_EndTurn.unblock();
		}
	}
	
	check_ability_targets = function(a, b) {
		O_EndTurn.block();
		if target_figure == undefined {
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
	
	back = function() {
		if target_figure != undefined {
			if fill_cell != undefined {
				fill_cell.set_draw_marks(1);
				fill_cell = undefined;
				global.cell_click_callback = target_cell;
				selected = 0;
				O_EndTurn.block();
			}
			else {
				target_figure = undefined;
				O_GameField.clear_all_marks();
				check_ability_targets(0, 0);
				target_cell = undefined;
				selected = false;
			}
		}
		else {
			if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
			O_GameField.clear_all_marks();
			global.using_ability = 0;
			global.cell_click_callback = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_GameLoopController.action = undefined;
		}
	}
	
	export = function() {
		export_data = {
			action: ShieldbearerAbility,
			type: "act_ability",
			ex_using_figure: using_figure,
			ex_using_cell: using_cell,
			ex_target_figure: target_figure,
			ex_target_cell: target_cell,
			ex_fill_cell: fill_cell
		}
		return export_data
	}
	import = function(import_data) {
		using_figure = import_data.ex_using_figure;
		using_cell = import_data.ex_using_cell;
		target_figure = import_data.ex_target_figure;
		target_cell = import_data.ex_target_cell;
		fill_cell = import_data.ex_fill_cell;
	}
}