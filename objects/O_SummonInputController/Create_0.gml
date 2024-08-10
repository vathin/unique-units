/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе


O_SummonButton.change_sprite(Behaviours.get_sprite(global.figure_to_summon), Settings.summon_button_figure_scale);
global.mark = S_Summon_mark

start_summon = function(target_x, target_y) {
	O_GameLoopController.set_action(new SummonAction(target_x, target_y, Behaviours.get_sprite(global.figure_to_summon)));
	instance_destroy();
}