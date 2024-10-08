function ServerMessageType() constructor {
	static Error = "Error"; // сообщение вызвало ошибку на сервере и сервер жалуется тебе на неё {error: "error_text"}
	
	static Registration = "Registration"; // ты просишь зарегестрировать новый аккаунт. {nickanme: "...", email: "...@...", password: "..."}
	static RegistrationAccept = "RegistrationAccept"; // сервер создал аккаунт и разрешил дальнейшие сообщения. {playerData: {...}}
	static RegistrationRefuse = "RegistrationRefuse"; // сервер отклонил запрос на создание аккаунта {reason: "ключевое слово причины", description: "детальное описание причины"}
	
	static Login = "Login"; // просьба войти на сервер. {email: "...", password: "..."}
	static LoginAccept = "LoginAccept"; // успешный вход, см. RegistrationAccept
	static LoginRefuse = "LoginRefuse"; // отклонение запроса, см. RegistrationRefuse
	
	static Kick = "Kick"; // сервер отключил тебя.
	
	static Invite = "Invite"; // отправить приглашение поиграть игроку {reciever: userid}
	static InviteCancelled = "InviteCancelled"; // приглашение откланено {reason: ..., invite: {from: userid, to: userid, duration: seconds}}
	static InviteCancel = "InviteCancel"; // отклонить своё или чужое приглашение {sender: userid, reciever: userid}
	static InviteAccept = "InviteAccept"; // принять чужое приглашение {sender: userid}
	
	static GameplayTurn = "GameplayTurn"; // см. ниже:
		/*
			когда игрок нажал завершить ход, отправляется на сервер {action: удобные тебе данные об действии игрока, state: состояние доски после хода}
			после этого сервер отправляет всем это сообщение с данными {turn: {turn: данные о действии которые ты передал в action, fieldState: состояние доски после ходаm turnOwner: чей ход был сделан}, newTurnOwner: айди игрока чей сейчас теперь ход}
		*/
	static GameplayFinish = "GameplayFinish"; // когда хост считает что один из игроков победил, он отправляет это сообщение на сервер {winner: пустая строка если ничья, иначе айди игрока-победителя}
	
	static GameStart = "GameStart"; // сервер отправляет когда начинает игру между двух игроков {matchId: айди матча, opponent: айди игрока-оппонента, role: host/guest} если role = host, то именно этот компьютер будет смотреть кто победил и отправлять эту информацию
	static GameEnd = "GameEnd"; // игра окончана {matchId: айди матча, winner: айди игрока-победителя либо пустая строка если ничья}
}
new ServerMessageType();

function ServerMessage(_type="Unknown", _data={}) constructor {
	type = _type;
	ID = "";
	reqid = "";
	data = _data;
	
	static Parse = function(_text) {
		var json = json_parse(_text);
		var msg = new ServerMessage(json.type);
		msg.data = json.data;
		msg.ID = json.ID;
		msg.reqid = json.reqid;
		return msg;
	}
	static toString = function() {
		var json = json_stringify({type, ID, reqid, data});
		return json;
	}
	
	static is = function(_type) {
		return type == _type;
	}
	
	static set_data = function(key, value) {
		data[$ key] = value;
	}
	static get_data = function(key) {
		return data[$ key];
	}
	static clear_data = function() {
		data = {};
	}
}
new ServerMessage();