/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) and global.selected_cell.filled_figure.able_to_move {
	O_FigureActionController.move_figure()
}