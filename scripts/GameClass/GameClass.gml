// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameClass() constructor{
	do_every_step_list = [];
	last_step_callback_warning = 0;
	do_every_step = function(list) {
		var _step_count = array_length(list);
		if _step_count > 32 && _step_count != last_step_callback_warning {
			show_debug_message("Game step callbacks: unusually high count=" + string(_step_count));
			last_step_callback_warning = _step_count;
		}
		else if _step_count <= 32 {
			last_step_callback_warning = 0;
		}
		for (var _step_index = 0; _step_index < _step_count && _step_index < array_length(list); _step_index++) {
			list[_step_index]();
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
	is_simulating = false;
	game_state = undefined;
	input_session = new GameInputSession();
	Player1 = undefined;
	Player2 = undefined;
	pending_gameplay_setups = [];
	// Match decks are transient setup data. Persistent deck-building data lives in
	// user_data, while a running match is owned exclusively by GameState.
	match_decks = {};
	match_state_initialized = false;
	game_rules = new GameRules();
	game_state_presenter = undefined;
	effect_choice_view_factory = function(_spec, _on_select) {
		return new EffectChoiceView(_spec, _on_select);
	}

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

	set_match_deck = function(_player_id, _deck) {
		if _player_id == undefined {
			return false;
		}
		match_decks[$ string(_player_id)] = is_array(_deck) ? deep_copy(_deck) : [];
		return true;
	}

	get_match_deck = function(_player_id) {
		var _key = string(_player_id);
		return variable_struct_exists(match_decks, _key) ? deep_copy(match_decks[$ _key]) : undefined;
	}

	try_initialize_match_state = function() {
		if match_state_initialized || Player1 == undefined || Player2 == undefined {
			return false;
		}
		var _player1_deck = get_match_deck(Player1.player_id);
		var _player2_deck = get_match_deck(Player2.player_id);
		if _player1_deck == undefined || _player2_deck == undefined {
			return false;
		}
		game_state = game_rules.create_match_state(global.map, Player1, Player2,
			_player1_deck, _player2_deck, global.turn_owner);
		match_state_initialized = true;
		if game_state_presenter != undefined {
			game_state_presenter.apply_state(game_state);
		}
		return true;
	}


	start_online = function(_server_id, _opponent, _role) {
		server_id = _server_id;
		opponent = _opponent;
		role = _role;
		online_match = 1;
		network_revision = 0;
		Server.send(new ServerMessage(ServerMessageType.PlayerInfo, {player: opponent}))
	}

	send_gameplay_intent = function(_effect_id, _inputs) {
		Server.send(new ServerMessage(ServerMessageType.GameplayIntent, {
			base_revision: network_revision,
			effect_id: _effect_id,
			inputs: deep_copy(_inputs)
		}));
	}

	send_authoritative_state = function(_logic_state, _animation_batches) {
		if role != "host" || _logic_state == undefined {
			return false;
		}
		var _next_turn_owner = _logic_state.data.active_player_id;
		var _revision = network_revision + 1;
		network_revision = _revision;
		Server.send(new ServerMessage(ServerMessageType.GameplayState, {
			revision: _revision,
			logic_state: _logic_state,
			animation_batches: deep_copy(_animation_batches),
			events: [],
			next_turn_owner: _next_turn_owner
		}));
		return true;
	}

	receive_gameplay_intent = function(_intent) {
		if role != "host" || game_loop_controller == undefined || !is_struct(_intent) {
			return false;
		}
		if _intent.actor_id != global.turn_owner || !variable_struct_exists(_intent, "effect_id") || !variable_struct_exists(_intent, "inputs") {
			show_debug_message("GameplayIntent ignored: invalid actor or payload");
			return false;
		}
		var _action = new EffectAction(_intent.effect_id, _intent.actor_id, _intent.inputs);
		game_loop_controller.set_action(_action);
		game_loop_controller.ready_to_send = 1;
		game_loop_controller.end_move();
		return true;
	}

	receive_authoritative_state = function(_logic_state, _animation_batches, _revision) {
		if _revision <= network_revision {
			return true;
		}
		network_revision = _revision;
		if _logic_state == undefined || !is_struct(_logic_state) {
			show_debug_message("GameplayState ignored: logic_state is missing");
			return false;
		}
		var _confirmed_state = new GameState(deep_copy(_logic_state));
		_confirmed_state.ensure_figure_ids();
		var _batches = is_array(_animation_batches) ? _animation_batches : [];
		if game_state_presenter != undefined {
			game_state_presenter.commit(_confirmed_state, _batches);
		}
		else {
			game_state = _confirmed_state;
		}
		if game_loop_controller != undefined {
			game_loop_controller.turn_transition_post_processed = false;
			game_loop_controller.turn_transition_pending = true;
			game_loop_controller.state = STATE_LIST.animation;
			game_loop_controller.set_can_cancel(0);
		}
		return true;
	}

	send_gameplay_setup = function() {
		var _deck = get_match_deck(O_Server._id);
		if _deck == undefined {
			show_debug_message("GameplaySetup skipped: local match deck is missing");
			return false;
		}
		Server.send(new ServerMessage(ServerMessageType.GameplaySetup, {deck: _deck}));
		return true;
	}

	receive_gameplay_setup = function(_setup) {
		if !is_struct(_setup) || !variable_struct_exists(_setup, "actor_id") || !variable_struct_exists(_setup, "deck") {
			return false;
		}
		if Player1 == undefined || Player2 == undefined {
			array_push(pending_gameplay_setups, deep_copy(_setup));
			return true;
		}
		set_match_deck(_setup.actor_id, _setup.deck);
		return try_initialize_match_state();
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
			randomize();
			set_match_deck(O_Server._id, array_shuffle(O_DeckManager.get_selected_deck_array()));
			for (var _setup_index = 0; _setup_index < array_length(pending_gameplay_setups); _setup_index++) {
				receive_gameplay_setup(pending_gameplay_setups[_setup_index]);
			}
			pending_gameplay_setups = [];
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
			if (_player2_type == "bot") {
				UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "OpponentNickname", "Bot");
			}
			if _player1_type != "local" {
				local_player = undefined;
			}
			global.turn_owner = Player1.player_id;
			var _source_deck = undefined;
			if variable_global_exists("local_match_deck") and global.local_match_deck != undefined {
				_source_deck = global.local_match_deck;
			}
			set_match_deck(Player1.player_id, make_local_deck_data(_source_deck).player_figures);
			set_match_deck(Player2.player_id, make_local_deck_data(_source_deck).player_figures);
		}
		Maps_list.select_map(global.map);
		game_loop_controller = new GameLoopController();
		field = new Field();
		array_push(do_every_step_list, game_loop_controller.step);
		game_data = new gameData();
		bot_controller = undefined;
		summon_controller = undefined;
		figure_action_controller = undefined;
		ability_input_controller = undefined;
		move_input_controller = undefined;
		game_state_presenter = new GameStatePresenter();
		input_session.clear();
		input_session.set_handler(game_loop_controller.default_cell_click_action);
		if game_state != undefined {
			game_state_presenter.apply_state(game_state);
		}
		else {
			try_initialize_match_state();
		}
		array_push(do_every_step_list, game_state_presenter.step);
		in_match = 1;
		if instance_exists(O_DeckManager) {
			O_DeckManager.clear_card_displays();
		}
		if !online_match and (Player1.player_type == "bot" or Player2.player_type == "bot") {
			bot_controller = new BotController();
			array_push(do_every_step_list, bot_controller.step);
		}
		if online_match {send_gameplay_setup()}
	}

	end_game = function() {
		online_match = 0;
		game_loop_controller = undefined;
		field = undefined;
		Player1 = undefined;
		Player2 = undefined;
		local_player = undefined;
		bot_controller = undefined;
		game_state = undefined;
		input_session.clear();
		game_state_presenter = undefined;
		match_decks = {};
		match_state_initialized = false;
		in_match = 0;
		do_every_step_list = [];
	}


}
