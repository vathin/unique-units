/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

O_SummonButton.change_sprite(S_AbilityButton, 1.63);
global.mark = S_Ability_mark;
global.using_ability = 1;
using_figure = global.cell_click_callback.filled_figure;
create_ability = using_figure.get_ability()
ability = new create_ability(using_figure, global.cell_click_callback)
ability.check_ability_targets()
global.cell_action = function(cell) {
	if cell.marked {
		global.cell_click_callback.draw_mark = 1;
		global.cell_click_callback = cell;
		cell.draw_mark = 0;
		cell.filled_figure.click()
	}
}

start_ability = function() {
	O_GameLoopController.set_action(ability);
	instance_destroy();
}