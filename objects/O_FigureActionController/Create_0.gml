/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
move_button = instance_create_depth(762, 1090, 0, O_MoveButton);
ability_button = instance_create_depth(917, 1090, 0, O_AbilityButton);
if !Behaviours.have_ability(global.selected_cell.filled_figure.behaviour) {ability_button.block()}
O_SummonButton.go_away();
move_and_ability = false;


figure_ability = Behaviours.get_ablility(global.selected_cell.filled_figure.behaviour);
if figure_ability != undefined {
	test_ability = new figure_ability(global.selected_cell.filled_figure, global.selected_cell);
	test_ability.check_ability_targets(1, 1);
	if !O_GameField.is_any_cell_marked() {ability_button.block()}
	O_GameField.clear_all_marks()
}

if Behaviours.get_move_ability(global.selected_cell.filled_figure.behaviour) = ArcherMoveAbility {
	ability = new ArcherMoveAbility(global.selected_cell.xcord, global.selected_cell.ycord, undefined, undefined, 0)
	if !ability.check_clear_cells(undefined, undefined) {move_button.block()}
}
O_EndTurn.active = 1;

move_figure = function() {	
	clear_buttons();
	O_SummonButton.block();
	if Behaviours.get_move_ability(global.selected_cell.filled_figure.behaviour) = ArcherMoveAbility {ability.check_all_cells()}
	else {O_GameField.check_clear_move_cells(global.cell_click_callback.xcord, global.cell_click_callback.ycord);}
	instance_create_depth(0, 0, 0, O_MoveInputController);
	instance_destroy();
	
}

use_ability = function() {
	if !move_and_ability {
		clear_buttons();
		O_SummonButton.block();
		instance_create_depth(0, 0, 0, O_AbilityInputController);
		instance_destroy();
	}
	else {
		global.moving_figure = 0;
		global.using_ability = 1;
		clear_buttons();
		O_SummonButton.block();
		O_GameLoopController.action.using_ability = 1;
		O_GameField.clear_all_marks();
		global.mark = S_Ability_mark;
		O_GameLoopController.action.check_ability_targets(1, 1);
		instance_destroy();
	}
}

clear_buttons = function() {
	O_SummonButton.go_to_standart_mode();
	instance_destroy(ability_button);
	instance_destroy(move_button);
}