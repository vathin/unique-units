/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_game = false
selected_cell = undefined
game_state = undefined
main_button_x = [room_width/2-40, room_width/2+40]
main_button_y = [room_height/1.25-40, room_height/1.25+40]
end_button_x = [room_width/2 + 50, room_width/2 + 130]
end_button_y = [room_height/1.25-40, room_height/1.25+40]

figure_click = function(_figure) {
		if _figure.state.is_active {
			game_state = Game.game_loop_controller.get_game_state()
			if game_state == STATE_LIST.wait {
				global.selected_cell = global.cell_click_callback;
				Game.figure_action_controller = new FigureActionController()
			}
			else{
				if game_state == STATE_LIST.figure_move and !global.cell_click_callback.is_filled(){
					if Game.game_loop_controller.have_action() {
						Game.game_loop_controller.action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
					}
					else {
						Game.move_input_controller.start_move(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
					}
				}
				if global.using_ability {
					if Game.game_loop_controller.have_action() {
						Game.game_loop_controller.action.set_target(self, global.cell_click_callback);
					}
					else {
						Game.ability_input_controller.start_ability();
						Game.game_loop_controller.action.set_target(self, global.cell_click_callback);
					}
				}
			}
		}
	}

Start_match()
