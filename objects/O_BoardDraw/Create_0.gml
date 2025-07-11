/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_game = false
selected_cell = undefined
game_state = undefined
main_button_x = [room_width/2-40, room_width/2+40];
main_button_y = [room_height/1.25-40, room_height/1.25+40];
end_button_x = [room_width/2-55, room_width/2 + 50];
end_button_y = [room_height/1.25+35, room_height/1.25+80];
move_button_x = [room_width/2-100, room_width/2 -40];
move_button_y = [room_height/1.25-30, room_height/1.25+30];
ability_button_x = [room_width/2+55, room_width/2 +115];
ability_button_y = [room_height/1.25-30, room_height/1.25+30];
drop_cord = [room_width/2 - 250, room_height/2-40];
capture_cord = [room_width/2 + 195, room_height/2-40];
turn_owner_cord = [room_width/1.85, room_height/6.45];
end_button = false


figure_click = function(_figure) {
		if _figure.state.is_active {
			game_state = Game.game_loop_controller.get_game_state()
			if game_state == STATE_LIST.wait {
				global.selected_cell = global.cell_click_callback;
				Game.field.clear_all_marks();
				Game.figure_action_controller = new FigureActionController()
			}
			else{
				if (game_state == STATE_LIST.figure_move or game_state == STATE_LIST.figure_action) and !global.cell_click_callback.is_filled(){
					if Game.game_loop_controller.have_action() {
						Game.game_loop_controller.action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
					}
					else if (Game.move_input_controller != undefined){
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

drop_draw = function() {
	draw_text_transformed(drop_cord[0] + 25, drop_cord[1] + 40, 
	array_length(Game.field.player1_dropped.figures), 0.65, 0.6, 0);
	draw_text_transformed(drop_cord[0] + 25, drop_cord[1] - 43,
	array_length(Game.field.player2_dropped.figures), 0.65, 0.6, 0);
}

capture_draw = function() {
	draw_text_transformed(capture_cord[0] + 25, capture_cord[1] + 40, 
	array_length(Game.field.player1_captured.figures), 0.65, 0.6, 0);
	draw_text_transformed(capture_cord[0] + 25, capture_cord[1] - 43, 
	array_length(Game.field.player2_captured.figures), 0.65, 0.6, 0);
}

figure_counters_draw = function() {
	drop_draw();
	capture_draw();
	draw_text_transformed(drop_cord[0], drop_cord[1], "СБРОС", 0.55, 0.55, 0);
	draw_text_transformed(capture_cord[0], capture_cord[1], "ПЛЕН", 0.55, 0.55, 0);
}

turn_owner_draw = function() {
	draw_text_transformed(turn_owner_cord[0], turn_owner_cord[1], 
	("Ход игрока " + string_char_at(global.turn_owner, string_length(global.turn_owner))), 0.65, 0.65, 0);
}

Start_match()
