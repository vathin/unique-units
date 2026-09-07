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
_avatar_url = "";
deck = []
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
	if (_avatar_url != "") {
		UI_controller.set_profile_avatar_from_url(_avatar_url);
	}
}

log_in = function(type) {
	_nickname = UI_controller.get_login_text();
	_email = UI_controller.get_email_text();
	_password = UI_controller.get_password_text();
	UI_controller.save_login_fields();
	if type == "login_acc" {
		Server.send(new ServerMessage(ServerMessageType.Login, {email: _email, password: _password}))
	}
	else if type == "register_acc" {
		Server.send(new ServerMessage(ServerMessageType.Registration, {nickname: _nickname, email: _email, password: _password}))
	}
	_password = "";
}

get_player_id_from_login_data = function(_data) {
	if (is_struct(_data)) {
		if (variable_struct_exists(_data, "userid")) {
			return _data.userid;
		}
		
		if (variable_struct_exists(_data, "playerData") && is_struct(_data.playerData) && variable_struct_exists(_data.playerData, "id")) {
			return _data.playerData.id;
		}
	}
	
	return undefined;
}

get_nickname_from_login_data = function(_data) {
	var _source = "none";
	var _name = undefined;
	var _vk_user = undefined;
	
	if (is_struct(_data)) {
		if (variable_struct_exists(_data, "vk_user") && is_struct(_data.vk_user)) {
			_vk_user = _data.vk_user;
			_source = "msg.data.vk_user";
		}
		else if (variable_struct_exists(_data, "vk_data") && is_struct(_data.vk_data)) {
			_vk_user = _data.vk_data;
			_source = "msg.data.vk_data";
		}
		else if (variable_struct_exists(_data, "playerData") && is_struct(_data.playerData)) {
			if (variable_struct_exists(_data.playerData, "nickname")) {
				_name = _data.playerData.nickname;
				_source = "msg.data.playerData.nickname";
			}
			else if (variable_struct_exists(_data.playerData, "display") && is_struct(_data.playerData.display) && variable_struct_exists(_data.playerData.display, "nickname")) {
				_name = _data.playerData.display.nickname;
				_source = "msg.data.playerData.display.nickname";
			}
			else if (variable_struct_exists(_data.playerData, "info") && is_struct(_data.playerData.info) && variable_struct_exists(_data.playerData.info, "nickname")) {
				_name = _data.playerData.info.nickname;
				_source = "msg.data.playerData.info.nickname";
			}
		}
	}
	
	if (_name == undefined && _vk_user != undefined && variable_struct_exists(_vk_user, "first_name")) {
		_name = _vk_user.first_name;
	}
	
	if (_name == undefined && variable_global_exists("vk") && variable_struct_exists(global.vk, "vk_user") && is_struct(global.vk.vk_user) && variable_struct_exists(global.vk.vk_user, "first_name")) {
		_name = global.vk.vk_user.first_name;
		_source = "global.vk.vk_user";
	}
	
	if (_name == undefined || string(_name) == "undefined" || string(_name) == "") {
		var _fallback_id = get_player_id_from_login_data(_data);
		if (_fallback_id == undefined || string(_fallback_id) == "undefined" || string(_fallback_id) == "") {
			_name = "VK Player";
			_source = "default fallback";
		}
		else {
			_name = string(_fallback_id);
			_source = "player id fallback";
		}
	}
	
	show_debug_message("VK/login: nickname resolved from " + _source + ": " + string(_name));
	return _name;
}

get_avatar_url_from_vk_user = function(_vk_user) {
	if (!is_struct(_vk_user)) {
		return "";
	}
	
	if (variable_struct_exists(_vk_user, "photo_100") && _vk_user.photo_100 != "") {
		return _vk_user.photo_100;
	}
	
	if (variable_struct_exists(_vk_user, "photo_200") && _vk_user.photo_200 != "") {
		return _vk_user.photo_200;
	}
	
	if (variable_struct_exists(_vk_user, "photo_max_orig") && _vk_user.photo_max_orig != "") {
		return _vk_user.photo_max_orig;
	}
	
	if (variable_struct_exists(_vk_user, "photo_base") && _vk_user.photo_base != "") {
		return _vk_user.photo_base;
	}
	
	return "";
}

