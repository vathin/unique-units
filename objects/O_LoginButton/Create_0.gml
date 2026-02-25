event_inherited();
image_speed = 0
send_to = O_Server
enum MODES {
	go_to_registration,
	go_to_login
}
mode = MODES.go_to_registration


set_type = function(new_type) {
	type = new_type
}

set_address = function(new_address) {
	send_to = new_address
}

click = function() {
	
	if type != "Mode_switch"{
		send_to.log_in(type)
	}
	else {
		UI_controller.switch_login_mode()
	}
}