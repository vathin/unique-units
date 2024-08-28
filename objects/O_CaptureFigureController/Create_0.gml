/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

global.turn_owner = O_GameLoopController.get_opponent(global.turn_owner);
O_GameLoopController.set_action(new GetFieldFigure())
cell_array = O_GameField.get_filled_cells(O_GameLoopController.get_opponent(global.turn_owner));
global.mark = S_Ability_mark;
for (i = 0; i < array_length(cell_array); i++) {
	cell_array[i].marked = 1
}
global.cell_action = function(cell){
	if cell.marked {
		if global.cell_click_callback != undefined{global.cell_click_callback.set_draw_marks(1)}
		global.cell_click_callback = cell;
		cell.set_draw_marks(0);
		O_GameLoopController.action.set_target(cell);
	}
}

instance_destroy();