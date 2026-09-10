function SummonEffect() : GameEffect("summon") constructor {
	get_summon_cells = function(_state, _actor_id) {
		var _cells = [];
		var _player_key = string(_actor_id);
		if !variable_struct_exists(_state.data.players, _player_key) return _cells;
		var _player = _state.data.players[$ _player_key];
		var _side = variable_struct_exists(_player, "side") && _player.side != undefined ? _player.side : 0;
		var _opponent_id = undefined;
		var _player_keys = variable_struct_get_names(_state.data.players);
		for (var _player_index = 0; _player_index < array_length(_player_keys); _player_index++) {
			var _candidate = _state.data.players[$ _player_keys[_player_index]];
			if _candidate.id != _actor_id {
				_opponent_id = _candidate.id;
				break;
			}
		}
		var _middle_low = floor(_state.data.width / 2) - 1;
		var _middle_high = floor(_state.data.width / 2);
		var _home_limit = floor(_state.data.height / 2) - 1;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _cell = _state.get_cell(_x, _y);
				if _cell.figure == undefined {
					var _own_control = false;
					var _opponent_control = false;
					for (var _dx = -1; _dx <= 1; _dx++) {
						for (var _dy = -1; _dy <= 1; _dy++) {
							var _neighbor = _state.get_cell(_x + _dx, _y + _dy);
							if _neighbor != undefined && _neighbor.figure != undefined && _neighbor.figure.owner_id == _actor_id {
								_own_control = true;
							}
							if _neighbor != undefined && _neighbor.figure != undefined && _neighbor.figure.owner_id == _opponent_id {
								_opponent_control = true;
							}
						}
					}
					var _on_home_side = _side == 0 ? _y > _home_limit : _y <= _home_limit;
					var _is_middle = (_x == _middle_low || _x == _middle_high) && (_y == _middle_low || _y == _middle_high);
					var _allowed = (_on_home_side || _own_control) && !_opponent_control;
					if _is_middle && (_on_home_side || (_own_control && _opponent_control)) {
						_allowed = true;
					}
					if _allowed {
						array_push(_cells, [_x, _y]);
					}
				}
			}
		}
		return _cells;
	}

	get_inputs = function(_state, _actor_id, _partial_inputs = {}) {
		return [Game.game_input.cell("target_cell", "game.input.summon_target", get_summon_cells(_state, _actor_id))];
	}

	validate_inputs = function(_state, _actor_id, _inputs) {
		var _player_key = string(_actor_id);
		if !variable_struct_exists(_state.data.players, _player_key) || _state.data.active_player_id != _actor_id {
			return {ok: false, error: "Actor cannot summon now"};
		}
		var _player = _state.data.players[$ _player_key];
		if !_player.able_to_summon || !is_array(_player.deck) || array_length(_player.deck) <= 0 {
			return {ok: false, error: "No figure available for summon"};
		}
		var _spec = get_inputs(_state, _actor_id)[0];
		if !is_struct(_inputs) || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_spec, _inputs.target_cell) {
			return {ok: false, error: "Invalid summon target"};
		}
		return {ok: true, error: ""};
	}

	execute = function(_state, _actor_id, _inputs) {
		var _validation = validate_inputs(_state, _actor_id, _inputs);
		if !_validation.ok {
			return {ok: false, error: _validation.error, next_state: _state, animation_batches: [], events: []};
		}
		var _next_state = _state.clone();
		var _player = _next_state.data.players[$ string(_actor_id)];
		var _behaviour = array_pop(_player.deck);
		var _target = _inputs.target_cell;
		var _figure = {id: string(_next_state.data.next_figure_id), behaviour: _behaviour, owner_id: _actor_id, status: "active"};
		_next_state.data.next_figure_id++;
		_next_state.set_figure(_target[0], _target[1], _figure);
		return {
			ok: true,
			error: "",
			next_state: _next_state,
			animation_batches: [[{type: "summon", figure_id: _figure.id, at: deep_copy(_target), duration_frames: 20}]],
			events: [{type: "figure_summoned", figure_id: _figure.id, owner_id: _actor_id, behaviour: _behaviour, at: deep_copy(_target)}]
		};
	}
}
