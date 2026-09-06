in_game = 1
selected_cell = undefined
game_state = undefined
width = display_get_gui_width();
height = display_get_gui_height();
drop_cord = [width/2 - 255, height/2-40];
capture_cord = [width/2 + 210, height/2-40];
turn_owner_cord = [width/1.85, height/7.5];
end_button = false;
button_overlay_sprite = undefined;
button_overlay_subimg = 0;
button_overlay_scale = 1;

update_layout = function() {
	width = display_get_gui_width();
	height = display_get_gui_height();
	var _scale = height/max(1, room_height);
	drop_cord = [width/2 - 255*_scale, height/2 - 40*_scale];
	capture_cord = [width/2 + 210*_scale, height/2 - 40*_scale];
	turn_owner_cord = [width/1.85, height/7.5];
}

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
	
cancel = function() {
	if (game_state == STATE_LIST.summon and global.cell_click_callback != undefined) or
	Game.game_loop_controller.can_cancel {
		if Game.game_loop_controller.have_action(){Game.game_loop_controller.action.back()}
		if Game.ability_input_controller != undefined {Game.ability_input_controller.back()}
		if Game.move_input_controller != undefined {Game.move_input_controller.back()}
		if Game.figure_action_controller != undefined {Game.figure_action_controller.back()}
	}
}

main_button_click = function() {
	if game_state == STATE_LIST.wait and 
		Game.game_loop_controller.get_player(global.turn_owner).able_to_summon {
		Game.summon_controller = new SummonInputController();
	}
	else {cancel()}
}

end_button_click = function() {
	if end_button{
		Game.game_loop_controller.end_move()
	}
}

move_button_click = function() {
	if Game.figure_action_controller != undefined {
		Game.figure_action_controller.move_figure();
	}
}

ability_button_click = function() {
	if Game.figure_action_controller != undefined {
		Game.figure_action_controller.use_ability();
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
	Game.game_loop_controller.player1_captured, 0.65, 0.6, 0);
	draw_text_transformed(capture_cord[0] + 25, capture_cord[1] - 43, 
	Game.game_loop_controller.player2_captured, 0.65, 0.6, 0);
}

figure_counters_draw = function() {
	//drop_draw();
	//capture_draw();
	var _font = draw_get_font();
	draw_set_font(F_menu);
	draw_text_transformed(drop_cord[0], drop_cord[1], "СБРОС", 0.55, 0.55, 0);
	draw_text_transformed(capture_cord[0], capture_cord[1], "ПЛЕН", 0.55, 0.55, 0);
	draw_set_font(_font);
}

turn_owner_draw = function() {
	draw_text_transformed(turn_owner_cord[0], turn_owner_cord[1], 
	("Ход игрока " + string(1+1*(global.turn_owner == Game.Player2.player_id))), 0.65, 0.65, 0);
}

clear_button_overlay = function() {
	UI_controller.clear_ingame_layer(1)
}

set_button_overlay = function(_sprite, _subimg = 0) {
	UI_controller.get_button_instance(UI_controller.main_button).set_sprite(_sprite, _subimg)
	UI_controller.get_button_instance(UI_controller.main_button).have_overlay = 1;
}

is_button_have_overlay = function() {
	if UI_controller.get_button_instance(UI_controller.main_button).have_overlay == 1 {return true}
	return false
}

clear = function() {
	clear_button_overlay();
	block_end_button();
}

Game.init();
