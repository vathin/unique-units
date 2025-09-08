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
	else if invite_text_field == undefined{
		invite_text_field = instance_create_depth(room_width/2, room_height/2 -30, -1, O_TextInputField);
		invite_text_field.default_text = "nickname"
		invite_text_field.image_xscale = 2.5;
		invite_text_field.image_yscale = 0.85;
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

set_text_on_ui_layer = function(_layer_name, _panel_name, _text) {
	var _layer = layer_get_flexpanel_node(_layer_name);
	var _text_panel = flexpanel_node_get_child(_layer, _panel_name);
	var _text_struct = flexpanel_node_get_struct(_text_panel);
	var _textID = _text_struct.layerElements[0].elementId;
	layer_text_text(_textID, _text);
}

invite_accept = function() {
	Server.send(new ServerMessage(ServerMessageType.InviteAccept, {sender: enemy}));
	invited = 0;
}

invite_decline = function() {
	Server.send(new ServerMessage(ServerMessageType.InviteCancel, {sender: _id}));
	invited = 0;
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
	set_text_on_ui_layer("MainMenu", "Nickname", _nickname)
}

send_data = function(type) {
	_nickname = O_MenuManager.get_login_text();
	_email = O_MenuManager.get_email_text();
	_password = O_MenuManager.get_password_text();
	if type == "login_acc" {
		Server.send(new ServerMessage(ServerMessageType.Login, {email: _email, password: _password}))
	}
	else if type == "register_acc" {
		Server.send(new ServerMessage(ServerMessageType.Registration, {nickname: _nickname, email: _email, password: _password}))
	}
	_password = "";
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
		reason = msg.data.description;
		set_text_on_ui_layer("LoginWindow", "ReasonText", reason);
	}
	else if msg.type == ServerMessageType.RegistrationAccept
	{
		_id = msg.data.playerData.id;
		show_debug_message(msg.data.playerData.id);
		log_in();
	}
	else if msg.type == ServerMessageType.RegistrationRefuse
	{
		reason = msg.data.description;
		set_text_on_ui_layer("LoginWindow", "ReasonText", reason);
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
				set_text_on_ui_layer("InviteWindow", "Text_2", "от: " + enemy)
				UI_controller.check_layers();
			}
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
