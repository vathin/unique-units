/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active and position_meeting(mouse_x, mouse_y, self){
if (global.moving_figure) {
	O_GameField.move_figure(global.selected_cell.xcord, global.selected_cell.ycord, O_GameField.cell_for_move.xcord,
	O_GameField.cell_for_move.ycord, global.chosen_figure);
	clear_all();
    }
if (global.able_to_summon) {
	global.selected_cell.create_figure(global.selected_cell.x, global.selected_cell.y, global.figure_to_summon)
	}
}