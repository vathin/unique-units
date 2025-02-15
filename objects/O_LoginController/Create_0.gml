/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

login_window_x = 840
login_window_y = 540
x_offset = 25
y_offset = 25
logged_in = false
active = false
reason = ""

login_x = login_window_x-x_offset
login_y = login_window_y-75-y_offset
email_x = login_window_x-x_offset
email_y = login_window_y-y_offset
password_x = login_window_x-x_offset
password_y = login_window_y+75-y_offset
LoginButton_x = login_window_x + 128
LoginButton_y = login_window_y + 102
RegisterButton_x = login_window_x - 35
RegisterButton_y = login_window_y + 102


create_window = function() {
	LoginTextField = instance_create_depth(login_x, login_y, -1, O_TextInputField)
	EmailTextField = instance_create_depth(email_x, email_y, -1, O_TextInputField)
	PasswordTextField = instance_create_depth(password_x, password_y, -1, O_TextInputField)

	LoginButton = instance_create_depth(LoginButton_x, LoginButton_y, -1, O_LoginButton)
	RegisterButton = instance_create_depth(RegisterButton_x, RegisterButton_y, -1, O_LoginButton)

	LoginButton.set_type("Login_acc")
	RegisterButton.set_type("Register_acc")

	LoginButton.set_address(self)
	RegisterButton.set_address(self)
	active = true
}

close_window = function() {
	instance_destroy(LoginTextField)
	instance_destroy(EmailTextField)
	instance_destroy(PasswordTextField)
	instance_destroy(LoginButton)
	instance_destroy(RegisterButton)
	active = false
}

create_window()
_nickname = undefined
_email = undefined
_password = undefined

send_data = function(type) {
	show_debug_message(type)
	get_text_data()
	if type == "Login_acc" {
		Server.send(new ServerMessage(ServerMessageType.Login, {email: _email, password: _password}))
	}
	else if type == "Register_acc" {
		Server.send(new ServerMessage(ServerMessageType.Registration, {nickname: _nickname, email: _email, password: _password}))
	}
}

get_text_data = function() {
	_nickname = LoginTextField.get_text()
	_email = EmailTextField.get_text()
	_password = PasswordTextField.get_text()
}

//login 123456789
//email dadada@1234.com
//passsword 123456789

Server.add_reaction(function(msg)
{
	if msg.type == ServerMessageType.LoginAccept {
		logged_in = true
		close_window()
	}
	else if msg.type == ServerMessageType.LoginRefuse 
	{
		reason = msg.data.description
	}
	else if msg.type == ServerMessageType.RegistrationAccept
	{
		reason = "succsessfull registration"
	}
	else if msg_type == ServerMessageType.RegistrationRefuse
	{
		reason = msg.data.description
	}
})
