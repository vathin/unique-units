/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

global.figure_to_summon = Behaviours.get("spearman")//Behaviours.get_random_figure();
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

start_summon = function(target_x, target_y) {
	O_GameLoopController.set_action(new SummonAction(target_x, target_y, Behaviours.get_sprite(global.figure_to_summon)));
	instance_destroy();
}
