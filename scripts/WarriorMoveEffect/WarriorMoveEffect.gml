/// A warrior turn is atomic: move first, then optionally strike an adjacent enemy.
/// The choices are data, so a different UI or a bot can drive the same effect.
function WarriorMoveEffect() : GameEffect("warrior_move") constructor {
	static get_sources = function(_state, _actor_id) {
		var _cells = [];
		var _width = min(16, max(0, floor(_state.data.width)));
		var _height = min(16, max(0, floor(_state.data.height)));
		for (var _x = 0; _x < _width; _x++) for (var _y = 0; _y < _height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "warrior" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}

	static get_move_cells = function(_state, _source) {
		var _cells = [];
		if !is_array(_source) || array_length(_source) != 2 return _cells;
		var _figure = _state.get_figure(_source[0], _source[1]);
		var _previous = _figure == undefined ? undefined : _state.get_previous_cell(_figure.id);
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			if !(_dx == 0 && _dy == 0) {
				var _cell = _state.get_cell(_source[0] + _dx, _source[1] + _dy);
				var _is_previous = _previous != undefined && _cell != undefined && _cell.x == _previous[0] && _cell.y == _previous[1];
				if _cell != undefined && _cell.figure == undefined && !_is_previous array_push(_cells, [_cell.x, _cell.y]);
			}
		}
		return _cells;
	}

	static get_strike_cells = function(_state, _actor_id, _destination) {
		var _cells = [];
		if !is_array(_destination) || array_length(_destination) != 2 return _cells;
		for (var _dx = -1; _dx <= 1; _dx++) {
			for (var _dy = -1; _dy <= 1; _dy++) {
				if !(_dx == 0 && _dy == 0) {
					var _figure = _state.get_figure(_destination[0] + _dx, _destination[1] + _dy);
					if _figure != undefined && _figure.owner_id != _actor_id && _figure.status == "active" {
						array_push(_cells, [_destination[0] + _dx, _destination[1] + _dy]);
					}
				}
			}
		}
		return _cells;
	}

	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _source = Game.game_input.cell("source_cell", "game.input.warrior_source", get_sources(_state, _actor_id));
		if !variable_struct_exists(_partial, "source_cell") {
			return [_source];
		}
		if !Game.game_input.has_cell(_source, _partial.source_cell) {
			return [_source];
		}
		var _target = Game.game_input.cell("target_cell", "game.input.move_target", get_move_cells(_state, _partial.source_cell));
		if !variable_struct_exists(_partial, "target_cell") || !Game.game_input.has_cell(_target, _partial.target_cell) {
			return [_source, _target];
		}
		return [_source, _target];
	}

	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot move now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 2 || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_specs[1], _inputs.target_cell) return {ok: false, error: "Invalid warrior move"};
		if abs(_inputs.target_cell[0] - _inputs.source_cell[0]) > 1
		or abs(_inputs.target_cell[1] - _inputs.source_cell[1]) > 1 {
			return {ok: false, error: "Warrior move must target an adjacent cell"};
		}
		if variable_struct_exists(_inputs, "strike_target") {
			var _strike_spec = Game.game_input.cell("strike_target", "game.input.warrior_target", get_strike_cells(_state, _actor_id, _inputs.target_cell));
			if !Game.game_input.has_cell(_strike_spec, _inputs.strike_target) return {ok: false, error: "Invalid warrior strike"};
		}
		return {ok: true, error: ""};
	}

	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _warrior = _next.get_figure(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.clear_cell(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.set_figure(_inputs.target_cell[0], _inputs.target_cell[1], _warrior);
		var _batches = [[{type: "move", figure_id: _warrior.id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell), duration_frames: Settings.move_animation_length}]];
		var _events = [{type: "figure_moved", figure_id: _warrior.id}];
		if variable_struct_exists(_inputs, "strike_target") {
			var _target = _next.get_figure(_inputs.strike_target[0], _inputs.strike_target[1]);
			_next.clear_cell(_inputs.target_cell[0], _inputs.target_cell[1]);
			_next.clear_cell(_inputs.strike_target[0], _inputs.strike_target[1]);
			_next.data.dropped[$ string(_warrior.owner_id)] += 1;
			_next.data.dropped[$ string(_target.owner_id)] += 1;
			array_push(_batches, [{type: "hit", at: deep_copy(_inputs.strike_target), duration_frames: Settings.hit_animation_length}]);
			array_push(_batches, [{type: "drop", figure_id: _warrior.id, at: deep_copy(_inputs.target_cell)}, {type: "drop", figure_id: _target.id, at: deep_copy(_inputs.strike_target)}]);
			array_push(_events, {type: "warrior_strike", source_id: _warrior.id, target_id: _target.id});
		}
		else {
			array_push(_next.data.movement_history, {figure_id: _warrior.id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell)});
		}
		return {ok: true, error: "", next_state: _next, animation_batches: _batches, events: _events};
	}
}
