function WarriorEffect() : GameEffect("warrior_ability") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		var _width = min(16, max(0, floor(_state.data.width)));
		var _height = min(16, max(0, floor(_state.data.height)));
		for (var _x = 0; _x < _width; _x++) for (var _y = 0; _y < _height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "warrior" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}
	get_targets = function(_state, _actor_id, _source) {
		var _cells = [];
		if !is_array(_source) || array_length(_source) != 2 return _cells;
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			var _figure = _state.get_figure(_source[0] + _dx, _source[1] + _dy);
			if _figure != undefined && _figure.owner_id != _actor_id && _figure.status == "active" array_push(_cells, [_source[0] + _dx, _source[1] + _dy]);
		}
		return _cells;
	}
	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _sources = get_sources(_state, _actor_id);
		var _source = Game.game_input.cell("source_cell", "game.input.warrior_source", _sources);
		if !variable_struct_exists(_partial, "source_cell") {
			return [_source];
		}
		if !Game.game_input.has_cell(_source, _partial.source_cell) {
			return [_source];
		}
		var _targets = get_targets(_state, _actor_id, _partial.source_cell);
		return [_source, Game.game_input.cell("target_cell", "game.input.warrior_target", _targets)];
	}
	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot use warrior ability now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 2 || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_specs[1], _inputs.target_cell) return {ok: false, error: "Invalid warrior target"};
		return {ok: true, error: ""};
	}
	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _source_figure = _next.get_figure(_inputs.source_cell[0], _inputs.source_cell[1]);
		var _target_figure = _next.get_figure(_inputs.target_cell[0], _inputs.target_cell[1]);
		_next.clear_cell(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.clear_cell(_inputs.target_cell[0], _inputs.target_cell[1]);
		_next.data.dropped[$ string(_source_figure.owner_id)]++;
		_next.data.dropped[$ string(_target_figure.owner_id)]++;
		return {ok: true, error: "", next_state: _next,
			animation_batches: [[{type: "hit", at: deep_copy(_inputs.target_cell), duration_frames: Settings.hit_animation_length}], [{type: "drop", figure_id: _source_figure.id, at: deep_copy(_inputs.source_cell)}, {type: "drop", figure_id: _target_figure.id, at: deep_copy(_inputs.target_cell)}]],
			events: [{type: "warrior_strike", source_id: _source_figure.id, target_id: _target_figure.id}]};
	}
}
