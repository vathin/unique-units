/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе


if marked_for_move and not ready_for_move {
	draw_sprite(S_Move_mark, -1, self.x, self.y);
}
if ready_for_move {
	draw_sprite_ext(global.chosen_figure.sprite_index, -1, self.x, self.y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.45)
}
if global.selected_cell = self and global.able_to_summon{
	O_GameLoopController.action.draw()
}
//if marked_for_summon and not ready_for_summon {
//	draw_sprite(S_Summon_mark, -1, self.x, self.y);
//}