// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameClass() constructor{
	do_every_step_list = [];
	do_every_step = function(list) {
		for (i = 0; i < array_length(list); i++) {
			list[i]();
		}
	}
	online_match = false;
	server_id = "";
	opponent = "";
	role = "host";
	user_data = new userData();
	in_match = false;
	local_player = undefined;
	local_match_mode = "local_vs_local";
	bot_controller = undefined;

	set_local_match_mode = function(_mode) {
		local_match_mode = _mode;
	}

	get_default_local_deck = function() {
		return {
			player_cards: ["trader", "archer", "shieldbearer", "warrior", "spearman"],
			player_figures: ["trader", "archer", "archer", "archer", "archer", "shieldbearer",
			"shieldbearer", "shieldbearer", "shieldbearer", "warrior", "warrior", "warrior",
			"warrior", "warrior", "warrior", "warrior", "spearman", "spearman", "spearman", "spearman"],
			player_deck_size: 20
		};
	}

	make_local_deck_data = function(_source_deck = undefined) {
		var _deck = get_default_local_deck();
		if _source_deck != undefined and is_struct(_source_deck) and variable_struct_exists(_source_deck, "player_figures") {
			if is_array(_source_deck.player_figures) and array_length(_source_deck.player_figures) > 0 {
				_deck = deep_copy(_source_deck);
			}
		}
		_deck.player_figures = array_shuffle(_deck.player_figures);
		_deck.player_deck_size = array_length(_deck.player_figures);
		return _deck;
	}


	start_online = function(_server_id, _opponent, _role) {
		server_id = _server_id;
		opponent = _opponent;
		role = _role;
		online_match = 1;
		Server.send(new ServerMessage(ServerMessageType.PlayerInfo, {player: opponent}))
	}

	send_turn = function(_field_data, _action_data) {
		Server.send(new ServerMessage(ServerMessageType.GameplayTurn, {action: _action_data, state: _field_data, turnOwner: O_Server._id}))
	}

	get_turn = function(_field_data, _action_data) {
		if _field_data.ex_turn_owner != O_Server._id{
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
		var _id = O_Server.enemy;
		user_data.save(_id, {player_cards: _deck_data.cards, player_figures: _deck_data.figures, player_deck_size: array_length(_deck_data.figures)});
		O_DeckManager.create_card_displays(O_Server._id, 0);
		O_DeckManager.create_card_displays(opponent, 1);
		if global.turn_owner != O_Server._id {game_loop_controller.state = STATE_LIST.enemy_turn}
	}

	send_deck = function(_count = 0) {
		var _id = O_Server._id;
		_export_data = {
			type: "GetEnemyDeck",
			cards: user_data.load(_id).player_cards,
			figures:  user_data.load(_id).player_figures,
			count: _count
		}
		field_state = game_loop_controller.export(_export_data);
		field_state.import_field = false;
		Server.send(new ServerMessage(ServerMessageType.GameplayTurn, {action: undefined, state: field_state, turnOwner: O_Server._id}))
	}

	init = function() {
		if online_match {
			if role == "host" {
				Player1 = new Player(O_Server._id, "local");
				Player2 = new Player(O_Server.enemy, "online");
				local_player = Player1;
			}
			else {
				Player1 = new Player(O_Server.enemy, "online");
				Player2 = new Player(O_Server._id, "local");
				local_player = Player2;
			}
			user_data.reset();
			randomize();
			user_data.save(O_Server._id, {player_cards: O_DeckManager.get_selected_deck_names_list(),
				player_figures: array_shuffle(O_DeckManager.get_selected_deck_array()),
				player_deck_size: array_length(O_DeckManager.get_selected_deck_array())});
		}
		else {
			var _player1_type = "local";
			var _player2_type = "local";
			if local_match_mode == "local_vs_bot" {
				_player2_type = "bot";
			}
			else if local_match_mode == "bot_vs_bot" {
				_player1_type = "bot";
				_player2_type = "bot";
			}
			Player1 = new Player(1, _player1_type);
			Player2 = new Player(2, _player2_type);
			local_player = Player1;
			if _player1_type != "local" {
				local_player = undefined;
			}
			global.turn_owner = Player1.player_id;
			user_data.reset();
			var _source_deck = undefined;
			if variable_global_exists("local_match_deck") and global.local_match_deck != undefined {
				_source_deck = global.local_match_deck;
			}
			user_data.save(Player1.player_id, make_local_deck_data(_source_deck));
			user_data.save(Player2.player_id, make_local_deck_data(_source_deck));
		}
		game_loop_controller = new GameLoopController();
		field = new Field();
		array_push(do_every_step_list, game_loop_controller.step);
		game_data = new gameData();
		bot_controller = undefined;
		summon_controller = undefined;
		figure_action_controller = undefined;
		ability_input_controller = undefined;
		move_input_controller = undefined;
		Maps_list.start(global.map);
		in_match = 1;
		if instance_exists(O_DeckManager) {
			O_DeckManager.clear_card_displays();
		}
		if !online_match and (Player1.player_type == "bot" or Player2.player_type == "bot") {
			bot_controller = new BotController();
			array_push(do_every_step_list, bot_controller.step);
		}
		if online_match and global.turn_owner == O_Server._id {send_deck(0)}
	}

	end_game = function() {
		online_match = 0;
		game_loop_controller = undefined;
		field = undefined;
		Player1 = undefined;
		Player2 = undefined;
		local_player = undefined;
		bot_controller = undefined;
		in_match = 0;
		do_every_step_list = [];
	}


}
