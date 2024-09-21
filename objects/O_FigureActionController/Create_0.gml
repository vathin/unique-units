/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

buttons_visiblity = 1;
create_buttons = function() {
	move_button = instance_create_depth(762, 1090, 0, O_MoveButton);
	ability_button = instance_create_depth(917, 1090, 0, O_AbilityButton);
}
create_buttons();
if !Behaviours.have_ability(global.selected_cell.filled_figure.behaviour) {
	instance_destroy(ability_button)
	move_button.x = 840;
	move_button.y = 1169;
	move_button.image_xscale = 1.35;
	move_button.image_yscale = 1.35;
	}
O_SummonButton.go_away();
move_and_ability = false;

figure_ability = Behaviours.get_ablility(global.selected_cell.filled_figure.behaviour);
if figure_ability != undefined {
	test_ability = new figure_ability(global.selected_cell.filled_figure, global.selected_cell);
	test_ability.check_ability_targets(1, 1);
	if !O_GameField.is_any_cell_marked() {ability_button.block()}
	O_GameField.clear_all_marks()
}


if Behaviours.get_move_ability(global.selected_cell.filled_figure.behaviour) == ArcherMoveAbility {
	ability = new ArcherMoveAbility(global.selected_cell.xcord, global.selected_cell.ycord, undefined, undefined, 0)
	if !ability.check_clear_cells(undefined, undefined) {move_button.block()}
}
//O_EndTurn.unblock();

move_figure = function() {	
	clear_buttons();
	O_SummonButton.block();
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
		O_EndTurn.block();
		O_GameLoopController.action.using_ability = 1;
		O_GameField.clear_all_marks();
		global.mark = S_Ability_mark;
		O_GameLoopController.action.check_ability_targets(1, 1);
		O_GameLoopController.action.figure_controller = undefined;
		O_SummonButton.alarm[0] = 1;
		instance_destroy();
	}
}

clear_buttons = function() {
	O_SummonButton.go_to_standart_mode();
	if instance_exists(ability_button) {instance_destroy(ability_button);}
	if instance_exists(move_button) {instance_destroy(move_button);}
}

switch_figure = function() {
	clear_buttons();
	O_GameLoopController.clean_controllers();
	instance_destroy();
}

back = function() {
	if !move_and_ability{
		O_GameLoopController.clear_all();
	}
}

revert_move_and_ability = function() {
	global.using_ability = 0;
	global.moving_figure = 1;
	O_GameLoopController.action.using_ability = 0;
	O_GameField.clear_all_marks();
	global.mark = S_Move_mark;
}
set_buttons_alpha = function(alpha) {
	if instance_exists(move_button) {move_button.image_alpha = alpha}
	if instance_exists(ability_button) {ability_button.image_alpha = alpha}
	if alpha > 0 {buttons_visiblity = 1}
	else buttons_visiblity = 0
}

if !(global.using_ability or global.moving_figure) {
	global.cell_action = function(cell) {
		if O_GameLoopController.cell_is_playable(cell) {
			O_FigureActionController.switch_figure();
		}
		O_GameLoopController.default_cell_click_action(cell);
	}
}