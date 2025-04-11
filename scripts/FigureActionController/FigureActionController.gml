// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureActionController() constructor{
	buttons_visiblity = 1;
	create_buttons = function() {
		move_button = instance_create_depth(762, 1000, 0, O_MoveButton);
		ability_button = instance_create_depth(917, 1000, 0, O_AbilityButton);
	}
	create_buttons();
	if !Behaviours.have_ability(global.selected_cell.filled_figure.behaviour) {
		instance_destroy(ability_button)
		move_button.x = 840;
		move_button.y = 1169;
		move_button.image_xscale = 1.25;
		move_button.image_yscale = 1.25;
		}
	O_SummonButton.go_away();
	move_and_ability = false;

	figure_ability = Behaviours.get_ablility(global.selected_cell.filled_figure.behaviour);
	if figure_ability != undefined {
		test_ability = new figure_ability(global.selected_cell.filled_figure, global.selected_cell);
		test_ability.check_ability_targets(1, 1);
		if !Game.Field.is_any_cell_marked() {ability_button.block()}
		Game.Field.clear_all_marks()
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
			Game.Field.GameLoopController.action.using_ability = 1;
			Game.Field.clear_all_marks();
			global.mark = S_Ability_mark;
			GameClass.Field.GameLoopController.action.check_ability_targets(1, 1);
			GameClass.Field.GameLoopController.action.figure_controller = undefined;
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
		GameClass.Field.GameLoopController.clean_controllers();
		instance_destroy();
	}

	back = function() {
		if !move_and_ability{
			GameClass.Field.GameLoopController.clear_all();
		}
	}

	revert_move_and_ability = function() {
		global.using_ability = 0;
		global.moving_figure = 1;
		GameClass.Field.GameLoopController.action.using_ability = 0;
		GameClass.Field.clear_all_marks();
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
			if GameClass.Field.GameLoopController.cell_is_playable(cell) {
				switch_figure();
			}
			GameClass.Field.GameLoopController.default_cell_click_action(cell);
		}
	}
}