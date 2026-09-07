// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureCapture() {
	global.turn_owner = Game.game_loop_controller.get_opponent(global.turn_owner);
	var _skip_ui = !Game.game_loop_controller.is_human_turn();
	Game.game_loop_controller.set_action(new GetFieldFigure(_skip_ui))
	Game.game_loop_controller.ready_to_send = 0
	cell_array = Game.field.get_filled_cells(Game.game_loop_controller.get_opponent(global.turn_owner));
	if _skip_ui {
		if array_length(cell_array) > 0 {
			Game.game_loop_controller.action.set_target(cell_array[irandom(array_length(cell_array) - 1)]);
		}
		return;
	}
	global.mark = S_Ability_mark;
	for (i = 0; i < array_length(cell_array); i++) {
		cell_array[i].marked = 1
	}
	if !Game.field.is_any_cell_marked() {
		
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
