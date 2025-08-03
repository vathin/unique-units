
function ShieldbearerAbility(_using_figure=undefined, _using_cell=undefined) : FigureAbilityAction() constructor{
	using_figure = _using_figure;
	using_cell = _using_cell;
	target_figure = undefined;
	target_cell = undefined;
	fill_cell = undefined;
	selected = false;
	draw_previous_ability = 0;
	draw_previous_move = 0;
	
	execute = function() {
		target_cell.filled_figure.add_previous_move_cell([target_cell.xcord, target_cell.ycord]);
		using_cell.filled_figure.add_previous_ability_cell([fill_cell.xcord, fill_cell.ycord], target_figure.figure_id);
		fill_cell.fill(target_figure);
		target_cell.clear();
		figure_animation = new MoveAnimationController();
		figure_animation.start_animation(Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1],
		Game.field.get_cell_xy(fill_cell)[0], Game.field.get_cell_xy(fill_cell)[1], Settings.move_animation_length*1.2);
		target_figure.add_animation(figure_animation);
	}
	
	draw = function() {
		if selected {
			draw_sprite_ext(Behaviours.get_sprite(target_figure.behaviour), target_figure.image, Game.field.get_cell_xy(fill_cell)[0], Game.field.get_cell_xy(fill_cell)[1], 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if target_figure != undefined {
			draw_sprite_ext(S_Back_Action_Target, 0, Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1], Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			if draw_previous_ability and using_figure.previous_ability_cell != undefined{
				var _draw_x = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_ability_cell[0], using_figure.previous_ability_cell[1]))[0];
				var _draw_y = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_ability_cell[0], using_figure.previous_ability_cell[1]))[1];
				draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
				//draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_ability_cell.x, using_figure.previous_ability_cell.y,
				//Settings.figure_scale, Settings.figure_scale, 0, c_white, 1)
			}
			if draw_previous_move and target_figure.previous_move_cell != undefined{
				var _draw_x = Game.field.get_cell_xy(Game.field.get_cell(target_figure.previous_move_cell[0], target_figure.previous_move_cell[1]))[0];
				var _draw_y = Game.field.get_cell_xy(Game.field.get_cell(target_figure.previous_move_cell[0], target_figure.previous_move_cell[1]))[1];
				draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
				//draw_sprite_ext(S_cycle_rule, 0, target_figure.previous_move_cell.x, target_figure.previous_move_cell.y,
				//Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			}
		}
	}
	
	set_target = function(new_target, new_cell) {
		if target_figure == undefined {
			target_cell = global.cell_click_callback;
			target_figure = target_cell.filled_figure
			check_ability_targets();
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
					cell = Game.field.get_cell(using_cell.xcord + i, using_cell.ycord + m);
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
			cl = using_figure.previous_ability_cell
			if cl != undefined and Game.field.get_cell(cl[0], cl[1]).is_marked 
			and using_figure.previous_ability_target_id == target_figure.figure_id{
				Game.field.get_cell(cl[0], cl[1]).marked = 0;
				draw_previous_ability = 1;
			}
			else {
				tcl = target_figure.previous_move_cell;
				if tcl != undefined and Game.field.get_cell(tcl[0], tcl[1]).is_filled() {
					Game.field.get_cell(tcl[0], tcl[1]).marked = 0;
					draw_previous_move = 1;
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
			ex_fill_cell: [fill_cell.xcord, fill_cell.ycord],
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_target_cell: [target_cell.xcord, target_cell.ycord],
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	
	import = function(_import_data) {
		using_cell = Game.field.get_cell(_import_data.ex_using_cell[0], _import_data.ex_using_cell[1]);
		using_figure = using_cell.filled_figure;
		target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
		target_figure = target_cell.filled_figure;
		fill_cell = Game.field.get_cell(_import_data.ex_fill_cell[0], _import_data.ex_fill_cell[1]);
	}
}