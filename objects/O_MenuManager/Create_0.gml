
login_button = UI_controller.get_button_on_ui("LoginWindow", "LoginButton");
register_button = UI_controller.get_button_on_ui("LoginWindow", "RegistrationButton");
login_text_field = UI_controller.get_button_instance((UI_controller.get_button_on_ui("LoginWindow", "LoginField")))
email_text_field = UI_controller.get_button_instance((UI_controller.get_button_on_ui("LoginWindow", "EmailField")))
password_text_field = UI_controller.get_button_instance((UI_controller.get_button_on_ui("LoginWindow", "PasswordField")))
UI_controller.turn_off_button(register_button);
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

get_login_text = function() {
	return login_text_field.get_text()
}
get_email_text = function() {
	return email_text_field.get_text()
}
get_password_text = function() {
	return password_text_field.get_text()
}