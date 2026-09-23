/// Registry and transaction boundary for pure rule execution.
function GameRules() constructor {
	// GameMaker initializes constructor static methods on the first instance.
	// Rules own input specifications, so establish GameInput before any effect
	// asks for GameInput.cell()/choice().
	input_schema = new GameInput();
	effects = {summon: new SummonEffect(), move: new MoveEffect(), archer_move: new ArcherMoveEffect(), warrior_move: new WarriorMoveEffect(), warrior_ability: new WarriorEffect(), spearman_ability: new SpearmanEffect(), shieldbearer_ability: new ShieldbearerEffect(), trader_ability: new TraderEffect()};

	get_effect = function(_effect_id) {
		if _effect_id == undefined {
			return undefined;
		}
		return variable_struct_exists(effects, string(_effect_id)) ? effects[$ string(_effect_id)] : undefined;
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
		if !is_struct(_state) || !variable_struct_exists(_state, "ensure_figure_ids") {
			return [];
		}
		_state.ensure_figure_ids();
		var _effect = get_effect(_effect_id);
		return _effect == undefined ? [] : _effect.get_inputs(_state, _actor_id,
			is_struct(_partial_inputs) ? _partial_inputs : {});
	}

	is_effect_cancelable = function(_state, _actor_id, _effect_id, _partial_inputs = {}, _progress = {}) {
		var _effect = get_effect(_effect_id);
		if _effect == undefined {
			return false;
		}
		return _effect.is_cancelable(_state, _actor_id, _partial_inputs, _progress);
	}

	can_summon = function(_state, _actor_id) {
		if !is_struct(_state) || !variable_struct_exists(_state, "data")
		|| !is_struct(_state.data) || !variable_struct_exists(_state.data, "players") {
			return false;
		}
		var _player_key = string(_actor_id);
		if !variable_struct_exists(_state.data.players, _player_key) {
			return false;
		}
		var _player = _state.data.players[$ _player_key];
		if !_player.able_to_summon || !is_array(_player.deck) || array_length(_player.deck) <= 0 {
			return false;
		}
		var _specs = get_inputs(_state, _actor_id, "summon", {});
		return array_length(_specs) > 0 && is_array(_specs[0].allowed_cells) && array_length(_specs[0].allowed_cells) > 0;
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

}
