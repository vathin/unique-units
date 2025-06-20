// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureCapture() {
	global.turn_owner = Game.game_loop_controller.get_opponent(global.turn_owner);
	Game.game_loop_controller.set_action(new GetFieldFigure())
	cell_array = Game.field.get_filled_cells(Game.game_loop_controller.get_opponent(global.turn_owner));
	global.mark = S_Ability_mark;
	for (i = 0; i < array_length(cell_array); i++) {
		cell_array[i].marked = 1
	}
	global.cell_action = function(cell){
		if cell.marked {
			if global.cell_click_callback != undefined{global.cell_click_callback.set_draw_marks(1)}
			global.cell_click_callback = cell;
			cell.set_draw_marks(0);
			Game.game_loop_controller.action.set_target(cell);
		}
	}

}