/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

login_window_x = 840;
login_window_y = 540;
x_offset = 25;
y_offset = 25;
logged_in = false;
active = false;
reason = "";
enemy = undefined;

login_x = login_window_x-x_offset;
login_y = login_window_y-75-y_offset;
email_x = login_window_x-x_offset;
email_y = login_window_y-y_offset;
password_x = login_window_x-x_offset;
password_y = login_window_y+75-y_offset;
LoginButton_x = login_window_x + 128;
LoginButton_y = login_window_y + 102;;
RegisterButton_x = login_window_x - 35;
RegisterButton_y = login_window_y + 102;
invite_text_field = undefined;


create_window = function() {
	LoginTextField = instance_create_depth(login_x, login_y, -1, O_TextInputField);
	EmailTextField = instance_create_depth(email_x, email_y, -1, O_TextInputField);
	PasswordTextField = instance_create_depth(password_x, password_y, -1, O_TextInputField);

	LoginButton = instance_create_depth(LoginButton_x, LoginButton_y, -1, O_LoginButton);
	RegisterButton = instance_create_depth(RegisterButton_x, RegisterButton_y, -1, O_LoginButton);

	LoginButton.set_type("Login_acc");
	RegisterButton.set_type("Register_acc");

	LoginButton.set_address(self);
	RegisterButton.set_address(self);
	active = true;
}

close_window = function() {
	instance_destroy(LoginTextField);
	instance_destroy(EmailTextField);
	instance_destroy(PasswordTextField);
	instance_destroy(LoginButton);
	instance_destroy(RegisterButton);
	active = false;
	reason = "";
}

invite_button_draw = function() {
	draw_set_alpha(0.5);
	draw_rectangle(room_width - 415, 40, room_width - 415 + 340, 125, 0);
	draw_set_alpha(1);
	draw_text(room_width - 400, 50, "ПРИГЛАСИТЬ");
	draw_set_font(F_test)
	if reason != "" {draw_text(room_width - 415, 215, reason)}
	draw_set_font(F_turn_timer)
}

invite_button_check = function() {
	if mouse_check_button_pressed(mb_left) and mouse_x > room_width - 415 
	and mouse_x < room_width - 415 + 340 
	and mouse_y > 40 and mouse_y < 125 {
		if invite_text_field != undefined and invite_text_field.get_text() != ""{
			Server.send(new ServerMessage(ServerMessageType.Invite, {reciever: invite_text_field.get_text()}));
			enemy = invite_text_field.get_text();
			instance_destroy(invite_text_field);
			invite_text_field = undefined;
			room_goto(R_Invite);
		}
		else {
			invite_text_field = instance_create_depth(room_width - 215, 225, -1, O_TextInputField);
			reason = "";
		}
		}
}

invite_cancel_button_draw = function() {
	draw_set_alpha(0.35)
	draw_rectangle(room_width/2 - 125, room_height/1.25 - 15, room_width/2 + 125, room_height/1.25 + 90, 0);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_text(room_width/2, room_height / 1.25, "ОТМЕНА");
	draw_set_halign(fa_left);
}
invite_cancel_button_check = function() {
	if mouse_check_button_pressed(mb_left) and mouse_x > room_width/2 - 125 and mouse_x < room_width/2 + 125
	and mouse_y > room_height/1.25 - 15 and mouse_y < room_height/1.25 + 90 {
		Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _nickname, reciever: enemy}));
		enemy = undefined;
		room_goto(R_Main_menu);
	}
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

//test3
//test3@a
//test3

//test4
//test4@a
//test4

Server.add_reaction(function(msg)
{
	if msg.type == ServerMessageType.LoginAccept {
		logged_in = true
		close_window()
		show_debug_message(msg.data);
	}
	else if msg.type == ServerMessageType.LoginRefuse 
	{
		reason = msg.data.description
	}
	else if msg.type == ServerMessageType.RegistrationAccept
	{
		reason = "succsessfull registration";
		logged_in = 1;
		close_window();
	}
	else if msg.type == ServerMessageType.RegistrationRefuse
	{
		reason = msg.data.description
	}
	else if msg.type == ServerMessageType.InviteAccept
	{
		
	}
	else if msg.type == ServerMessageType.InviteCancelled {
		room_goto(R_Main_menu)
		reason = "ошибка";
		show_debug_message(msg.data)
	}
	else if msg.type == ServerMessageType.InviteCancel {
		//room_goto(R_Main_menu);
		reason = "отмена";
	}
})
