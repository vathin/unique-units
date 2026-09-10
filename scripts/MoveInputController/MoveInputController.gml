// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function MoveInputController() constructor{
	draw_previous_cell = 0;
	Game.game_loop_controller.state = STATE_LIST.figure_move;
	move_from = Game.field.get_cell(global.selected_cell.xcord, global.selected_cell.ycord)
	var _move_cells_data = Game.game_loop_controller.get_move_target_cells_data(move_from);
	Game.field.mark_cells(_move_cells_data.cells);
	
	draw_cell = function() {
		var _draw_x = Game.field.get_cell_xy(previous_cell)[0];
		var _draw_y = Game.field.get_cell_xy(previous_cell)[1];
		draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.7);
		if Game.game_loop_controller.have_action() {array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, self), 1)}
	}
	
	previous_cell = _move_cells_data.blocked_previous_cell;
	if previous_cell != undefined {
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
		if move_ability == StandartMoveAbility {
			action_set = new EffectAction("move", global.turn_owner, {from_cell: [move_from.xcord, move_from.ycord], target_cell: [to_x, to_y]});
		}
		else {
			action_set = new move_ability(move_from.xcord,move_from.ycord, to_x, to_y, undefined);
		}
		if move_ability != StandartMoveAbility {
			action_set.draw_previous_cell = draw_previous_cell;
			action_set.previous_move_cell = previous_cell;
		}
		Game.game_loop_controller.set_action(action_set);
		set_new_cell_action();
		Game.field.get_cell(to_x, to_y).add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved));
		O_BoardDraw.unblock_end_button();
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
