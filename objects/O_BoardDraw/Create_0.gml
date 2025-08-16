/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_game = 1
selected_cell = undefined
game_state = undefined
main_button_x = [room_width/2-40, room_width/2+40];
main_button_y = [room_height/1.25-40, room_height/1.25+20];
end_button_x = [room_width/2-55, room_width/2 + 50];
end_button_y = [room_height/1.25+35, room_height/1.25+80];
move_button_x = [room_width/2-100, room_width/2 -40];
move_button_y = [room_height/1.25-30, room_height/1.25+30];
ability_button_x = [room_width/2+55, room_width/2 +115];
ability_button_y = [room_height/1.25-30, room_height/1.25+30];
drop_cord = [room_width/2 - 250, room_height/2-40];
capture_cord = [room_width/2 + 195, room_height/2-40];
turn_owner_cord = [room_width/1.85, room_height/6.45];
end_button = false;
button_overlay_sprite = undefined;
button_overlay_subimg = 0;
button_overlay_scale = 1;
main_button = undefined;
move_button = undefined;
ability_button = undefined;

get_button_on_ui = function(_layer, _panel) {
	var _l = layer_get_flexpanel_node(_layer);
	var _p = flexpanel_node_get_child(_l, _panel);
	return _p
}

main_button = get_button_on_ui("GameRoom", "MainButton");
flexpanel_delete_node(main_button, 1)

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
	/*array_length(Game.field.player1_captured.figures)*/Game.game_loop_controller.player1_captured, 0.65, 0.6, 0);
	draw_text_transformed(capture_cord[0] + 25, capture_cord[1] - 43, 
	/*array_length(Game.field.player2_captured.figures)*/Game.game_loop_controller.player2_captured, 0.65, 0.6, 0);
}

figure_counters_draw = function() {
	//drop_draw();
	//capture_draw();
	draw_text_transformed(drop_cord[0], drop_cord[1], "СБРОС", 0.55, 0.55, 0);
	draw_text_transformed(capture_cord[0], capture_cord[1], "ПЛЕН", 0.55, 0.55, 0);
}

turn_owner_draw = function() {
	draw_text_transformed(turn_owner_cord[0], turn_owner_cord[1], 
	("Ход игрока " + string(1+1*(global.turn_owner == Game.Player2.player_id))), 0.65, 0.65, 0);
}

clear_button_overlay = function() {
	button_overlay_sprite = undefined;
	button_overlay_subimg = 0;
}

set_button_overlay = function(_sprite, _subimg = 0) {
	button_overlay_sprite = _sprite;
	button_overlay_subimg = _subimg;
	button_overlay_scale = (main_button_x[1] - main_button_x[0])/sprite_get_width(_sprite)
}

clear = function() {
	clear_button_overlay();
	block_end_button();
}

Game.init();