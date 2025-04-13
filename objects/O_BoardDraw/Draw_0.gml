/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if in_game {
	Game.do_every_step(Game.do_every_step_list)
	if selected_cell != undefined {
		draw_sprite_ext(S_Summon_mark, 0, Game.field.get_cell_xy(selected_cell)[0], Game.field.get_cell_xy(selected_cell)[1], 
		Game.field.scale, Game.field.scale, 0, c_white, 1)
	}
}
