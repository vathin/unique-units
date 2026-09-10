function SpearmanEffect() : GameEffect("spearman_ability") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "spearman" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}
	get_targets = function(_state, _source) {
		var _cells = [];
		var _directions = [[1, 0], [-1, 0], [0, 1], [0, -1]];
		if !is_array(_source) || array_length(_source) != 2 return _cells;
		var _figure = _state.get_figure(_source[0], _source[1]);
		var _previous = _figure == undefined ? undefined : _state.get_previous_cell(_figure.id);
		for (var _index = 0; _index < array_length(_directions); _index++) {
			var _direction = _directions[_index];
			var _middle = _state.get_cell(_source[0] + _direction[0], _source[1] + _direction[1]);
			var _target = _state.get_cell(_source[0] + _direction[0] * 2, _source[1] + _direction[1] * 2);
			var _is_previous = _previous != undefined && _target != undefined && _target.x == _previous[0] && _target.y == _previous[1];
			if _middle != undefined && _target != undefined && _middle.figure == undefined && _target.figure == undefined && !_is_previous array_push(_cells, [_target.x, _target.y]);
		}
		show_debug_message("Spearman effect: source=" + json_stringify(_source) + ", jump_targets=" + json_stringify(_cells));
		return _cells;
	}
	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _source = Game.game_input.cell("source_cell", "game.input.spearman_source", get_sources(_state, _actor_id));
		if !variable_struct_exists(_partial, "source_cell") || !Game.game_input.has_cell(_source, _partial.source_cell) return [_source];
		return [_source, Game.game_input.cell("target_cell", "game.input.spearman_target", get_targets(_state, _partial.source_cell))];
	}
	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot use spearman ability now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 2 || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_specs[1], _inputs.target_cell) return {ok: false, error: "Invalid spearman target"};
		return {ok: true, error: ""};
	}
	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _figure = _next.get_figure(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.clear_cell(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.set_figure(_inputs.target_cell[0], _inputs.target_cell[1], _figure);
		array_push(_next.data.movement_history, {figure_id: _figure.id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell), is_ability: true});
		return {ok: true, error: "", next_state: _next, animation_batches: [[{type: "move", figure_id: _figure.id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell), duration_frames: Settings.move_animation_length * 1.8}]], events: [{type: "spearman_jump", figure_id: _figure.id}]};
	}
}
