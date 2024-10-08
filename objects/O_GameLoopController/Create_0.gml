/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакто
global.turn_owner = "player1";
player1_captured = 0;
player2_captured = 0;
action = undefined;
turn_end = false;
can_cancel = false;
displaying_card = false;

O_Turn_timer.start_count()

set_can_cancel = function(value) {
	can_cancel = value;
}

startInput = function() {
	O_SummonButton.unblock()
}

end_move = function() {
	alarm[0] = 5;
	global.input = 0;
	if global.moving_figure {
		global.selected_cell.filled_figure.start_move_animation(global.cell_click_callback, Settings.move_animation_lenght)
	}
	if have_action() { action.execute() }
	global.turn_owner = get_opponent(global.turn_owner);
	clear_all();
	O_Turn_timer.start_count();
	Maps_list.check_if_any_cell_conquested(global.map);
	O_GameField.check_every_figure();
	O_Figures_counter.update_turn();
	if check_win_conditions() != undefined {game_end()}
}

set_action = function(new_action) {
	action = new_action;
}

have_action = function() {
	return action != undefined
}

get_opponent = function(player) {
	if player = "player1" {
		return "player2"
	}
	else {
		return "player1"
	}
}

choose_cell_for_summon = function() {
	if global.selected_cell = "" {
		global.cell_click_callback.marked = 0;
		global.selected_cell = global.cell_click_callback;
		O_SummonInputController.start_summon(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
	}
	else {
		global.selected_cell.marked = 1;
		global.selected_cell = global.cell_click_callback;
		global.cell_click_callback.marked = 0;
		action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
	}
}
cancel_action = function() {
	if have_action{
		action = undefined;
		clear_all();
	}
	else {
		if global.using_ability{instance_destroy(O_AbilityInputController)}
		if global.moving_figure{instance_destroy(O_MoveInputController)}
		clear_all();
	}
}

default_cell_click_action = function(cell) {
	if (cell_is_playable(cell)) {
		select_movable_figure(cell);
	}
}
cell_is_playable = function(cell) {
	return (cell.is_filled() and 
			cell.filled_figure.able_to_move and 
			cell.filled_figure.owner = global.turn_owner and 
			cell.filled_figure.state.is_active);
}
select_movable_figure = function(cell) {
	global.cell_click_callback = cell;
	global.selected_cell = cell;
	set_can_cancel(1);
	cell.filled_figure.click();
}

clear_all = function() {
	if !have_action() {
		if global.using_ability{instance_destroy(O_AbilityInputController)}
		if global.moving_figure{instance_destroy(O_MoveInputController)}
	}
	else {if global.input = 1 {action.cancel()} }
	try {
		O_FigureActionController.clear_buttons();
		instance_destroy(O_FigureActionController);
	}
	catch(_exception) {}
	O_EndTurn.active = 1;
	global.moving_figure = 0;
	global.using_ability = 0;
	global.chosen_figure = "";
	global.selected_cell = "";
	O_SummonButton.go_to_standart_mode();
	O_GameField.clear_all_marks();
	global.cell_click_callback = undefined;
	set_can_cancel(0)
	O_SummonButton.unblock()
	global.cell_action = default_cell_click_action;
	action = undefined;
}

check_win_conditions = function() {
	if player1_captured >= 4 and player2_captured >= 4 {return "draw"}
	else {
		if player1_captured >= 4 {return "player1_win"}
		if player2_captured >= 4 {return "player2_win"}
	}
	return undefined
}
	
global.cell_action = default_cell_click_action;