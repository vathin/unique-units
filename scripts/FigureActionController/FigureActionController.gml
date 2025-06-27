// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureActionController() constructor{
	buttons_visiblity = 1;
	figure_have_ability = 1;
	figure_can_move = 1
	Game.game_loop_controller.state = STATE_LIST.figure_action
	if !Behaviours.have_ability(global.selected_cell.filled_figure.behaviour) {
		figure_have_ability = 0;
		//move_button.x = 840;
		//move_button.y = 1169;
		//move_button.image_xscale = 1.25;
		//move_button.image_yscale = 1.25;
		}
	//O_SummonButton.go_away();
	move_and_ability = false;

	figure_ability = Behaviours.get_ablility(global.selected_cell.filled_figure.behaviour);
	if figure_ability != undefined {
		test_ability = new figure_ability(global.selected_cell.filled_figure, global.selected_cell);
		test_ability.check_ability_targets(1, 1);
		if !Game.field.is_any_cell_marked() {figure_have_ability = 0}
		Game.field.clear_all_marks()
	}


	if Behaviours.get_move_ability(global.selected_cell.filled_figure.behaviour) == ArcherMoveAbility {
		ability = new ArcherMoveAbility(global.selected_cell.xcord, global.selected_cell.ycord, undefined, undefined, 0)
		if !ability.check_clear_cells(undefined, undefined) {figure_can_move = 0}
	}
	//O_BoardDraw.unblock_end_button();
	
	destroy_self = function() {
		Game.figure_action_controller = undefined
	}
	
	move_figure = function() {	
		if figure_can_move{
			Game.move_input_controller = new MoveInputController();
			destroy_self();
		}
	}

	use_ability = function() {
		if figure_have_ability{
			if !move_and_ability {
				Game.ability_input_controller = new AbilityInputController();
			}
			else {
				global.moving_figure = 0;
				global.using_ability = 1;
				Game.game_loop_controller.action.using_ability = 1;
				Game.field.clear_all_marks();
				global.mark = S_Ability_mark;
				Game.game_loop_controller.action.check_ability_targets(1, 1);
				Game.game_loop_controller.state = STATE_LIST.figure_ability;
				Game.ability_input_controller = new AbilityInputController();
				Game.ability_input_controller = undefined;
				O_BoardDraw.block_end_button();
			}
			destroy_self();
		}
	}

	switch_figure = function() {
		Game.game_loop_controller.clean_controllers();
		destroy_self()
	}

	back = function() {
		if !move_and_ability{
			Game.game_loop_controller.clear_all();
		}
	}

	revert_move_and_ability = function() {
		Game.game_loop_controller.state = STATE_LIST.figure_move
		Game.game_loop_controller.action.using_ability = 0;
		Game.field.clear_all_marks();
		global.mark = S_Move_mark;
	}

	if (Game.game_loop_controller.get_game_state() == STATE_LIST.figure_action) {
		global.cell_action = function(cell) {
			if Game.game_loop_controller.cell_is_playable(cell) {
				switch_figure();
			}
			Game.game_loop_controller.default_cell_click_action(cell);
		}
	}
}