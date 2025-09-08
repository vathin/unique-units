/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

image_speed = 0
send_to = O_LoginController
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
		send_to.send_data(type)
	}
	else {
		O_MenuManager.switch_login_mode()
	}
}