/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакто
turn_owner = "";
action = undefined;
turn_end = false;
can_cancel = false;

enum game_state{
	input,
	move
}
state = game_state.input

startInput = function() {
	O_SummonButton.unblock()
}

end_move = function() {
	action.execute();
	action = undefined;
	O_SummonButton.go_to_standart_mode();
	state = game_state.move
	alarm[0] = 120;
	
}

set_action = function(new_action, cancel) {
	action = new_action;
	can_cancel = cancel;
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
		clear_all();
		try {
			instance_destroy(O_MoveInputController);
		}
	}
}

clear_all = function() {
	global.moving_figure = 0;
	global.chosen_figure = "";
	global.selected_cell = "";
	O_SummonButton.go_to_standart_mode();
	O_GameField.clear_all_marks();
	global.cell_click_callback = undefined;
	can_cancel = 0;
	O_SummonButton.unblock()
	global.cell_action = function(cell) {
		if (cell.is_filled() and cell.filled_figure.able_to_move) {
			global.cell_click_callback = cell;
			global.selected_cell = cell;
			cell.filled_figure.click();
		}
	} 
}

