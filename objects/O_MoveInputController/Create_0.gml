/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
draw_previous_cell = 0;
move_from = O_GameField.get_cell(global.selected_cell.xcord, global.selected_cell.ycord)
if Behaviours.get_move_ability(move_from.filled_figure.behaviour) == ArcherMoveAbility {
	move_ability = new ArcherMoveAbility(move_from.xcord, move_from.ycord, undefined, undefined, 0);
	move_ability.check_all_cells();
}
else {O_GameField.check_clear_move_cells(move_from.xcord, move_from.ycord)}
if move_from.filled_figure.previous_move_cell != undefined and move_from.filled_figure.previous_move_cell.marked {
	move_from.filled_figure.previous_move_cell.marked = 0;
	draw_previous_cell = 1;
}
O_SummonButton.image_index = 1
global.moving_figure = 1;
global.mark = S_Move_mark;
O_SummonButton.block();
O_SummonButton.alarm[0] = 1;
move_ability = Behaviours.get_move_ability(move_from.filled_figure.behaviour)
set_new_cell_action = function() {
	global.cell_action = function(cell) {
		if cell.marked {
			global.cell_click_callback = cell;
			global.selected_cell.filled_figure.click();
		}
	}
}
set_new_cell_action();

start_move = function(to_x, to_y) {
	action_set = new move_ability(move_from.xcord,move_from.ycord, 
	to_x, to_y, move_from.filled_figure.sprite_index);
	action_set.draw_previous_cell = draw_previous_cell;
	O_GameLoopController.set_action(action_set);
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