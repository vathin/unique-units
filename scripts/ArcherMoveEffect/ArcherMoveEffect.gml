/// Pure archer movement. Every path cell must neighbour at least one figure;
/// different neighbouring groups are all valid movement routes.
function ArcherMoveEffect() : GameEffect("archer_move") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "archer" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}

	has_neighbour_figure = function(_state, _cell, _source) {
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			if !(_dx == 0 && _dy == 0) {
				var _x = _cell[0] + _dx;
				var _y = _cell[1] + _dy;
				if !(_x == _source[0] && _y == _source[1]) {
					var _figure = _state.get_figure(_x, _y);
					if _figure != undefined {
						return true;
					}
				}
			}
		}
		return false;
	}

	get_reachable = function(_state, _source) {
		var _paths = array_create(_state.data.width);
		var _visited = array_create(_state.data.width);
		for (var _x = 0; _x < _state.data.width; _x++) {
			_paths[_x] = array_create(_state.data.height, undefined);
			_visited[_x] = array_create(_state.data.height, false);
		}
		var _result = {cells: [], paths: _paths};
		if !is_array(_source) || array_length(_source) != 2 return _result;
		// The archer may only move while it remains connected to another figure.
		// Do not let a later path cell establish that connection from nothing.
		if !has_neighbour_figure(_state, _source, [-1, -1]) return _result;
		var _queue = [{cell: _source, path: [_source]}];
		_visited[_source[0]][_source[1]] = true;
		var _iterations_left = _state.data.width * _state.data.height;
		while array_length(_queue) > 0 && _iterations_left > 0 {
			_iterations_left--;
			var _node = _queue[0];
			array_delete(_queue, 0, 1);
			var _current = _node.cell;
			for (var _direction = 0; _direction < 4; _direction++) {
				var _dx = _direction == 0 ? -1 : (_direction == 1 ? 1 : 0);
				var _dy = _direction == 2 ? -1 : (_direction == 3 ? 1 : 0);
				var _candidate = [_current[0] + _dx, _current[1] + _dy];
				var _candidate_cell = _state.get_cell(_candidate[0], _candidate[1]);
				if _candidate_cell != undefined && !_visited[_candidate[0]][_candidate[1]] && _state.get_figure(_candidate[0], _candidate[1]) == undefined {
					_visited[_candidate[0]][_candidate[1]] = true;
					if has_neighbour_figure(_state, _candidate, _source) {
						var _path = deep_copy(_node.path);
						array_push(_path, _candidate);
						_result.paths[_candidate[0]][_candidate[1]] = _path;
						array_push(_result.cells, _candidate);
						array_push(_queue, {cell: _candidate, path: _path});
					}
				}
			}
		}
		return _result;
	}

	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _source = Game.game_input.cell("source_cell", "game.input.archer_source", get_sources(_state, _actor_id));
		if !variable_struct_exists(_partial, "source_cell") || !Game.game_input.has_cell(_source, _partial.source_cell) return [_source];
		var _reachable = get_reachable(_state, _partial.source_cell);
		return [_source, Game.game_input.cell("target_cell", "game.input.move_target", _reachable.cells)];
	}

	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot move now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 2 || !variable_struct_exists(_inputs, "target_cell") || !Game.game_input.has_cell(_specs[1], _inputs.target_cell) return {ok: false, error: "Invalid archer move"};
		return {ok: true, error: ""};
	}

	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _archer = _next.get_figure(_inputs.source_cell[0], _inputs.source_cell[1]);
		var _path = get_reachable(_state, _inputs.source_cell).paths[_inputs.target_cell[0]][_inputs.target_cell[1]];
		_next.clear_cell(_inputs.source_cell[0], _inputs.source_cell[1]);
		_next.set_figure(_inputs.target_cell[0], _inputs.target_cell[1], _archer);
		var _archer_id = _archer.figure_id;
		array_push(_next.data.movement_history, {figure_id: _archer_id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell)});
		var _batches = [];
		for (var _index = 0; _index < array_length(_path) - 1; _index++) array_push(_batches, [{type: "move", figure_id: _archer_id, from: deep_copy(_path[_index]), to: deep_copy(_path[_index + 1]), duration_frames: Settings.move_animation_length}]);
		return {ok: true, error: "", next_state: _next, animation_batches: _batches, events: [{type: "figure_moved", figure_id: _archer_id, trajectory: deep_copy(_path)}]};
	}
}
