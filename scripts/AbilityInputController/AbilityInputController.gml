// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function AbilityInputController() constructor{
	set_new_cell_action = function() {
		global.cell_action = function(cell) {
			if cell.marked {
				global.cell_click_callback.set_draw_marks(1);
				global.cell_click_callback = cell;
				cell.set_draw_marks(0);
				if cell.is_filled() {O_BoardDraw.figure_click(cell.filled_figure)}
				else {
					if !Game.game_loop_controller.have_action() {Game.ability_input_controller.start_ability()}
					Game.game_loop_controller.action.set_target(cell)
				}
			}
		}
	}

	set_new_cell_action();

	start_ability = function() {
		Game.game_loop_controller.set_action(ability);
		Game.ability_input_controller = undefined;
		O_BoardDraw.unblock_end_button();
	}

	//O_SummonButton.change_sprite(S_AbilityButton, 1.63);
	global.mark = S_Ability_mark;
	Game.game_loop_controller.state = STATE_LIST.figure_ability;
	using_figure = global.selected_cell.filled_figure;
	create_ability = using_figure.get_ability();
	ability = new create_ability(using_figure, global.selected_cell);
	ability.check_ability_targets(1, 1);

	if Game.game_loop_controller.can_cancel {
		
	}

	back = function() {
		if Game.game_loop_controller.can_cancel {
			Game.field.clear_all_marks();
			global.cell_click_callback = global.selected_cell;
			Game.figure_action_controller = new FigureActionController()
			//O_SummonButton.go_away();
			Game.ability_input_controller = undefined;
		}
	}
}