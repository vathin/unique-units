/// Registry and transaction boundary for pure rule execution.
function GameRules() constructor {
	effects = {summon: new SummonEffect(), move: new MoveEffect(), archer_move: new ArcherMoveEffect(), warrior_move: new WarriorMoveEffect(), warrior_ability: new WarriorEffect(), spearman_ability: new SpearmanEffect(), shieldbearer_ability: new ShieldbearerEffect(), trader_ability: new TraderEffect()};

	get_effect = function(_effect_id) {
		return variable_struct_exists(effects, _effect_id) ? effects[$ _effect_id] : undefined;
	}

	create_match_state = function(_map, _player1, _player2, _player1_deck, _player2_deck, _active_player_id) {
		var _state = new GameState();
		_state.data.map = _map;
		_state.add_player(_player1.player_id, _player1_deck, 0);
		_state.add_player(_player2.player_id, _player2_deck, 1);
		_state.data.active_player_id = _active_player_id;
		Maps_list.select_map(_map);
		var _zones = Maps_list.get_cells_for_conquest();
		for (var _zone_index = 0; _zone_index < array_length(_zones); _zone_index++) {
			var _zone = _zones[_zone_index];
			for (var _cell_index = 0; _cell_index < array_length(_zone); _cell_index++) {
				var _cell_data = _zone[_cell_index];
				var _cell = _state.get_cell(_cell_data[0], _cell_data[1]);
				if _cell != undefined {
					_cell.can_be_conquested = true;
				}
			}
		}
		return _state;
	}

	get_inputs = function(_state, _actor_id, _effect_id, _partial_inputs = {}) {
		if is_struct(_state) && variable_struct_exists(_state, "ensure_figure_ids") {
			_state.ensure_figure_ids();
		}
		var _effect = get_effect(_effect_id);
		return _effect == undefined ? [] : _effect.get_inputs(_state, _actor_id, _partial_inputs);
	}

	execute = function(_state, _actor_id, _intent) {
		if !is_struct(_state) || !variable_struct_exists(_state, "ensure_figure_ids") {
			return {ok: false, error: "Invalid game state", next_state: _state, animation_batches: [], events: []};
		}
		_state.ensure_figure_ids();
		if !is_struct(_intent) || !variable_struct_exists(_intent, "effect_id") {
			return {ok: false, error: "Missing effect id", next_state: _state, animation_batches: [], events: []};
		}
		var _effect = get_effect(_intent.effect_id);
		if _effect == undefined {
			return {ok: false, error: "Unknown effect", next_state: _state, animation_batches: [], events: []};
		}
		var _inputs = variable_struct_exists(_intent, "inputs") ? _intent.inputs : {};
		return _effect.execute(_state, _actor_id, _inputs);
	}

	get_player_ids = function(_state) {
		var _players = [undefined, undefined];
		var _keys = variable_struct_get_names(_state.data.players);
		for (var _index = 0; _index < array_length(_keys); _index++) {
			var _player = _state.data.players[$ _keys[_index]];
			var _side = _index;
			if variable_struct_exists(_player, "side") && _player.side != undefined {
				_side = _player.side;
			}
			if (_side >= 0 && _side < 2) {
				_players[_side] = _player.player_id;
			}
		}
		for (var _index = 0; _index < min(2, array_length(_keys)); _index++) {
			if (_players[_index] == undefined) {
				_players[_index] = _state.data.players[$ _keys[_index]].player_id;
			}
		}
		return _players;
	}

	get_opponent_id = function(_state, _player_id) {
		if (_player_id == undefined || !variable_struct_exists(_state.data, "players")) {
			return undefined;
		}
		var _keys = variable_struct_get_names(_state.data.players);
		for (var _index = 0; _index < array_length(_keys); _index++) {
			var _candidate_id = _state.data.players[$ _keys[_index]].player_id;
			if string(_candidate_id) != string(_player_id) {
				return _candidate_id;
			}
		}
		return undefined;
	}

	get_active_figure_count = function(_state, _player_id) {
		var _count = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if (_figure != undefined && string(_figure.owner_id) == string(_player_id) && _figure.status == "active") {
					_count++;
				}
			}
		}
		return _count;
	}

	is_surrounded = function(_state, _x, _y) {
		for (var _dx = -1; _dx <= 1; _dx++) {
			for (var _dy = -1; _dy <= 1; _dy++) {
				if (_dx == 0 && _dy == 0) {
					continue;
				}
				var _neighbor = _state.get_cell(_x + _dx, _y + _dy);
				if (_neighbor != undefined && _neighbor.figure == undefined) {
					return false;
				}
			}
		}
		return true;
	}

	// Resolves every rule that happens between turns. The result is data only;
	// GameStatePresenter is the sole code that turns these events into visuals.
	resolve_turn = function(_state, _next_player_id) {
		if !is_struct(_state) || !variable_struct_exists(_state, "ensure_figure_ids") {
			return {next_state: _state, animation_batches: [], events: []};
		}
		_state.ensure_figure_ids();
		var _next = _state.clone();
		if !variable_struct_exists(_next.data, "captured") {
			_next.data.captured = {};
		}
		if !variable_struct_exists(_next.data, "dropped") {
			_next.data.dropped = {};
		}
		if !variable_struct_exists(_next.data, "captured_figures") {
			_next.data.captured_figures = {};
		}
		if !variable_struct_exists(_next.data, "dropped_figures") {
			_next.data.dropped_figures = {};
		}
		if !variable_struct_exists(_next.data, "next_figure_id") || !is_real(_next.data.next_figure_id) {
			_next.data.next_figure_id = 1;
		}
		if !variable_struct_exists(_next.data, "revision") || !is_real(_next.data.revision) {
			_next.data.revision = 0;
		}
		var _batches = [];
		var _events = [];
		var _players = get_player_ids(_next);
		var _zones = Maps_list.get_cells_for_conquest();
		if !is_array(_zones) {
			_zones = [[], []];
		}
		var _player_keys = variable_struct_get_names(_next.data.players);
		for (var _player_index = 0; _player_index < array_length(_player_keys); _player_index++) {
			var _player_key = _player_keys[_player_index];
			if !variable_struct_exists(_next.data.captured, _player_key) {
				_next.data.captured[$ _player_key] = 0;
			}
			if !variable_struct_exists(_next.data.dropped, _player_key) {
				_next.data.dropped[$ _player_key] = 0;
			}
			if !variable_struct_exists(_next.data.captured_figures, _player_key) {
				_next.data.captured_figures[$ _player_key] = [];
			}
			if !variable_struct_exists(_next.data.dropped_figures, _player_key) {
				_next.data.dropped_figures[$ _player_key] = [];
			}
		}

		for (var _zone_index = 0; _zone_index < array_length(_zones); _zone_index++) {
			var _zone_owner = _players[_zone_index];
			var _zone_cells = _zones[_zone_index];
			if (_zone_owner == undefined || !is_array(_zone_cells)) {
				continue;
			}
			for (var _cell_index = 0; _cell_index < array_length(_zone_cells); _cell_index++) {
				var _at = _zone_cells[_cell_index];
				if !is_array(_at) || array_length(_at) < 2 {
					continue;
				}
				var _figure = _next.get_figure(_at[0], _at[1]);
				if (_figure == undefined || string(_figure.owner_id) == string(_zone_owner)
				|| (_figure.status != "active" && _figure.status != "dropped")) {
					continue;
				}
				_figure.status = "conquesting";
				_next.data.captured[$ string(_zone_owner)] += 1;
				var _zone_player = _next.data.players[$ string(_zone_owner)];
				if (_zone_player != undefined && is_array(_zone_player.deck) && array_length(_zone_player.deck) > 0) {
					var _reward_behaviour = array_pop(_zone_player.deck);
					var _reward = {figure_id: string(_next.data.next_figure_id), behaviour: _reward_behaviour, owner_id: _zone_owner, status: "captured"};
					_next.data.next_figure_id++;
					_next.add_captured_figure(_figure.owner_id, _reward);
					show_debug_message("Conquest: invader=" + string(_figure.figure_id)
						+ ", owner=" + string(_figure.owner_id)
						+ ", captured=" + string(_reward.behaviour)
						+ ", from_player=" + string(_zone_owner));
				}
				else {
					show_debug_message("Conquest: invader=" + string(_figure.figure_id)
						+ ", opponent deck is empty; no card reward available");
				}
				array_push(_batches, [{type: "conquest", figure_id: _figure.figure_id, at: deep_copy(_at), duration_frames: 30}]);
				array_push(_events, {type: "figure_conquested", figure_id: _figure.figure_id, at: deep_copy(_at), score_owner_id: _zone_owner});
			}
		}

		for (var _x = 0; _x < _next.data.width; _x++) {
			for (var _y = 0; _y < _next.data.height; _y++) {
				var _figure = _next.get_figure(_x, _y);
				if (_figure == undefined
				|| (_figure.status != "active" && _figure.status != "conquesting" && _figure.status != "dropped")
				|| !is_surrounded(_next, _x, _y)) {
					continue;
			}
			var _captor_id = get_opponent_id(_next, _figure.owner_id);
			if _captor_id == undefined {
				var _known_players = variable_struct_get_names(_next.data.players);
				show_debug_message("GameState integrity error: surrounded figure has no opponent; figure="
					+ string(_figure.figure_id) + ", owner=" + string(_figure.owner_id)
					+ ", players=" + json_stringify(_known_players));
				continue;
			}
			var _captured = deep_copy(_figure);
				_captured.status = "captured";
				_next.clear_cell(_x, _y);
				_next.add_captured_figure(_captor_id, _captured);
				_next.data.captured[$ string(_captor_id)] += 1;
			array_push(_batches, [{type: "capture", figure_id: _figure.figure_id, at: [_x, _y], duration_frames: Settings.hit_animation_length}]);
			array_push(_events, {type: "figure_captured", figure_id: _figure.figure_id, at: [_x, _y], captor_id: _captor_id});
			}
		}

		for (var _player_index = 0; _player_index < array_length(_players); _player_index++) {
			var _player_id = _players[_player_index];
			if _player_id == undefined {
				show_debug_message("GameState integrity error: missing player id for side=" + string(_player_index));
				continue;
			}
			var _player_key = string(_player_id);
			if !variable_struct_exists(_next.data.players, _player_key) {
				show_debug_message("GameState integrity error: missing player=" + _player_key);
				continue;
			}
			var _player = _next.data.players[$ _player_key];
			_player.able_to_summon = is_array(_player.deck) && array_length(_player.deck) > 0
				&& get_active_figure_count(_next, _player_id) < Settings.max_field_figures;
		}
		_next.data.active_player_id = _next_player_id;
		_next.data.revision++;
		return {next_state: _next, animation_batches: _batches, events: _events};
	}

	from_legacy_match = function(_deck_source_state = undefined) {
		var _state = new GameState();
		if Game.field == undefined {
			return _state;
		}
		_state.data.map = global.map;
		_state.data.width = Game.field.field_width;
		_state.data.height = Game.field.field_height;
		_state.data.active_player_id = global.turn_owner;
		_state.data.movement_history = deep_copy(Game.field.movement_array);
		_state.data.cells = [];
		var _next_figure_id = 1;
		var _used_figure_ids = {};
		var get_unique_figure_id = function(_candidate_id) {
			var _id = _candidate_id == undefined ? "" : string(_candidate_id);
			if (_id == "" || _id == "undefined" || variable_struct_exists(_used_figure_ids, _id)) {
				while variable_struct_exists(_used_figure_ids, string(_next_figure_id)) {
					_next_figure_id++;
				}
				_id = string(_next_figure_id);
				_next_figure_id++;
			}
			_used_figure_ids[$ _id] = true;
			while variable_struct_exists(_used_figure_ids, string(_next_figure_id)) {
				_next_figure_id++;
			}
			return _id;
		}
		for (var _x = 0; _x < _state.data.width; _x++) {
			_state.data.cells[_x] = [];
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _legacy_cell = Game.field.get_cell(_x, _y);
				var _figure = undefined;
				if _legacy_cell != undefined && _legacy_cell.is_filled() {
					var _legacy_figure = _legacy_cell.filled_figure;
					var _legacy_id = variable_struct_exists(_legacy_figure, "figure_id") ? _legacy_figure.figure_id : undefined;
					var _legacy_id_text = get_unique_figure_id(_legacy_id);
					_legacy_figure.figure_id = _legacy_id_text;
					var _status = "inactive";
					if _legacy_figure.state.is_active _status = "active";
					else if _legacy_figure.state.is_dropped _status = "dropped";
					else if _legacy_figure.state.is_conquesting _status = "conquesting";
					else if _legacy_figure.state.is_captured _status = "captured";
					_figure = {figure_id: _legacy_id_text, behaviour: string(_legacy_figure.behaviour), owner_id: _legacy_figure.owner, status: _status};
				}
				_state.data.cells[_x][_y] = {x: _x, y: _y, figure: _figure, can_be_conquested: _legacy_cell != undefined && _legacy_cell.can_be_conquested};
			}
		}
		_state.data.next_figure_id = _next_figure_id;
		var _players = [Game.Player1, Game.Player2];
		for (var _index = 0; _index < array_length(_players); _index++) {
			var _player = _players[_index];
			if _player != undefined {
				var _player_key = string(_player.player_id);
				var _deck = undefined;
				// Field is still legacy-owned during the migration, but the deck is
				// changed by pure effects.  Re-reading it from HTML storage here could
				// restore an old top card between a preview and confirmation.
				if _deck_source_state != undefined
				&& variable_struct_exists(_deck_source_state.data.players, _player_key) {
					var _source_player = _deck_source_state.data.players[$ _player_key];
					if is_array(_source_player.deck) {
						_deck = deep_copy(_source_player.deck);
					}
				}
				if _deck == undefined {
					var _deck_data = Game.user_data.load(_player.player_id);
					_deck = is_struct(_deck_data) && variable_struct_exists(_deck_data, "player_figures") ? _deck_data.player_figures : [];
				}
				_state.add_player(_player.player_id, _deck, _index);
				_state.data.players[$ string(_player.player_id)].able_to_summon = _player.able_to_summon;
				if (_player.player_id == Game.Player1.player_id) {
					_state.data.captured[$ string(_player.player_id)] = Game.game_loop_controller.player1_captured;
					_state.data.dropped[$ string(_player.player_id)] = array_length(Game.field.player1_dropped.figures);
				}
				else {
					_state.data.captured[$ string(_player.player_id)] = Game.game_loop_controller.player2_captured;
					_state.data.dropped[$ string(_player.player_id)] = array_length(Game.field.player2_dropped.figures);
				}
			}
		}
		// Import piles as state as well. They are part of the match: a captured
		// card can later be exchanged for a field figure, so counters alone lose
		// information required by the rules.
		var _pile_player_ids = [Game.Player1.player_id, Game.Player2.player_id];
		for (var _pile_player_index = 0; _pile_player_index < array_length(_pile_player_ids); _pile_player_index++) {
			var _pile_owner_id = _pile_player_ids[_pile_player_index];
			var _places = [
				{place: Game.field.get_place("capture", _pile_owner_id), target: _state.data.captured_figures, status: "captured"},
				{place: Game.field.get_place("drop", _pile_owner_id), target: _state.data.dropped_figures, status: "dropped"}
			];
			for (var _place_index = 0; _place_index < array_length(_places); _place_index++) {
				var _place_data = _places[_place_index];
				if (_place_data.place == undefined || !is_array(_place_data.place.figures)) {
					continue;
				}
				for (var _figure_index = 0; _figure_index < array_length(_place_data.place.figures); _figure_index++) {
					var _pile_figure = _place_data.place.figures[_figure_index];
					var _pile_candidate_id = variable_struct_exists(_pile_figure, "figure_id") ? _pile_figure.figure_id : undefined;
					var _pile_id = get_unique_figure_id(_pile_candidate_id);
					_pile_figure.figure_id = _pile_id;
					var _state_pile = _place_data.target[$ string(_pile_owner_id)];
					array_push(_state_pile, {
						figure_id: _pile_id,
						behaviour: string(_pile_figure.behaviour),
						owner_id: _pile_figure.owner,
						status: _place_data.status
					});
					_place_data.target[$ string(_pile_owner_id)] = _state_pile;
				}
			}
		}
		return _state;
	}
}
