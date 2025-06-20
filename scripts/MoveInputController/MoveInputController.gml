// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function MoveInputController() constructor{
	draw_previous_cell = 0;
	Game.game_loop_controller.state = STATE_LIST.figure_move;
	move_from = Game.field.get_cell(global.selected_cell.xcord, global.selected_cell.ycord)
	if Behaviours.get_move_ability(move_from.filled_figure.behaviour) == ArcherMoveAbility {
		move_ability = new ArcherMoveAbility(move_from.xcord, move_from.ycord, undefined, undefined, 0);
		move_ability.check_all_cells();
	}
	else {Game.field.check_clear_move_cells(move_from.xcord, move_from.ycord)}
	if move_from.filled_figure.previous_move_cell != undefined and move_from.filled_figure.previous_move_cell.marked {
		move_from.filled_figure.previous_move_cell.marked = 0;
		draw_previous_cell = 1;
	}
	global.mark = S_Move_mark;
	move_ability = Behaviours.get_move_ability(move_from.filled_figure.behaviour)
	set_new_cell_action = function() {
		global.cell_action = function(cell) {
			if cell.is_marked() {
				global.cell_click_callback = cell;
				O_BoardDraw.figure_click(global.selected_cell.filled_figure)
			}
		}
	}
	set_new_cell_action();

	start_move = function(to_x, to_y) {
		action_set = new move_ability(move_from.xcord,move_from.ycord, 
		to_x, to_y, undefined);
		action_set.draw_previous_cell = draw_previous_cell;
		Game.game_loop_controller.set_action(action_set);
		Game.move_input_controller = undefined;
		set_new_cell_action();
	}

	back = function() {
		Game.field.clear_all_marks();
		global.cell_click_callback = global.selected_cell;
		Game.figure_action_controller = new FigureActionController()
		//O_SummonButton.go_away();
		global.moving_figure = 0;
		Game.move_input_controller = undefined
	}
}