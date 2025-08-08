// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameClass() constructor{
	do_every_step_list = [];
	do_every_step = function(list) {
		for (i = 0; i < array_length(list); i++) {
			list[i]()
		}
	}
	online_match = false;
	var server_id;
	var opponent;
	var role;
	user_data = new userData();
	in_match = false;
	
	
	start_online = function(_server_id, _opponent, _role) {
		server_id = _server_id;
		enemy = _opponent;
		role = _role;
		online_match = 1;
	}
	
	send_turn = function(_field_data, _action_data) {
		Server.send(new ServerMessage(ServerMessageType.GameplayTurn, {action: _action_data, state: _field_data}))
	}
	
	get_turn = function(_field_data, _action_data) {
		if _field_data.ex_turn_owner != O_LoginController._id{
			Game.game_loop_controller.import(_field_data);
			Game.game_loop_controller.import_action(_action_data[0]);
			if array_length(_action_data) > 1 {
				Game.game_loop_controller.import_action(_action_data[1])
			}
		}
	}
	
	init = function() {
		if online_match {
			if role == "host" {
				Player1 = new Player(O_LoginController._id, "local");
				Player2 = new Player(O_LoginController.enemy, "online");
			}
			else {
				Player1 = new Player(O_LoginController.enemy, "online");
				Player2 = new Player(O_LoginController._id, "local");
			}
		}
		else {
			Player1 = new Player(1, "local");
			Player2 = new Player(2, "local")
		}
		user_data.reset()
		game_loop_controller = new GameLoopController();
		field = new Field();
		game_data = new gameData();
		summon_controller = undefined;
		figure_action_controller = undefined;
		ability_input_controller = undefined;
		move_input_controller = undefined;
		Maps_list.start(global.map);
		in_match = 1
	}
	
	end_game = function() {
		online_match = 0;
		game_loop_controller = undefined;
		field = undefined;
		Player1 = undefined;
		Player2 = undefined;
		in_match = 0;
		do_every_step_list = [];
	}
}