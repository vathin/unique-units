/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

O_GameLoopController.set_can_cancel(0);
load_data = O_App.data.load(global.turn_owner);
global.figure_to_summon = array_pop(load_data.player_figures)
O_App.data.save(global.turn_owner, load_data)
O_SummonButton.change_sprite(Behaviours.get_sprite(global.figure_to_summon), Settings.summon_button_figure_scale);
global.mark = S_Summon_mark;
O_GameField.check_controlled_summon_cells(global.turn_owner);
global.able_to_summon = true;
global.cell_action = function(cell) {
	if (cell.marked) {
		global.cell_click_callback = cell;
		O_GameLoopController.choose_cell_for_summon();
	}	
}

time_end = function() {
	drop_figure = instance_create_depth(O_SummonButton.x, O_SummonButton.y, -1, O_Figure);
	drop_figure.set_behaviour(global.figure_to_summon);
	drop_figure.drop();
	instance_destroy();
}

start_summon = function(target_x, target_y) {
	O_GameLoopController.set_action(new SummonAction(target_x, target_y, Behaviours.get_sprite(global.figure_to_summon)));
	instance_destroy();
}
