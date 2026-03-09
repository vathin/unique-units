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
_nickname = undefined;
_email = undefined;
_password = undefined;
_id = undefined;
_winner = undefined;
deck = []
instance_create_depth(0, 0, 0, UI_controller);
UI_controller.check_layers();
//global.vk.init()

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
LoginButton_y = login_window_y + 102;
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

delete_invite_text_field = function() {
	if instance_exists(invite_text_field) {
		instance_destroy(invite_text_field);
		invite_text_field = undefined;	
	}
}

start_fast_search = function() {
	Server.send(new ServerMessage(ServerMessageType.FastMatchEnter));
	delete_invite_text_field()
	room_goto(R_Game_search);
} 

cancel_fast_search = function() {
	Server.send(new ServerMessage(ServerMessageType.FastMatchLeave, {sender: _id, reciever: enemy}));
	room_goto(R_Main_menu);
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


log_in_callback = function() {
	logged_in = true
	UI_controller.check_layers();
	UI_controller.set_text_on_ui_layer("MenuHome", "Nickname", _nickname);
	UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "PlayerNickname", _nickname);
}

log_in = function(type) {
	_nickname = UI_controller.get_login_text();
	_email = UI_controller.get_email_text();
	_password = UI_controller.get_password_text();
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
	switch msg.type{
		case ServerMessageType.LoginVK:
			_id = msg.data.userid;
			_nickname = msg.data.vk_user.first_name
			log_in_callback();
			break;
		case ServerMessageType.LoginAccept:
			_id = msg.data.playerData.id;
			log_in_callback()
			break;
		case ServerMessageType.LoginRefuse:
			reason = msg.data.description;
			UI_controller.set_text_on_ui_layer("LoginWindow", "ReasonText", reason);
			break;
		case ServerMessageType.RegistrationAccept:
			_id = msg.data.playerData.id;
			log_in_callback();
			break;
		case ServerMessageType.RegistrationRefuse:
			reason = msg.data.description;
			UI_controller.set_text_on_ui_layer("LoginWindow", "ReasonText", reason);
			break;
		case ServerMessageType.InviteCancelled:
			room_goto(R_Main_menu)
			reason = "ошибка";
			break;
		case ServerMessageType.InviteCancel:
			room_goto(R_Main_menu);
			reason = "отмена";
			break;
		case ServerMessageType.Invite:
			if msg.data.invite.sender != _id {
				enemy = msg.data.invite.sender;
				if room == R_Main_menu{
					invited = 1;
					UI_controller.set_text_on_ui_layer("InviteWindow", "Text_2", "от: " + enemy)
					UI_controller.check_layers();
				}
			}
			break
		case ServerMessageType.GameStart:
			room_goto(R_Test);
			enemy = msg.data.opponent;
			global.turn_owner = msg.data.turn
			Start_online_match(msg.data.matchId, msg.data.opponent, msg.data.role);
			break;
		case ServerMessageType.GameplayTurn:
			if msg.data.turn.turnOwner != _id {
				Game.get_turn(msg.data.turn.fieldState, msg.data.turn.turn);
				var _add = msg.data.turn.fieldState.additional_data
				if _add != undefined {
					if _add.type == "GetEnemyDeck" {
						Game.get_enemy_deck(_add);
						if _add.count == 0 {Game.send_deck(_add.count+1)}
					}
				}
			}
			break;
		case ServerMessageType.GameEnd:
			_winner = msg.data.winner;
			if _winner == "" {winner = "draw"}
			alarm[0] = 35;
			break;
		case ServerMessageType.PlayerInfo:
			if msg.data.player.id != _id {
				var _name = msg.data.player.info.nickname;
				UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "OpponentNickname", _name);
			}
			break;
	}
}
)
