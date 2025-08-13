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
instance_create_depth(0, 0, 0, UI_controller);
UI_controller.check_layers();

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

start_invite = function() {
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

cancel_invite = function() {
	Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _id, reciever: enemy}));
	enemy = undefined;
	room_goto(R_Main_menu);
}

start_fast_search = function() {
	Server.send(new ServerMessage(ServerMessageType.FastMatchEnter));
	room_goto(R_Game_search);
} 

cancel_fast_search = function() {
	Server.send(new ServerMessage(ServerMessageType.FastMatchLeave, {sender: _id, reciever: enemy}));
	room_goto(R_Main_menu);
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

//create_window();
_nickname = undefined;
_email = undefined;
_password = undefined;
_id = undefined;
_winner = undefined;

log_in = function() {
	logged_in = true
	UI_controller.check_layers();
}

send_data = function(type) {
	show_debug_message(type)
	get_text_data()
	if type == "login_acc" {
		Server.send(new ServerMessage(ServerMessageType.Login, {email: _email, password: _password}))
	}
	else if type == "register_acc" {
		Server.send(new ServerMessage(ServerMessageType.Registration, {nickname: _nickname, email: _email, password: _password}))
	}
	_password = "";
}

get_text_data = function() {
	with (O_TextInputField) {
		switch(type) {
			case "login":
				O_LoginController._nickname = get_text()
			break;
			case "email":
				O_LoginController._email = get_text()
			break;
			case "password":
				O_LoginController._password = get_text()
			break;
		}
	}
	/*_nickname = LoginTextField.get_text()
	_email = EmailTextField.get_text()
	_password = PasswordTextField.get_text()*/
}



Server.add_reaction(function(msg)
{
	if msg.type == ServerMessageType.LoginAccept {
		_id = msg.data.playerData.id;
		show_debug_message(msg.data.playerData.id);
		log_in()
	}
	else if msg.type == ServerMessageType.LoginRefuse 
	{
		reason = msg.data.description
	}
	else if msg.type == ServerMessageType.RegistrationAccept
	{
		_id = msg.data.playerData.id;
		show_debug_message(msg.data.playerData.id);
		log_in()
	}
	else if msg.type == ServerMessageType.RegistrationRefuse
	{
		reason = msg.data.description
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
			if room == R_Main_menu{
				invited = 1;
			}
			else {}
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
