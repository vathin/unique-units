/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if in_game {
	Game.do_every_step(Game.do_every_step_list)
	/*if selected_cell != undefined {
		draw_sprite_ext(S_Summon_mark, 0, Game.field.get_cell_xy(selected_cell)[0], Game.field.get_cell_xy(selected_cell)[1], 
		Game.field.scale, Game.field.scale, 0, c_white, 1)
	}*/
	draw_set_font(F_test)
	
	
	figure_counters_draw();
	turn_owner_draw();
	
	UI_controller.clear_ingame_layer();
	if Game.game_loop_controller.have_action() {
		Game.game_loop_controller.action.draw();
	}
	if end_button {
		//draw_text_transformed(room_width/2-50, room_height/1.25+40, "закончить ход", 0.55, 0.55, 0);
		UI_controller.set_button_frame(UI_controller.end_turn_button, SIDEBUTTONFRAMES.end_turn_active);
	}
	if Game.game_loop_controller.can_cancel {
		//draw_text_transformed(room_width/2-23, room_height/1.25-10, "отмена", 0.55, 0.55, 0);
		UI_controller.set_button_frame(UI_controller.cancel_button, SIDEBUTTONFRAMES.cancel_active)
	}
	switch game_state{
	case STATE_LIST.wait:
		UI_controller.turn_on_button(UI_controller.main_button);
		//draw_text_transformed(main_button_x[1] + 55, main_button_y[0] + 25,
		//("Доступно:" + string(Game.game_loop_controller.figures_counter.get_summon_figures_amount(global.turn_owner))),
		//0.75, 0.75, 0);
		if Game.game_loop_controller.get_player(global.turn_owner).able_to_summon {
			//draw_text_transformed(room_width/2-27, room_height/1.25-10, "призыв", 0.55, 0.55, 0);
			UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.can_summon);
		}
		break;
	case STATE_LIST.figure_action:
		UI_controller.turn_on_button(UI_controller.move_button);
		UI_controller.turn_on_button(UI_controller.ability_button);
		if Game.figure_action_controller.figure_can_move {
			//draw_text_transformed(move_button_x[0] + 10, move_button_y[0] + 20, "передв.", 0.55, 0.55, 0);
			UI_controller.set_button_frame(UI_controller.move_button, INGAMEBUTTONFRAMES.can_move);
		}
		if Game.figure_action_controller.figure_have_ability{
			//draw_text_transformed(ability_button_x[0] + 10, ability_button_y[0] + 20, "способ.", 0.55, 0.55, 0);
			UI_controller.set_button_frame(UI_controller.ability_button, INGAMEBUTTONFRAMES.can_use_ability)
		}
		break;
	case STATE_LIST.summon:
		UI_controller.turn_on_button(UI_controller.main_button);
		if global.cell_click_callback != undefined {
			UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.cancel);
		}
		break;
		case STATE_LIST.enemy_turn:
			UI_controller.turn_on_button(UI_controller.main_button);
			UI_controller.set_button_frame(UI_controller.main_button, INGAMEBUTTONFRAMES.opponent_turn);
		break;
	}
}
