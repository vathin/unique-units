/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
global.cell_action = function(cell) {
	if cell.marked {
		global.cell_click_callback.set_draw_marks(1);
		global.cell_click_callback = cell;
		cell.set_draw_marks(0);
		if cell.is_filled() {cell.filled_figure.click()}
		else {
			if O_GameLoopController.have_action() {O_GameLoopController.action.set_target(cell)}
			else {
				O_AbilityInputController.start_ability()
				O_GameLoopController.action.set_target(cell)
				}
			}
	}
}

O_SummonButton.change_sprite(S_AbilityButton, 1.63);
global.mark = S_Ability_mark;
global.using_ability = 1;
using_figure = global.cell_click_callback.filled_figure;
create_ability = using_figure.get_ability()
ability = new create_ability(using_figure, global.cell_click_callback)
ability.check_ability_targets(1, 1)


start_ability = function() {
	O_GameLoopController.set_action(ability);
	instance_destroy();
}