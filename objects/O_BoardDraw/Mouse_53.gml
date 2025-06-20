/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

selected_cell = Game.field.check_click()
if selected_cell != undefined {
	global.cell_action(selected_cell)
}
else {
	if mouse_x > main_button_x[0] and mouse_x < main_button_x[1] and mouse_y > main_button_y[0] and mouse_y < main_button_y[1] {
		if game_state == STATE_LIST.wait{
			Game.summon_controller = new SummonInputController()
		}
		if game_state == STATE_LIST.summon and global.cell_click_callback != undefined {
			Game.game_loop_controller.action.back()
		}
	}
	if mouse_x > end_button_x[0] and mouse_x < end_button_x[1] and mouse_y > end_button_y[0] and mouse_y < end_button_y[1]{
		if end_button{
			Game.game_loop_controller.end_move()
		}
	}
	if game_state == STATE_LIST.figure_action{
		if mouse_x > move_button_x[0] and mouse_x < move_button_x[1] and mouse_y > move_button_y[0] and mouse_y < move_button_y[1]{
			Game.figure_action_controller.move_figure();
		}
		if mouse_x > ability_button_x[0] and mouse_x < ability_button_x[1] and mouse_y > ability_button_y[0] and mouse_y < ability_button_y[1]{
			Game.figure_action_controller.use_ability();
		}
	}
	
	
}
