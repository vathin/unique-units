/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if in_game {
	Game.do_every_step(Game.do_every_step_list)
	/*if selected_cell != undefined {
		draw_sprite_ext(S_Summon_mark, 0, Game.field.get_cell_xy(selected_cell)[0], Game.field.get_cell_xy(selected_cell)[1], 
		Game.field.scale, Game.field.scale, 0, c_white, 1)
	}*/
	draw_set_font(F_test)
	
	game_state = Game.game_loop_controller.get_game_state()
	switch game_state{
	case STATE_LIST.wait:
		draw_text_transformed(room_width/2-27, room_height/1.25-10, "призыв", 0.55, 0.55, 0)
	case STATE_LIST.summon:
		if global.cell_click_callback != undefined {
			draw_text_transformed(room_width/2-27, room_height/1.25-10, "отмена", 0.55, 0.55, 0)
			draw_text_transformed(room_width/2+50, room_height/1.25-10, "закончить ход", 0.55, 0.55, 0)
		}
		
	}
}
