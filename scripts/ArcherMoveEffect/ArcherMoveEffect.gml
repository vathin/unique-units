/// Pure archer movement. A reachable empty cell must stay connected to the
/// same neighbouring-figure group; the returned path is used for animation.
function ArcherMoveEffect() : GameEffect("archer_move") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "archer" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}

	get_neighbour_ids = function(_state, _cell, _source) {
		var _ids = [];
		for (var _dx = -1; _dx <= 1; _dx++) for (var _dy = -1; _dy <= 1; _dy++) {
			if !(_dx == 0 && _dy == 0) {
				var _x = _cell[0] + _dx;
				var _y = _cell[1] + _dy;
				if !(_x == _source[0] && _y == _source[1]) {
					var _figure = _state.get_figure(_x, _y);
					if _figure != undefined && array_get_index(_ids, _figure.id) == -1 array_push(_ids, _figure.id);
				}
			}
		}
		return _ids;
	}

	shares_id = function(_ids, _known_ids) {
		for (var _index = 0; _index < array_length(_ids); _index++) if array_get_index(_known_ids, _ids[_index]) != -1 return true;
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
		var _queue = [{cell: _source, path: [_source]}];
		var _known_ids = [];
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
					var _neighbours = get_neighbour_ids(_state, _candidate, _source);
					if array_length(_neighbours) > 0 && (array_length(_known_ids) == 0 || shares_id(_neighbours, _known_ids)) {
						for (var _id_index = 0; _id_index < array_length(_neighbours); _id_index++) if array_get_index(_known_ids, _neighbours[_id_index]) == -1 array_push(_known_ids, _neighbours[_id_index]);
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
		var _figure = _state.get_figure(_partial.source_cell[0], _partial.source_cell[1]);
		var _previous = _figure == undefined ? undefined : _state.get_previous_cell(_figure.id);
		if _previous != undefined {
			for (var _index = array_length(_reachable.cells) - 1; _index >= 0; _index--) {
				if _reachable.cells[_index][0] == _previous[0] && _reachable.cells[_index][1] == _previous[1] {
					array_delete(_reachable.cells, _index, 1);
				}
			}
		}
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
		array_push(_next.data.movement_history, {figure_id: _archer.id, from: deep_copy(_inputs.source_cell), to: deep_copy(_inputs.target_cell)});
		var _batches = [];
		for (var _index = 0; _index < array_length(_path) - 1; _index++) array_push(_batches, [{type: "move", figure_id: _archer.id, from: deep_copy(_path[_index]), to: deep_copy(_path[_index + 1]), duration_frames: Settings.move_animation_length}]);
		return {ok: true, error: "", next_state: _next, animation_batches: _batches, events: [{type: "figure_moved", figure_id: _archer.id, trajectory: deep_copy(_path)}]};
	}
}
