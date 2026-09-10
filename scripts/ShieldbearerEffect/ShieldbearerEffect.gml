function ShieldbearerEffect() : GameEffect("shieldbearer_ability") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "shieldbearer" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}
	get_neighbors = function(_state, _source, _want_filled) {
		var _cells = [];
		if !is_array(_source) || array_length(_source) != 2 return _cells;
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			if !(_dx == 0 && _dy == 0) {
				var _cell = _state.get_cell(_source[0] + _dx, _source[1] + _dy);
				if _cell != undefined {
					if _want_filled && _cell.figure != undefined && _cell.figure.status != "conquesting" array_push(_cells, [_cell.x, _cell.y]);
					if !_want_filled && _cell.figure == undefined array_push(_cells, [_cell.x, _cell.y]);
				}
			}
		}
		return _cells;
	}
	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _source = Game.game_input.cell("source_cell", "game.input.shieldbearer_source", get_sources(_state, _actor_id));
		if !variable_struct_exists(_partial, "source_cell") || !Game.game_input.has_cell(_source, _partial.source_cell) return [_source];
		var _target = Game.game_input.cell("target_cell", "game.input.shieldbearer_figure", get_neighbors(_state, _partial.source_cell, true));
		if !variable_struct_exists(_partial, "target_cell") || !Game.game_input.has_cell(_target, _partial.target_cell) return [_source, _target];
		return [_source, _target, Game.game_input.cell("destination_cell", "game.input.shieldbearer_destination", get_neighbors(_state, _partial.source_cell, false))];
	}
	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot use shieldbearer ability now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 3 || !variable_struct_exists(_inputs, "destination_cell") || !Game.game_input.has_cell(_specs[2], _inputs.destination_cell) return {ok: false, error: "Invalid shieldbearer input"};
		return {ok: true, error: ""};
	}
	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _figure = _next.get_figure(_inputs.target_cell[0], _inputs.target_cell[1]);
		_next.clear_cell(_inputs.target_cell[0], _inputs.target_cell[1]);
		_next.set_figure(_inputs.destination_cell[0], _inputs.destination_cell[1], _figure);
		array_push(_next.data.movement_history, {figure_id: _figure.id, from: deep_copy(_inputs.target_cell), to: deep_copy(_inputs.destination_cell), is_ability: true});
		return {ok: true, error: "", next_state: _next, animation_batches: [[{type: "move", figure_id: _figure.id, from: deep_copy(_inputs.target_cell), to: deep_copy(_inputs.destination_cell), duration_frames: Settings.move_animation_length * 1.2}]], events: [{type: "shieldbearer_push", figure_id: _figure.id}]};
	}
}
