function MoveEffect() : GameEffect("move") constructor {
	get_owned_figure_cells = function(_state, _actor_id) {
		var _result = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.status == "active" && _figure.behaviour != "warrior" && _figure.behaviour != "archer" array_push(_result, [_x, _y]);
		}
		return _result;
	}
	get_target_cells = function(_state, _from) {
		var _result = [];
		if !is_array(_from) || array_length(_from) != 2 return _result;
		var _figure = _state.get_figure(_from[0], _from[1]);
		var _previous = _figure == undefined ? undefined : _state.get_previous_cell(_figure.id);
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			if !(_dx == 0 && _dy == 0) {
				var _cell = _state.get_cell(_from[0] + _dx, _from[1] + _dy);
				var _is_previous = _previous != undefined && _cell != undefined && _cell.x == _previous[0] && _cell.y == _previous[1];
				if _cell != undefined && _cell.figure == undefined && !_is_previous array_push(_result, [_cell.x, _cell.y]);
			}
		}
		return _result;
	}
	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _from = Game.game_input.cell("from_cell", "game.input.move_figure", get_owned_figure_cells(_state, _actor_id));
		if !variable_struct_exists(_partial, "from_cell") || !Game.game_input.has_cell(_from, _partial.from_cell) return [_from];
		return [_from, Game.game_input.cell("target_cell", "game.input.move_target", get_target_cells(_state, _partial.from_cell))];
	}
	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot move now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 2 || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_specs[1], _inputs.target_cell) return {ok: false, error: "Invalid move"};
		return {ok: true, error: ""};
	}
	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _figure = _next.get_figure(_inputs.from_cell[0], _inputs.from_cell[1]);
		_next.clear_cell(_inputs.from_cell[0], _inputs.from_cell[1]);
		_next.set_figure(_inputs.target_cell[0], _inputs.target_cell[1], _figure);
		array_push(_next.data.movement_history, {figure_id: _figure.id, from: deep_copy(_inputs.from_cell), to: deep_copy(_inputs.target_cell)});
		return {ok: true, error: "", next_state: _next, animation_batches: [[{type: "move", figure_id: _figure.id, from: deep_copy(_inputs.from_cell), to: deep_copy(_inputs.target_cell), duration_frames: Settings.move_animation_length}]], events: [{type: "figure_moved", figure_id: _figure.id}]};
	}
}
