/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

move_button = instance_create_depth(762, 1090, 0, O_MoveButton);
ability_button = instance_create_depth(917, 1090, 0, O_AbilityButton);
O_SummonButton.go_away();
move_figure = function() {
	clear_buttons();
	O_SummonButton.block();
	O_GameField.check_clear_move_cells(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
	instance_create_depth(0, 0, 0, O_MoveInputController);
	instance_destroy();
}

use_ability = function() {
	clear_buttons();
	O_SummonButton.block();
	instance_create_depth(0, 0, 0, O_AbilityInputController);
	instance_destroy();
}

clear_buttons = function() {
	O_SummonButton.go_to_standart_mode();
	instance_destroy(ability_button);
	instance_destroy(move_button);
}