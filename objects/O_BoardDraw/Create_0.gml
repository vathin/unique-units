/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_game = false
selected_cell = undefined
game_state = undefined
main_button_x = [room_width/2-40, room_width/2+40]
main_button_y = [room_height/1.25-40, room_height/1.25+40]
end_button_x = [room_width/2-55, room_width/2 + 50]
end_button_y = [room_height/1.25, room_height/1.25+80]
move_button_x = [room_width/2-100, room_width/2 -40]
move_button_y = [room_height/1.25-30, room_height/1.25+30]
ability_button_x = [room_width/2+55, room_width/2 +115]
ability_button_y = [room_height/1.25-30, room_height/1.25+30]
end_button = false


figure_click = function(_figure) {
		if _figure.state.is_active {
			game_state = Game.game_loop_controller.get_game_state()
			if game_state == STATE_LIST.wait {
				global.selected_cell = global.cell_click_callback;
				Game.figure_action_controller = new FigureActionController()
			}
			else{
				if (game_state == STATE_LIST.figure_move or game_state == STATE_LIST.figure_action) and !global.cell_click_callback.is_filled(){
					if Game.game_loop_controller.have_action() {
						Game.game_loop_controller.action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
					}
					else {
						Game.move_input_controller.start_move(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
					}
				}
				if game_state == STATE_LIST.figure_ability {
					if Game.game_loop_controller.have_action() {
						Game.game_loop_controller.action.set_target(_figure, global.cell_click_callback);
					}
					else {
						Game.ability_input_controller.start_ability();
						Game.game_loop_controller.action.set_target(_figure, global.cell_click_callback);
					}
				}
			}
		}
	}
	
block_end_button = function() {
	end_button = false
}

unblock_end_button = function() {
	end_button = true
}

Start_match()
