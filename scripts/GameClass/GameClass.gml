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
	local_player = undefined;
	
	
	start_online = function(_server_id, _opponent, _role) {
		server_id = _server_id;
		enemy = _opponent;
		role = _role;
		online_match = 1;
	}
	
	send_turn = function(_field_data, _action_data) {
		Server.send(new ServerMessage(ServerMessageType.GameplayTurn, {action: _action_data, state: _field_data, turnOwner: O_LoginController._id}))
	}
	
	get_turn = function(_field_data, _action_data) {
		if _field_data.ex_turn_owner != O_LoginController._id{
			if _field_data.import_field {
				Game.game_loop_controller.import(_field_data);
			}
			if _action_data != undefined {
				Game.game_loop_controller.import_action(_action_data[0]);
				if array_length(_action_data) > 1 {
					Game.game_loop_controller.import_action(_action_data[1]);
				}
			}
		}
	}
	
	get_enemy_deck = function(_deck_data) {
		var _id = O_LoginController.enemy;
		user_data.save(_id, {player_cards: _deck_data.cards, player_figures: _deck_data.figures});
		game_loop_controller.create_cards(Player1.player_id, 1);
		game_loop_controller.create_cards(Player2.player_id, 2);
		if global.turn_owner != O_LoginController._id {game_loop_controller.state = STATE_LIST.enemy_turn}
	}
	
	send_deck = function(_count = 0) {
		var _id = O_LoginController._id
		_export_data = {
			type: "GetEnemyDeck",
			cards: user_data.load(_id).player_cards,
			figures:  user_data.load(_id).player_figures,
			count: _count
		}
		field_state = game_loop_controller.export(_export_data);
		field_state.import_field = false;
		Server.send(new ServerMessage(ServerMessageType.GameplayTurn, {action: undefined, state: field_state, turnowner: O_LoginController._id}))
		//if _count == 1 {global.turn_owner = O_LoginController.enemy}
	}
	
	init = function() {
		if online_match {
			if role == "host" {
				Player1 = new Player(O_LoginController._id, "local");
				Player2 = new Player(O_LoginController.enemy, "online");
				//Player1.deck = O_DeckManager.get_selected_deck_names_list();
				local_player = Player1;
			}
			else {
				Player1 = new Player(O_LoginController.enemy, "online");
				Player2 = new Player(O_LoginController._id, "local");
				//Player2.deck = O_DeckManager.get_selected_deck_names_list();
				local_player = Player2;
			}
			user_data.reset();
			randomize();
			user_data.save(O_LoginController._id, {player_cards: O_DeckManager.get_selected_deck_names_list(),
				player_figures: array_shuffle(O_DeckManager.get_selected_deck_array())});
			//show_message(user_data.load(local_player.player_id));
		}
		else {
			Player1 = new Player(1, "local");
			Player2 = new Player(2, "local");
			user_data.reset()
		}
		game_loop_controller = new GameLoopController();
		field = new Field();
		game_data = new gameData();
		summon_controller = undefined;
		figure_action_controller = undefined;
		ability_input_controller = undefined;
		move_input_controller = undefined;
		Maps_list.start(global.map);
		in_match = 1;
		if global.turn_owner == O_LoginController._id {send_deck(0)}
	}
	
	end_game = function() {
		online_match = 0;
		game_loop_controller = undefined;
		field = undefined;
		Player1 = undefined;
		Player2 = undefined;
		local_player = undefined;
		in_match = 0;
		do_every_step_list = [];
	}
}