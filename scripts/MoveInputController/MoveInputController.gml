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
	
	draw_cell = function() {
		var _draw_x = Game.field.get_cell_xy(previous_cell)[0];
		var _draw_y = Game.field.get_cell_xy(previous_cell)[1];
		draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
		if Game.game_loop_controller.have_action() {array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, self), 1)}
	}
	
	previous_cell = Game.field.check_movement_array(move_from.filled_figure.figure_id)
	if previous_cell != undefined and previous_cell.is_marked() {
		previous_cell.marked = 0;
		draw_previous_cell = 1;
		array_push(Game.do_every_step_list, draw_cell)
	}
	else {previous_cell = undefined}
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
		action_set.previous_move_cell = previous_cell
		Game.game_loop_controller.set_action(action_set);
		set_new_cell_action();
		Game.move_input_controller = undefined;
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