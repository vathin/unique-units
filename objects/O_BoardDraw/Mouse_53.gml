selected_cell = Game.field.check_click()
if !Game.game_loop_controller.is_turn_transition_active() and Game.game_loop_controller.is_human_turn() and game_state != STATE_LIST.enemy_turn {
	if selected_cell != undefined {
		Game.input_session.click(selected_cell);
	}
}
