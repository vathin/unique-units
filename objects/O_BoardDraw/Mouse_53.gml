/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

selected_cell = Game.field.check_click()
if selected_cell != undefined {
	global.cell_action(selected_cell)
}
else {
	if mouse_x > room_width/2-45 and mouse_x < room_width/2+45 and mouse_y > room_height/1.25-45 and mouse_y < room_height/1.25+45 {
		if game_state == STATE_LIST.wait{
			show_debug_message("summon")
			Game.summon_controller = new SummonInputController()
		}
		if game_state == STATE_LIST.summon and global.cell_click_callback != undefined {
			Game.game_loop_controller.action.back()
		}
	}
	
}
