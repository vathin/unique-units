/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if global.selected_cell != undefined and global.selected_cell == self and global.cell_click_callback != undefined{
	draw_sprite_ext(S_Back_chosen, 0, x, y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
}

if marked and draw_mark {
	draw_sprite(global.mark, -1, x, y)
}