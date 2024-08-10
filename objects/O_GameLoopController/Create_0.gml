/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакто
turn_owner = "";
action = "";
turn_end = false;

enum game_state{
	input,
	move
}
state = game_state.input

startInput = function() {
	O_SummonButton.active = 1
}

end_move = function() {
	action.execute();
	action = "";
	O_SummonButton.go_to_standart_mode();
	state = game_state.move
	alarm[0] = 120;
	
}

set_action = function(new_action) {
	action = new_action;
}

have_action = function() {
	return action != ""
}

get_opponent = function(player) {
	if player = "player1" {
		return "player2"
	}
	else {
		return "player1"
	}
}