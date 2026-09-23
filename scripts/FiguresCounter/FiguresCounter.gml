// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FiguresCounter() constructor {
	player1_field_figures = 0;
	player2_field_figures = 0;
	current_player_figures = 20;
	figures_id_counter = 0;
	figures_to_capture = [];
	display_player_max_figures = 20;
	display_opponent_max_figures = 20;
	display_player_figures = 20;
	display_opponent_figures = 20;
	
	add_figure_to_capture = function(new_figure, owning_cell) {
		array_push(figures_to_capture, [new_figure, owning_cell])
	}
	
	get_field_figures = function(player) {
		if player == Game.Player1.player_id {return player1_field_figures}
		else {return player2_field_figures}
	}

	get_player_figures_amount = function(player) {
		if Game.game_state != undefined && variable_struct_exists(Game.game_state.data, "players")
		&& variable_struct_exists(Game.game_state.data.players, string(player)) {
			var _deck = Game.game_state.data.players[$ string(player)].deck;
			return is_array(_deck) ? array_length(_deck) : 0;
		}
		return 0;
	}

	change_field_figures_amount = function(player, amount) {							//кто прочитал тот дурак
		if player == Game.Player1.player_id {player1_field_figures += amount}	
		else {player2_field_figures += amount}									
	}

	get_figure_id = function() {
		figures_id_counter ++;
		return string(figures_id_counter-1);
	}
	
	get_display_player = function() {
		if Game.online_match {
			return O_Server._id;
		}
		return global.turn_owner;
	}
	
	get_display_opponent = function() {
		if Game.online_match {
			return Game.opponent;
		}
		return Game.game_loop_controller.get_opponent(global.turn_owner);
	}

	sync_from_game_state = function(_state) {
		if (_state == undefined || !is_struct(_state) || !variable_struct_exists(_state, "data")
		|| !variable_struct_exists(_state.data, "players")) {
			return false;
		}
		var _player_id = get_display_player();
		var _opponent_id = get_display_opponent();
		var _keys = variable_struct_get_names(_state.data.players);
		if !variable_struct_exists(_state.data.players, string(_player_id)) && array_length(_keys) > 0 {
			_player_id = _state.data.players[$ _keys[0]].player_id;
		}
		if !variable_struct_exists(_state.data.players, string(_opponent_id)) {
			for (var _index = 0; _index < array_length(_keys); _index++) {
				var _candidate_id = _state.data.players[$ _keys[_index]].player_id;
				if string(_candidate_id) != string(_player_id) {
					_opponent_id = _candidate_id;
					break;
				}
			}
		}
		var _player = variable_struct_exists(_state.data.players, string(_player_id))
			? _state.data.players[$ string(_player_id)] : undefined;
		var _opponent = variable_struct_exists(_state.data.players, string(_opponent_id))
			? _state.data.players[$ string(_opponent_id)] : undefined;
		display_player_figures = _player != undefined && is_array(_player.deck) ? array_length(_player.deck) : 0;
		display_opponent_figures = _opponent != undefined && is_array(_opponent.deck) ? array_length(_opponent.deck) : 0;
		current_player_figures = display_player_figures;
		display_player_max_figures = max(display_player_max_figures, display_player_figures);
		display_opponent_max_figures = max(display_opponent_max_figures, display_opponent_figures);
		return true;
	}

	update_captured_figures_array = function() {
		if array_length(figures_to_capture) > 0 {
			while array_length(figures_to_capture) > 0 {
				capture_figure = array_pop(figures_to_capture);
				Game.game_loop_controller.add_captured_figure(Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				capture_figure[0].capture(1);
				capture_figure[1].clear();
				place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				place.add_figure(capture_figure[0], 1);
			}
		}
	}

	update_turn = function() {
		if Game.game_state != undefined && Game.game_rules != undefined && sync_from_game_state(Game.game_state) {
			player1_field_figures = Game.game_rules.get_active_figure_count(Game.game_state, Game.Player1.player_id);
			player2_field_figures = Game.game_rules.get_active_figure_count(Game.game_state, Game.Player2.player_id);
			update_ui_counter();
			return;
		}
		player1_field_figures = array_length(Game.field.get_player_field_figures(Game.Player1.player_id));
		player2_field_figures = array_length(Game.field.get_player_field_figures(Game.Player2.player_id));
		var _turn_data = global.turn_owner != undefined ? Game.user_data.load(global.turn_owner) : undefined;
		current_player_figures = is_struct(_turn_data) && variable_struct_exists(_turn_data, "player_figures") && is_array(_turn_data.player_figures)
			? array_length(_turn_data.player_figures) : 0;
		update_display_figures();
		if current_player_figures <= 0 or (get_field_figures(global.turn_owner) >= Settings.max_field_figures){
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 0
		}
		else {
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 1
		}
		update_captured_figures_array();
		update_ui_counter();
	}
	
	update_display_figures = function() {
		if Game.game_state != undefined && sync_from_game_state(Game.game_state) {
			return;
		}
		var _display_player = get_display_player();
		var _display_opponent = get_display_opponent();
		var _player_data = _display_player != undefined ? Game.user_data.load(_display_player) : undefined;
		var _opponent_data = _display_opponent != undefined ? Game.user_data.load(_display_opponent) : undefined;
		display_player_figures = is_struct(_player_data) && variable_struct_exists(_player_data, "player_figures") && is_array(_player_data.player_figures)
			? array_length(_player_data.player_figures) : 0;
		display_opponent_figures = is_struct(_opponent_data) && variable_struct_exists(_opponent_data, "player_figures") && is_array(_opponent_data.player_figures)
			? array_length(_opponent_data.player_figures) : 0;
		display_player_max_figures = is_struct(_player_data) && variable_struct_exists(_player_data, "player_deck_size")
			? _player_data.player_deck_size : display_player_figures;
		display_opponent_max_figures = is_struct(_opponent_data) && variable_struct_exists(_opponent_data, "player_deck_size")
			? _opponent_data.player_deck_size : display_opponent_figures;
	}

	update_ui_counter = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "PlayerFiguresText", get_field_figures(get_display_player()));
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "OpponentFiguresText", get_field_figures(get_display_opponent()));
	}
	
	display_available_figures = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "AvailableFiguresCount", string(display_player_figures) + 
		"/" + string(display_player_max_figures));
	}
	
	clear_available_figures_text = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "AvailableFiguresCount", "");
	}
	
	display_opponent_available_figures = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "EnemyDeckCount", string(display_opponent_figures) + 
		"/" + string(display_opponent_max_figures));
	}

	get_summon_figures_amount = function(player) {
		if player == Game.Player1.player_id {
			if get_player_figures_amount(player) < Settings.max_field_figures - player1_field_figures {return get_player_figures_amount(player)}
			else {return Settings.max_field_figures - player1_field_figures}}
		else {
			if get_player_figures_amount(player) < Settings.max_field_figures - player2_field_figures {return get_player_figures_amount(player)}
			else {return Settings.max_field_figures - player2_field_figures}}
	}

	get_current_player_figures = function() {
		return current_player_figures;
	}

	export = function() {
		export_data = {
			ex_player1_field_figures: player1_field_figures,
			ex_player2_field_figures: player2_field_figures,
			ex_figures_id_counter: figures_id_counter
		}
			return export_data;
	}

	import = function(import_data) {
		player1_field_figures = import_data.ex_player1_field_figures;
		player2_field_figures = import_data.ex_player2_field_figures;
		figures_id_counter = import_data.ex_figures_id_counter;
		update_turn();
	}
}
