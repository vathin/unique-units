/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
set_new_cell_action = function() {
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
}
set_new_cell_action();

O_SummonButton.change_sprite(S_AbilityButton, 1.63);
global.mark = S_Ability_mark;
global.using_ability = 1;
using_figure = global.selected_cell.filled_figure;
create_ability = using_figure.get_ability();
ability = new create_ability(using_figure, global.selected_cell);
ability.check_ability_targets(1, 1);
if O_GameLoopController.can_cancel {
	O_SummonButton.alarm[0] = 1;
}


start_ability = function() {
	O_GameLoopController.set_action(ability);
	instance_destroy();
}

back = function() {
	if O_GameLoopController.can_cancel {
		O_GameField.clear_all_marks();
		global.cell_click_callback = global.selected_cell;
		instance_create_depth(0, 0, 0, O_FigureActionController);
		O_SummonButton.go_away();
		global.using_ability = 0;
		instance_destroy();
	}
}