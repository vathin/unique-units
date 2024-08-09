/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакто
turn_owner = "";
action = "";
turn_end = false;

enum state{
	input,
	move
}

startInput = function() {
	O_SummonButton.active = 1
}

end_move = function() {
	action.execute()
	action = ""
	O_SummonButton.go_to_standart_mode();
}

set_action = function(new_action) {
	action = new_action;
}

have_action = function() {
	return action != ""
}