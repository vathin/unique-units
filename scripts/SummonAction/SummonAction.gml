
function SummonAction(_target_x, _target_y, _figure_sprite, _behaviour) : Action() constructor{
	type = "summon"
	target_x = _target_x;
	target_y = _target_y;
	figure_sprite = _figure_sprite;
	summon_figure = _behaviour;
	O_BoardDraw.clear_button_overlay();
	O_BoardDraw.unblock_end_button();
	//O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
	//O_SummonButton.back = 1;
	
	execute = function() {
		Game.field.create_figure(summon_figure, target_x, target_y, 1)
		//new_figure = new Figure()
		//new_figure.set_behaviour(summon_figure)
		//Game.field.get_cell(target_x, target_y).fill(new_figure)
		//Game.game_loop_controller.figures_counter.change_field_figures_amount(global.turn_owner, 1)
	}
	draw = function() {
		if target_x != undefined {
			var _enemy_side = (Game.local_player != undefined && global.turn_owner != Game.local_player.player_id);
			draw_sprite_ext(figure_sprite, _enemy_side, Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))[0],
			Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))[1], 
			Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
			cords = Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))
		}
	}
	
	Button_set_overlay = function() {
		O_BoardDraw.set_button_overlay(Behaviours.get_sprite(summon_figure), 0)
		if Game.game_loop_controller.state != STATE_LIST.summon or Game.game_loop_controller.action.target_x != undefined {
			array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, Button_set_overlay), 1)
			O_BoardDraw.clear_button_overlay()
			}
	}
	
	set_new_target_coordinates = function(_new_x, _new_y) {
		target_x = _new_x;
		target_y = _new_y;
		O_BoardDraw.unblock_end_button();
		O_BoardDraw.clear_button_overlay();
		Game.field.get_cell(target_x, target_y).add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned));
		//O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
		//O_SummonButton.back = 1;
	}
	
	back = function() {
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

