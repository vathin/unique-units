/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

O_SummonButton.change_sprite(S_Move_active, 1.63);
global.moving_figure = 1;
global.mark = S_Move_mark;
O_SummonButton.block();
global.cell_action = function(cell) {
	if cell.marked{
		figure_to_move = global.selected_cell.filled_figure;
		global.cell_click_callback = cell;
		figure_to_move.click();
	}
}

start_move = function(to_x,to_y) {
	O_GameLoopController.set_action(new MoveAction(global.selected_cell.xcord, global.selected_cell.ycord, 
		to_x, to_y, global.selected_cell.filled_figure.sprite_index));
	instance_destroy();
}