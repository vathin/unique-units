/// Serializable logical match state. It deliberately contains no UI objects,
/// sprites, animation controllers, or references to the live Field.
function GameState(_data = undefined) constructor {
	if (_data == undefined) {
		data = {
			schema_version: 1,
			revision: 0,
			map: "map1",
			width: 6,
			height: 6,
			active_player_id: undefined,
			cells: [],
			players: {},
			movement_history: [],
			captured: {},
			dropped: {},
			next_figure_id: 1
		};
		for (var _x = 0; _x < data.width; _x++) {
			data.cells[_x] = [];
			for (var _y = 0; _y < data.height; _y++) {
				data.cells[_x][_y] = {x: _x, y: _y, figure: undefined, can_be_conquested: false};
			}
		}
	}
	else {
		data = _data;
	}

	clone = function() {
		return new GameState(deep_copy(data));
	}

	serialize = function() {
		return deep_copy(data);
	}

	is_inside = function(_x, _y) {
		return _x >= 0 && _x < data.width && _y >= 0 && _y < data.height;
	}

	get_cell = function(_x, _y) {
		if !is_inside(_x, _y) {
			return undefined;
		}
		return data.cells[_x][_y];
	}

	get_figure = function(_x, _y) {
		var _cell = get_cell(_x, _y);
		return _cell == undefined ? undefined : _cell.figure;
	}

	set_figure = function(_x, _y, _figure) {
		var _cell = get_cell(_x, _y);
		if _cell == undefined {
			return false;
		}
		_cell.figure = _figure;
		return true;
	}

	clear_cell = function(_x, _y) {
		return set_figure(_x, _y, undefined);
	}

	get_previous_cell = function(_figure_id) {
		for (var _index = array_length(data.movement_history) - 1; _index >= 0; _index--) {
			var _move = data.movement_history[_index];
			if string(_move.figure_id) == string(_figure_id) {
				return deep_copy(_move.from);
			}
		}
		return undefined;
	}

	add_player = function(_player_id, _deck = [], _side = undefined) {
		var _key = string(_player_id);
		data.players[$ _key] = {id: _player_id, deck: deep_copy(_deck), able_to_summon: true, side: _side};
		data.captured[$ _key] = 0;
		data.dropped[$ _key] = 0;
	}
}
