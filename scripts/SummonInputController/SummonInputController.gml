// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function SummonInputController() constructor{
	Game.game_loop_controller.state = STATE_LIST.summon
	Game.game_loop_controller.set_can_cancel(0);
	load_data = Game.data.load(global.turn_owner);
	figure_to_summon = array_pop(load_data.player_figures)
	Game.data.save(global.turn_owner, load_data)
	//O_SummonButton.change_sprite(Behaviours.get_sprite(figure_to_summon), Settings.summon_button_figure_scale);
	global.mark = S_Summon_mark;
	Game.field.check_controlled_summon_cells(global.turn_owner);
	global.able_to_summon = true;
	global.cell_action = function(cell) {
		if (cell.marked) {
			global.cell_click_callback = cell;
			Game.field.set_selected_cell(cell)
			Game.game_loop_controller.choose_cell_for_summon();
		}	
	}

	time_end = function() {
		//drop_figure = instance_create_depth(O_SummonButton.x, O_SummonButton.y, -1, O_Figure);
		//drop_figure.set_behaviour(figure_to_summon);
		//drop_figure.drop();
		Game.summon_controller = undefined
	}

	start_summon = function(target_x, target_y) {
		Game.game_loop_controller.set_action(new SummonAction(target_x, target_y, Behaviours.get_sprite(figure_to_summon), figure_to_summon));
		Game.summon_controller = undefined
	}
}