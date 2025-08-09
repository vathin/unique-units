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
invited = false;
role = undefined;
server_id = undefined;

#macro Game global.game
Game = undefined;
Game = new GameClass();

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
			Server.send(new ServerMessage(ServerMessageType.Invite, {reciever: invite_text_field.get_text(), sender: _id}));
			enemy = invite_text_field.get_text();
			instance_destroy(invite_text_field);
			invite_text_field = undefined;
			room_goto(R_Invite);
		}
		else {
			invite_text_field = instance_create_depth(room_width - 215, 185, -1, O_TextInputField);
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
		Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _id, reciever: enemy}));
		enemy = undefined;
		room_goto(R_Main_menu);
	}
}

game_search_button_draw = function() {
	draw_set_font(F_turn_timer)
	draw_set_alpha(0.5);
	draw_rectangle(room_width - 415, 245, room_width - 415 + 340, 330, 0);
	draw_set_alpha(1);
	draw_text(room_width - 400, 255, "ПОИСК ИГРЫ");
	//draw_set_font(F_test)
	//if reason != "" {draw_text(room_width - 415, 215, reason)}
	//draw_set_font(F_turn_timer)
}

game_search_button_check = function() {
	if mouse_check_button_pressed(mb_left) and mouse_x > room_width - 415 and mouse_x < room_width - 415 + 340 
	and mouse_y > 245 and mouse_y < 330 {
		room_goto(R_Game_search)
	}
}

search_cancel_button_draw = function() {
	draw_set_alpha(0.35)
	draw_rectangle(room_width/2 - 125, room_height/1.25 - 15, room_width/2 + 125, room_height/1.25 + 90, 0);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_text(room_width/2, room_height / 1.25, "ОТМЕНА");
	draw_set_halign(fa_left);
}
search_cancel_button_check = function() {
	if mouse_check_button_pressed(mb_left) and mouse_x > room_width/2 - 125 and mouse_x < room_width/2 + 125
	and mouse_y > room_height/1.25 - 15 and mouse_y < room_height/1.25 + 90 {
		//Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _id, reciever: enemy}));
		//enemy = undefined;
		room_goto(R_Main_menu);
	}
}

end_game_back_button_draw = function() {
	draw_set_alpha(0.35)
	draw_rectangle(room_width/2 - 125, room_height/1.25 - 15, room_width/2 + 125, room_height/1.25 + 90, 0);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_text(room_width/2, room_height / 1.25, "В МЕНЮ");
	draw_set_halign(fa_left);
}
end_game_back_button_check = function() {
	if mouse_check_button_pressed(mb_left) and mouse_x > room_width/2 - 125 and mouse_x < room_width/2 + 125
	and mouse_y > room_height/1.25 - 15 and mouse_y < room_height/1.25 + 90 {
		enemy = undefined;
		room_goto(R_Main_menu);
	}
}

invite_accept_window_draw = function() {
	window_x = room_width - 900;
	window_y = 45
	draw_set_alpha(0.35);
	draw_set_font(F_test);
	draw_rectangle(window_x, window_y, window_x + 340, window_y + 200, 0);
	draw_rectangle_color(window_x + 20, window_y + 120, window_x + 155, window_y + 160, c_lime, c_lime, c_lime, c_lime, 0);
	draw_rectangle_color(window_x + 185, window_y + 120, window_x + 320, window_y + 160, c_red, c_red, c_red, c_red, 0);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_text(window_x + 170, window_y + 10, "ПРИГЛАШЕНИЕ В ИГРУ");
	draw_text(window_x + 170, window_y + 50, "ОТ: " + string(enemy));
	draw_text(window_x + 87, window_y + 122, "принять");
	draw_text(window_x + 253, window_y + 122, "отклонить");
	draw_set_halign(fa_left);
}

invite_accept_window_check = function() {
	if mouse_check_button_pressed(mb_left) {
		window_x = room_width - 900;
		window_y = 45;
		if mouse_x > window_x + 20 and mouse_x < window_x + 155 and mouse_y > window_y + 120 and mouse_y < window_y + 160 {
			Server.send(new ServerMessage(ServerMessageType.InviteAccept, {sender: enemy}));
			invited = 0;
		}
		else if mouse_x > window_x + 185 and mouse_x < window_x + 320 and mouse_y > window_y + 120 and mouse_y < window_y + 160 {
			Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _id}));
			invited = 0;
		}
	}
}

create_window();
_nickname = undefined;
_email = undefined;
_password = undefined;
_id = undefined;
var _winner

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
		show_debug_message(msg.data.playerData.id);
		_id = msg.data.playerData.id;
	}
	else if msg.type == ServerMessageType.LoginRefuse 
	{
		reason = msg.data.description
	}
	else if msg.type == ServerMessageType.RegistrationAccept
	{
		reason = "succsessfull registration";
		logged_in = 1;
		show_debug_message(msg.data.playerData.id);
		_id = msg.data.playerData.id;
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
	else if msg.type == ServerMessageType.Invite {
		if msg.data.invite.sender != _id {
			enemy = msg.data.invite.sender;
			invited = 1;
		}
	}
	else if msg.type == ServerMessageType.GameStart {
		room_goto(R_Test);
		enemy = msg.data.opponent;
		global.turn_owner = msg.data.turn
		Start_online_match(msg.data.matchId, msg.data.opponent, msg.data.role);
	}
	else if msg.type == ServerMessageType.GameplayTurn {
		if msg.data.turn.fieldState.ex_turn_owner != _id {
			Game.get_turn(msg.data.turn.fieldState, msg.data.turn.turn);
		}
	}
	else if msg.type == ServerMessageType.GameEnd {
		_winner = msg.data.winner;
		if _winner == "" {winner = "draw"}
		alarm[0] = 35;
	}
})
