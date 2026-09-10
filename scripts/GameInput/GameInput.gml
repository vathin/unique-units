/// Input specifications are logical data. The UI renders these descriptions and
/// sends only selected values back to the effect.
function GameInput() constructor {
	static cell = function(_id, _title_key, _allowed_cells) {
		var _cells_copy = deep_copy(_allowed_cells);
		return {id: _id, type: "cell", title_key: _title_key, allowed_cells: _cells_copy, min: 1, max: 1};
	}

	static choice = function(_id, _title_key, _options) {
		return {id: _id, type: "choice", title_key: _title_key, options: deep_copy(_options), min: 1, max: 1};
	}

	static has_cell = function(_spec, _value) {
		if !is_array(_spec.allowed_cells) || !is_array(_value) || array_length(_value) != 2 {
			return false;
		}
		var _count = array_length(_spec.allowed_cells);
		for (var _index = 0; _index < _count; _index++) {
			var _candidate = _spec.allowed_cells[_index];
			if _candidate[0] == _value[0] && _candidate[1] == _value[1] {
				return true;
			}
		}
		return false;
	}

	static has_choice = function(_spec, _value) {
		if !is_array(_spec.options) {
			return false;
		}
		for (var _index = 0; _index < array_length(_spec.options); _index++) {
			if _spec.options[_index].id == _value {
				return true;
			}
		}
		return false;
	}
}
