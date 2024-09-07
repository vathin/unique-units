/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

O_SummonButton.image_index = 1
global.moving_figure = 1;
global.mark = S_Move_mark;
O_SummonButton.block();
O_SummonButton.alarm[0] = 2;
move_ability = Behaviours.get_move_ability(global.selected_cell.filled_figure.behaviour)
global.cell_action = function(cell) {
	if cell.marked {
		figure_to_move = global.selected_cell.filled_figure;
		global.cell_click_callback = cell;
		figure_to_move.click();
	}
}

start_move = function(to_x, to_y) {
	O_GameLoopController.set_action(new move_ability(global.selected_cell.xcord, global.selected_cell.ycord, 
		to_x, to_y, global.selected_cell.filled_figure.sprite_index));
	instance_destroy();
}

back = function() {
	O_GameField.clear_all_marks();
	global.cell_click_callback = global.selected_cell;
	instance_create_depth(0, 0, 0, O_FigureActionController);
	O_SummonButton.go_away();
	global.moving_figure = 0;
	instance_destroy();
}