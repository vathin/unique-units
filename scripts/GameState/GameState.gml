/// Serializable logical match state. It deliberately contains no UI objects,
/// sprites, animation controllers, or references to the live Field.
function GameState(_data = undefined) constructor {
	if (_data == undefined) {
		data = {
			schema_version: 2,
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
			captured_figures: {},
			dropped_figures: {},
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

	// figure_id is the canonical identity of a logical figure. Do not use `id`:
	// HTML5 treats that name specially for some struct access paths.
	ensure_figure_ids = function() {
		if !variable_struct_exists(data, "next_figure_id") || !is_real(data.next_figure_id) {
			data.next_figure_id = 1;
		}
		data.next_figure_id = max(1, floor(data.next_figure_id));
		var _used_ids = {};
		var _repaired = 0;
		var _normalized = 0;
		for (var _x = 0; _x < data.width; _x++) {
			for (var _y = 0; _y < data.height; _y++) {
				var _figure = get_figure(_x, _y);
				if !is_struct(_figure) {
					continue;
				}
				if (!variable_struct_exists(_figure, "owner_id") || _figure.owner_id == undefined)
				&& variable_struct_exists(_figure, "owner") {
					_figure.owner_id = _figure.owner;
					_normalized++;
				}
				if !variable_struct_exists(_figure, "status") || _figure.status == undefined {
					var _legacy_state = variable_struct_exists(_figure, "state") ? _figure.state : undefined;
					var _status = "active";
					if is_struct(_legacy_state) {
						if variable_struct_exists(_legacy_state, "is_captured") && _legacy_state.is_captured _status = "captured";
						else if variable_struct_exists(_legacy_state, "is_conquesting") && _legacy_state.is_conquesting _status = "conquesting";
						else if variable_struct_exists(_legacy_state, "is_dropped") && _legacy_state.is_dropped _status = "dropped";
						else if variable_struct_exists(_legacy_state, "is_active") && !_legacy_state.is_active _status = "inactive";
					}
					_figure.status = _status;
					_normalized++;
				}
				var _candidate = variable_struct_exists(_figure, "figure_id") ? _figure.figure_id : undefined;
				var _id = _candidate == undefined ? "" : string(_candidate);
				if (_id == "" || _id == "undefined" || variable_struct_exists(_used_ids, _id)) {
					while variable_struct_exists(_used_ids, string(data.next_figure_id)) {
						data.next_figure_id++;
					}
					_id = string(data.next_figure_id);
					data.next_figure_id++;
					_repaired++;
				}
				_figure.figure_id = _id;
				_used_ids[$ _id] = true;
				while variable_struct_exists(_used_ids, string(data.next_figure_id)) {
					data.next_figure_id++;
				}
			}
		}
		if _repaired > 0 || _normalized > 0 {
			show_debug_message("GameState: normalized figures, ids=" + string(_repaired)
				+ ", legacy fields=" + string(_normalized));
		}
		return _repaired;
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
		data.players[$ _key] = {player_id: _player_id, deck: deep_copy(_deck), able_to_summon: true, side: _side};
		data.captured[$ _key] = 0;
		data.dropped[$ _key] = 0;
		data.captured_figures[$ _key] = [];
		data.dropped_figures[$ _key] = [];
	}

	add_captured_figure = function(_owner_id, _figure) {
		var _key = string(_owner_id);
		if !variable_struct_exists(data.captured_figures, _key) {
			data.captured_figures[$ _key] = [];
		}
		array_push(data.captured_figures[$ _key], deep_copy(_figure));
	}

	add_dropped_figure = function(_owner_id, _figure) {
		var _key = string(_owner_id);
		if !variable_struct_exists(data.dropped_figures, _key) {
			data.dropped_figures[$ _key] = [];
		}
		array_push(data.dropped_figures[$ _key], deep_copy(_figure));
	}
}
