
function ShieldbearerAbility(_using_figure, _using_cell) : FigureAbilityAction() constructor{
	using_figure = _using_figure;
	using_cell = _using_cell;
	target_figure = undefined;
	target_cell = undefined;
	fill_cell = undefined;
	selected = false;
	draw_previous_ability = 0;
	draw_previous_move = 0;
	
	execute = function() {
		target_figure.add_previous_move_cell(target_cell);
		using_figure.add_previous_ability_cell(fill_cell, target_figure);
		//target_figure.start_move_animation(fill_cell, Settings.ability_animation_length)
		fill_cell.fill(target_figure);
		target_cell.clear();
	}
	
	draw = function() {
		if selected {
			//draw_sprite_ext(target_figure.sprite_index, 0, fill_cell.x, fill_cell.y, 
			//Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if target_figure != undefined {
			//draw_sprite_ext(S_Back_Action_Target, 0, target_figure.x, target_figure.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			if draw_previous_ability{
				//draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_ability_cell.x, using_figure.previous_ability_cell.y,
				//Settings.figure_scale, Settings.figure_scale, 0, c_white, 1)
			}
			if draw_previous_move {
				//draw_sprite_ext(S_cycle_rule, 0, target_figure.previous_move_cell.x, target_figure.previous_move_cell.y,
				//Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			}
		}
	}
	
	set_target = function(new_target, new_cell) {
		if target_figure == undefined {
			target_figure = new_target;
			target_cell = new_cell;
			check_ability_targets()
		}
		else {
			selected = 1;
			O_BoardDraw.unblock_end_button();
			fill_cell = global.cell_click_callback;
		}
	}
	
	check_ability_targets = function() {
		O_BoardDraw.block_end_button();
		if target_figure == undefined {
			for (i = -1; i <= 1; i++) {
				for (m = -1; m <= 1; m++) {
					cell = Game.field.get_cell(using_cell.xcord + i, using_cell.ycord + m)
					if cell != undefined {
						if cell.is_filled() and cell.filled_figure != using_cell.filled_figure and !cell.filled_figure.state.is_conquesting {
							cell.marked = 1;
						}
					}
				}
			}
		}
		else {
			Game.field.clear_all_marks();
		Game.field.check_clear_move_cells(using_cell.xcord, using_cell.ycord);
			if using_figure.previous_ability_cell != undefined and using_figure.previous_ability_cell.marked 
			and using_figure.previous_ability_target == target_figure{
				using_figure.previous_ability_cell.marked = 0;
				draw_previous_ability = 1
			}
			else {
				if target_figure.previous_move_cell != undefined and !target_figure.previous_move_cell.is_filled() {
					target_figure.previous_move_cell.marked = 0
					draw_previous_move = 1
				}
			}
		}
	}
	
	back = function() {
		if target_figure != undefined {
			if fill_cell != undefined {
				fill_cell.set_draw_marks(1);
				fill_cell = undefined;
				global.cell_click_callback = target_cell;
				selected = 0;
				O_BoardDraw.block_end_button();
			}
			else {
				target_figure = undefined;
				Game.field.clear_all_marks();
				check_ability_targets();
				target_cell = undefined;
				selected = false;
				draw_previous_ability = 0;
				draw_previous_move = 0;
			}
		}
		else {
			Game.game_loop_controller.quit_from_action();
		}
	}
	
	export = function() {
		export_data = {
			ex_action: ShieldbearerAbility,
			ex_type: "act_ability",
			ex_using_figure: using_figure,
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_target_figure: target_figure,
			ex_target_cell: [target_cell.xcord, target_cell.ycord],
			ex_fill_cell: [fill_cell.xcord, fill_cell.ycord],
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	
	import = function(_import_data) {
		using_figure = _import_data.ex_using_figure;
		using_cell = Game.field.get_cell(_import_data.ex_using_cell[0], _import_data.ex_using_cell[1]);
		target_figure = _import_data.ex_target_figure;
		target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
		fill_cell = Game.field.get_cell(_import_data.ex_fill_cell[0], _import_data.ex_fill_cell[1]);
	}
}