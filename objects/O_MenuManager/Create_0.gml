
login_button = UI_controller.get_button_on_ui("LoginWindow", "LoginButton");
register_button = UI_controller.get_button_on_ui("LoginWindow", "RegistrationButton");
enum LOGIN_MODES {
	login,
	register
}
login_mode = LOGIN_MODES.login;
switch_login_mode = function() {
	if login_mode == LOGIN_MODES.login {
		login_mode = LOGIN_MODES.register;
		UI_controller.turn_off_button(login_button);
		UI_controller.turn_on_button(register_button);
	}
	else {
		login_mode = LOGIN_MODES.login;
		UI_controller.turn_on_button(login_button);
		UI_controller.turn_off_button(register_button);
	}
}