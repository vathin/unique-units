/// Registry and transaction boundary for pure rule execution.
function GameRules() constructor {
	effects = {summon: new SummonEffect(), move: new MoveEffect(), archer_move: new ArcherMoveEffect(), warrior_move: new WarriorMoveEffect(), warrior_ability: new WarriorEffect(), spearman_ability: new SpearmanEffect(), shieldbearer_ability: new ShieldbearerEffect(), trader_ability: new TraderEffect()};

	get_effect = function(_effect_id) {
		return variable_struct_exists(effects, _effect_id) ? effects[$ _effect_id] : undefined;
	}

	get_inputs = function(_state, _actor_id, _effect_id, _partial_inputs = {}) {
		var _effect = get_effect(_effect_id);
		return _effect == undefined ? [] : _effect.get_inputs(_state, _actor_id, _partial_inputs);
	}

	execute = function(_state, _actor_id, _intent) {
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

	from_legacy_match = function() {
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
		for (var _x = 0; _x < _state.data.width; _x++) {
			_state.data.cells[_x] = [];
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _legacy_cell = Game.field.get_cell(_x, _y);
				var _figure = undefined;
				if _legacy_cell != undefined && _legacy_cell.is_filled() {
					var _legacy_figure = _legacy_cell.filled_figure;
					var _legacy_id_number = real(string(_legacy_figure.figure_id));
					if _legacy_id_number >= _next_figure_id {
						_next_figure_id = floor(_legacy_id_number) + 1;
					}
					var _status = "inactive";
					if _legacy_figure.state.is_active _status = "active";
					else if _legacy_figure.state.is_dropped _status = "dropped";
					else if _legacy_figure.state.is_conquesting _status = "conquesting";
					else if _legacy_figure.state.is_captured _status = "captured";
					_figure = {id: string(_legacy_figure.figure_id), behaviour: string(_legacy_figure.behaviour), owner_id: _legacy_figure.owner, status: _status};
				}
				_state.data.cells[_x][_y] = {x: _x, y: _y, figure: _figure, can_be_conquested: _legacy_cell != undefined && _legacy_cell.can_be_conquested};
			}
		}
		_state.data.next_figure_id = _next_figure_id;
		var _players = [Game.Player1, Game.Player2];
		for (var _index = 0; _index < array_length(_players); _index++) {
			var _player = _players[_index];
			if _player != undefined {
				var _deck_data = Game.user_data.load(_player.player_id);
				var _deck = is_struct(_deck_data) && variable_struct_exists(_deck_data, "player_figures") ? _deck_data.player_figures : [];
				_state.add_player(_player.player_id, _deck, _index);
				_state.data.players[$ string(_player.player_id)].able_to_summon = _player.able_to_summon;
			}
		}
		return _state;
	}
}
