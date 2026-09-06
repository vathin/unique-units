if in_game {
	update_layout();
	Game.do_every_step(Game.do_every_step_list)
	draw_set_font(F_test);
	
	Game.game_loop_controller.figures_counter.display_opponent_available_figures();
	
	UI_controller.clear_ingame_layer();
	/*if Game.game_loop_controller.have_action() {
		Game.game_loop_controller.action.draw();
	}*/
	if end_button {
		UI_controller.set_button_frame(UI_controller.end_turn_button, SIDEBUTTONFRAMES.end_turn_active);
	}
	if (game_state == STATE_LIST.summon and global.cell_click_callback != undefined) or
	Game.game_loop_controller.can_cancel {
		UI_controller.set_button_frame(UI_controller.cancel_button, SIDEBUTTONFRAMES.cancel_active)
	}
	switch game_state{
	case STATE_LIST.wait:
		UI_controller.turn_on_button(UI_controller.main_button);
		if Game.game_loop_controller.get_player(global.turn_owner).able_to_summon and !is_button_have_overlay() {
			UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.can_summon);
			Game.game_loop_controller.figures_counter.display_available_figures();
		}
		break;
	case STATE_LIST.figure_action:
		UI_controller.turn_on_button(UI_controller.move_button);
		UI_controller.turn_on_button(UI_controller.ability_button);
		if Game.figure_action_controller.figure_can_move {
			UI_controller.set_button_frame(UI_controller.move_button, INGAMEBUTTONFRAMES.can_move);
		}
		if Game.figure_action_controller.figure_have_ability {
			UI_controller.set_button_frame(UI_controller.ability_button, INGAMEBUTTONFRAMES.can_use_ability)
		}
		break;
	case STATE_LIST.summon:
		UI_controller.turn_on_button(UI_controller.main_button);
		if global.cell_click_callback != undefined and !is_button_have_overlay() {
			UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.cancel);
		}
		break;
	case STATE_LIST.enemy_turn:
			UI_controller.turn_on_button(UI_controller.main_button);
			if !is_button_have_overlay() {
				UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.opponent_turn);
			}
		break;
	}
}
