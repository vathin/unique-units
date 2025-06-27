/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if in_game {
	Game.do_every_step(Game.do_every_step_list)
	/*if selected_cell != undefined {
		draw_sprite_ext(S_Summon_mark, 0, Game.field.get_cell_xy(selected_cell)[0], Game.field.get_cell_xy(selected_cell)[1], 
		Game.field.scale, Game.field.scale, 0, c_white, 1)
	}*/
	draw_set_font(F_test)
	

	if end_button {
		draw_text_transformed(room_width/2-50, room_height/1.25+40, "закончить ход", 0.55, 0.55, 0);
	}
	if Game.game_loop_controller.can_cancel {
		draw_text_transformed(room_width/2-23, room_height/1.25-10, "отмена", 0.55, 0.55, 0);
	}
	switch game_state{
	case STATE_LIST.wait:
		draw_text_transformed(room_width/2-27, room_height/1.25-10, "призыв", 0.55, 0.55, 0);
		break;
	case STATE_LIST.figure_action:
		if Game.figure_action_controller.figure_can_move {
			draw_text_transformed(move_button_x[0] + 10, move_button_y[0] + 20, "передв.", 0.55, 0.55, 0);
		}
		if Game.figure_action_controller.figure_have_ability{
			draw_text_transformed(ability_button_x[0] + 10, ability_button_y[0] + 20, "способ.", 0.55, 0.55, 0);
		}
		break;
	case STATE_LIST.summon:
		if global.cell_click_callback != undefined {
			draw_text_transformed(room_width/2-27, room_height/1.25-10, "отмена", 0.55, 0.55, 0);
		}
		break;
	}
	
}
