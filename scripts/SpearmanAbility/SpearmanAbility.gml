
function SpearmanAbility(using_figure=undefined, using_cell=undefined, _skip_ui=false) : FigureAbilityAction() constructor{
	skip_ui = _skip_ui;
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	if using_figure != undefined {
		figure_sprite = Behaviours.get_sprite(using_figure.behaviour)
	}
	cell_for_move = undefined;
	target_figure = undefined;
	draw_previous_cell = false;
	previous_move_cell = undefined;
	
	execute = function() {
		using_figure = using_cell.filled_figure
		Game.field.add_movement(using_cell, cell_for_move, using_cell.filled_figure.figure_id)
		cell_for_move.fill(using_cell.filled_figure, 1);
		using_cell.clear();
		figure_animation = new MoveAnimationController();
		figure_animation.start_animation(Game.field.get_cell_xy(using_cell)[0], Game.field.get_cell_xy(using_cell)[1],
		Game.field.get_cell_xy(cell_for_move)[0], Game.field.get_cell_xy(cell_for_move)[1], Settings.move_animation_length*1.8);
		using_figure.add_animation(figure_animation);
	}
	
	set_target = function(a, b) {
		if !skip_ui and cell_for_move != undefined {
			cell_for_move.remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
		}
		cell_for_move = b;
		if cell_for_move == undefined {
			cell_for_move = global.cell_click_callback;
		}
		if !skip_ui {
			cell_for_move.add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
			O_BoardDraw.unblock_end_button();
		}
	}
	
	draw = function() {
		if global.cell_click_callback != using_cell{
			draw_sprite_ext(figure_sprite, using_cell.filled_figure.image, Game.field.get_cell_xy(cell_for_move)[0], 
			Game.field.get_cell_xy(cell_for_move)[1], 
			Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
		}
		if draw_previous_cell and previous_move_cell != undefined{
			var _draw_x = Game.field.get_cell_xy(previous_move_cell)[0];
			var _draw_y = Game.field.get_cell_xy(previous_move_cell)[1];
			draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.7);
		}
		
	}
	
	check_ability_targets = function(a, b) {
		if Game.field.get_cell(using_cell.xcord + 1, using_cell.ycord) != undefined and 
		Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord) != undefined {
			if !Game.field.get_cell(using_cell.xcord + 1, using_cell.ycord).is_filled() and 
			!Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord).is_filled() {
				Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord).marked = 1;
			}
		}
		if Game.field.get_cell(using_cell.xcord - 1, using_cell.ycord) != undefined and 
		Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord) != undefined {
			if !Game.field.get_cell(using_cell.xcord - 1, using_cell.ycord).is_filled() and 
			!Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord).is_filled() {
				Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord).marked = 1;
			}
		}	
		if Game.field.get_cell(using_cell.xcord, using_cell.ycord + 1) != undefined and 
		Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2) != undefined {
			if !Game.field.get_cell(using_cell.xcord, using_cell.ycord + 1).is_filled() and 
			!Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2).is_filled() {
				Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2).marked = 1;
			}
		}
		if Game.field.get_cell(using_cell.xcord, using_cell.ycord - 1) != undefined and 
		Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2) != undefined {
			if !Game.field.get_cell(using_cell.xcord, using_cell.ycord - 1).is_filled() and 
			!Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2).is_filled() {
				Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2).marked = 1;
			}
		}
		var _previous_cell = Game.field.check_movement_array(using_figure.figure_id);
		if _previous_cell != undefined{ 
			if _previous_cell.is_marked() {
				draw_previous_cell = 1;
				_previous_cell.marked = 0
				previous_move_cell = _previous_cell
				draw_cell = function() {
					var _draw_x = Game.field.get_cell_xy(previous_move_cell)[0];
					var _draw_y = Game.field.get_cell_xy(previous_move_cell)[1];
					draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.7);
					if Game.game_loop_controller.have_action() {
						var _draw_index = array_get_index(Game.do_every_step_list, draw_cell);
						if _draw_index != -1 {
							array_delete(Game.do_every_step_list, _draw_index, 1);
						}
					}
				}
				if !skip_ui and !Game.game_loop_controller.have_action()
				and Game.game_loop_controller.state == STATE_LIST.figure_ability{array_push(Game.do_every_step_list, draw_cell)}
			}
		}
	}
	
	
	back = function() {
		if skip_ui {
			cell_for_move = undefined;
			return;
		}
		if global.cell_click_callback != global.selected_cell {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback.remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
			global.cell_click_callback = using_cell;
			O_BoardDraw.block_end_button();
		}
		else {
			Game.game_loop_controller.quit_from_action()
		}
	}
	
	export = function() {
		export_data = {
			ex_action : SpearmanAbility,
			ex_type : "act_ability",
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_cell_for_move: [cell_for_move.xcord, cell_for_move.ycord],
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	
	import = function(import_data) {
		//using_figure = import_data.ex_using_figure;
		using_cell = Game.field.get_cell(import_data.ex_using_cell[0], import_data.ex_using_cell[1]);
		cell_for_move = Game.field.get_cell(import_data.ex_cell_for_move[0], import_data.ex_cell_for_move[1]);
		using_figure = using_cell.filled_figure;
	}
}