get_avatar_url_from_login_data = function(_data, _allow_current_vk = true) {
	var _source = "none";
	var _url = "";
	
	if (is_struct(_data)) {
		if (variable_struct_exists(_data, "vk_user")) {
			_url = get_avatar_url_from_vk_user(_data.vk_user);
			_source = "msg.data.vk_user";
		}
		else if (variable_struct_exists(_data, "vk_data")) {
			_url = get_avatar_url_from_vk_user(_data.vk_data);
			_source = "msg.data.vk_data";
		}
		else {
			var _player_data = _data;
			if (variable_struct_exists(_data, "playerData") && is_struct(_data.playerData)) {
				_player_data = _data.playerData;
			}
			if (variable_struct_exists(_player_data, "display") && is_struct(_player_data.display) && variable_struct_exists(_player_data.display, "icon") && _player_data.display.icon != "") {
				_url = _player_data.display.icon;
				_source = "player display.icon";
			}
			else if (variable_struct_exists(_player_data, "platform_vk") && is_struct(_player_data.platform_vk) && variable_struct_exists(_player_data.platform_vk, "PlatfromVk") && is_struct(_player_data.platform_vk.PlatfromVk) && variable_struct_exists(_player_data.platform_vk.PlatfromVk, "user_info")) {
				_url = get_avatar_url_from_vk_user(_player_data.platform_vk.PlatfromVk.user_info);
				_source = "player platform_vk user_info";
			}
			else if (variable_struct_exists(_player_data, "info") && is_struct(_player_data.info)) {
				var _info = _player_data.info;
				if (variable_struct_exists(_info, "display") && is_struct(_info.display) && variable_struct_exists(_info.display, "icon") && _info.display.icon != "") {
					_url = _info.display.icon;
					_source = "player info.display.icon";
				}
				else if (variable_struct_exists(_info, "platform_vk") && is_struct(_info.platform_vk) && variable_struct_exists(_info.platform_vk, "PlatfromVk") && is_struct(_info.platform_vk.PlatfromVk) && variable_struct_exists(_info.platform_vk.PlatfromVk, "user_info")) {
					_url = get_avatar_url_from_vk_user(_info.platform_vk.PlatfromVk.user_info);
					_source = "player info platform_vk user_info";
				}
			}
		}
	}
	
	if (_url == "" && _allow_current_vk && variable_global_exists("vk") && variable_struct_exists(global.vk, "vk_user")) {
		_url = get_avatar_url_from_vk_user(global.vk.vk_user);
		_source = "global.vk.vk_user";
	}
	
	show_debug_message("VK/avatar: avatar url resolved from " + _source + ": " + _url);
	return _url;
}

Server.add_reaction(function(msg)
{
	switch msg.type{
		case ServerMessageType.LoginVK:
			show_debug_message("VK login: server response accepted: " + json_stringify(msg.data));
			_id = get_player_id_from_login_data(msg.data);
			_nickname = get_nickname_from_login_data(msg.data);
			_avatar_url = get_avatar_url_from_login_data(msg.data);
			log_in_callback();
			break;
		case ServerMessageType.LoginAccept:
			show_debug_message("VK/login: server login accepted: " + json_stringify(msg.data));
			_id = get_player_id_from_login_data(msg.data);
			if (_nickname == undefined || string(_nickname) == "undefined" || string(_nickname) == "") {
				_nickname = get_nickname_from_login_data(msg.data);
			}
			_avatar_url = get_avatar_url_from_login_data(msg.data);
			log_in_callback()
			break;
		case ServerMessageType.LoginRefuse:
			show_debug_message("VK/login: server response refused: " + json_stringify(msg.data));
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
				var _player = msg.data.player;
				show_debug_message("Online opponent PlayerInfo: " + json_stringify(_player));
				var _name = "";
				if (variable_struct_exists(_player, "info") && is_struct(_player.info) && variable_struct_exists(_player.info, "nickname")) {
					_name = _player.info.nickname;
				}
				else if (variable_struct_exists(_player, "display") && is_struct(_player.display) && variable_struct_exists(_player.display, "nickname")) {
					_name = _player.display.nickname;
				}
				else if (variable_struct_exists(_player, "nickname")) {
					_name = _player.nickname;
				}
				if (_name != undefined && string(_name) != "" && string(_name) != "undefined") {
					UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "OpponentNickname", _name);
				}
				var _opponent_avatar_url = get_avatar_url_from_login_data(_player, false);
				if (_opponent_avatar_url != "") {
					UI_controller.set_opponent_avatar_from_url(_opponent_avatar_url);
				}
			}
			break;
	}
}
)
