selected_cell = Game.field.check_click()
if game_state != STATE_LIST.enemy_turn {
	if selected_cell != undefined {
		global.cell_action(selected_cell);
	}
}
Game.field.check_status();