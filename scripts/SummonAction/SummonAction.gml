
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
		new_figure = new Figure()
		new_figure.set_behaviour(summon_figure)
		Game.field.get_cell(target_x, target_y).fill(new_figure)
		Game.game_loop_controller.figures_counter.change_field_figures_amount(global.turn_owner, 1)
	}
	draw = function() {
		if target_x != undefined {
			draw_sprite_ext(figure_sprite, (global.turn_owner==Game.Player2.player_id), Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))[0],
			Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))[1], 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			cords = Game.field.get_cell_xy(Game.field.get_cell(target_x, target_y))
			//draw_text_transformed(cords[0], cords[1], string_char_at(summon_figure,1)+string_char_at(summon_figure, 2), 0.5, 0.5, 0)
		}
	}
	set_new_target_coordinates = function(_new_x, _new_y) {
		target_x = _new_x;
		target_y = _new_y;
		O_BoardDraw.unblock_end_button();
		O_BoardDraw.clear_button_overlay();
		//O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
		//O_SummonButton.back = 1;
	}
	
	back = function() {
		if target_x != undefined {
			Game.field.get_cell(target_x, target_y).marked = 1;
			target_x = undefined;
			target_y = undefined;
			//O_SummonButton.change_sprite(figure_sprite, Settings.summon_button_figure_scale);
			//O_SummonButton.back = 0;
			global.cell_click_callback = undefined;
			O_BoardDraw.clear();
			O_BoardDraw.set_button_overlay(Behaviours.get_sprite(summon_figure), (global.turn_owner==Game.Player2.player_id))
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

