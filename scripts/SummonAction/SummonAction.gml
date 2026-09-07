
function SummonAction(_target_x, _target_y, _figure_sprite, _behaviour, _skip_ui=false) : Action() constructor{
	type = "summon"
	skip_ui = _skip_ui;
	target_x = _target_x;
	target_y = _target_y;
	figure_sprite = _figure_sprite;
	summon_figure = _behaviour;
	if !skip_ui {
		O_BoardDraw.clear_button_overlay();
		O_BoardDraw.unblock_end_button();
	}
	//O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
	//O_SummonButton.back = 1;

	execute = function() {
		if target_x == undefined or target_y == undefined {
			show_debug_message("SummonAction.execute skipped: target is undefined, figure=" + string(summon_figure));
			return;
		}
		if Game.field.get_cell(target_x, target_y) == undefined {
			show_debug_message("SummonAction.execute skipped: invalid target x=" + string(target_x) + ", y=" + string(target_y) + ", figure=" + string(summon_figure));
			return;
		}
		Game.field.create_figure(summon_figure, target_x, target_y, 1)
		//new_figure = new Figure()
		//new_figure.set_behaviour(summon_figure)
		//Game.field.get_cell(target_x, target_y).fill(new_figure)
		//Game.game_loop_controller.figures_counter.change_field_figures_amount(global.turn_owner, 1)
	}
	draw = function() {
		if target_x != undefined {
			var _target_cell = Game.field.get_cell(target_x, target_y);
			if _target_cell == undefined {
				return;
			}
			var _enemy_side = (Game.local_player != undefined && global.turn_owner != Game.local_player.player_id);
			draw_sprite_ext(figure_sprite, _enemy_side, Game.field.get_cell_xy(_target_cell)[0],
			Game.field.get_cell_xy(_target_cell)[1],
			Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
			cords = Game.field.get_cell_xy(_target_cell)
		}
	}

	Button_set_overlay = function() {
		if skip_ui {
			return;
		}
		O_BoardDraw.set_button_overlay(Behaviours.get_sprite(summon_figure), 0)
		if Game.game_loop_controller.state != STATE_LIST.summon or Game.game_loop_controller.action.target_x != undefined {
			var _overlay_index = array_get_index(Game.do_every_step_list, Button_set_overlay);
			if _overlay_index != -1 {
				array_delete(Game.do_every_step_list, _overlay_index, 1)
			}
			O_BoardDraw.clear_button_overlay()
			}
	}

	set_new_target_coordinates = function(_new_x, _new_y) {
		var _target_cell = Game.field.get_cell(_new_x, _new_y);
		if _target_cell == undefined {
			show_debug_message("SummonAction.set_new_target_coordinates skipped: invalid target x=" + string(_new_x) + ", y=" + string(_new_y));
			return;
		}
		target_x = _new_x;
		target_y = _new_y;
		if !skip_ui {
			O_BoardDraw.unblock_end_button();
			O_BoardDraw.clear_button_overlay();
			_target_cell.add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned));
		}
		//O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
		//O_SummonButton.back = 1;
	}

	back = function() {
		if skip_ui {
			target_x = undefined;
			target_y = undefined;
			return;
		}
		if target_x != undefined {
			Game.field.get_cell(target_x, target_y).marked = 1;
			Game.field.get_cell(target_x, target_y).remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned))
			target_x = undefined;
			target_y = undefined;
			//O_SummonButton.change_sprite(figure_sprite, Settings.summon_button_figure_scale);
			//O_SummonButton.back = 0;
			global.cell_click_callback = undefined;
			O_BoardDraw.clear();
			var _enemy_side = (Game.local_player != undefined && global.turn_owner != Game.local_player.player_id);
			O_BoardDraw.set_button_overlay(Behaviours.get_sprite(summon_figure), _enemy_side)
			array_push(Game.do_every_step_list, Button_set_overlay);
		}
	}

	export = function() {
		export_data = {
			ex_action: SummonAction,
			ex_type: "summon",
			ex_target_x: target_x,
			ex_target_y: target_y,
			ex_turn_owner: global.turn_owner,
			ex_summon_figure: summon_figure
		}
		return export_data
	}

	import = function(_import_data) {
		target_x = _import_data.ex_target_x;
		target_y = _import_data.ex_target_y;
		summon_figure = _import_data.ex_summon_figure;
	}
}

