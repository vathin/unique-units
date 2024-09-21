/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if draw_previous_cell {
	draw_sprite_ext(S_cycle_rule, 0, move_from.filled_figure.previous_move_cell.x, 
	move_from.filled_figure.previous_move_cell.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1)
}