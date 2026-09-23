/// Per-match UI input state. It contains coordinates and handlers only; rules
/// receive plain inputs through EffectAction and never consult this object.
function GameInputSession() constructor {
	selected_cell = undefined;
	clicked_cell = undefined;
	cell_handler = undefined;
	mark_sprite = S_Controlled_mark;

	set_handler = function(_handler) {
		cell_handler = _handler;
	}

	select = function(_cell) {
		selected_cell = _cell;
		clicked_cell = _cell;
	}

	click = function(_cell) {
		if _cell == undefined || cell_handler == undefined {
			return false;
		}
		clicked_cell = _cell;
		cell_handler(_cell);
		return true;
	}

	clear = function() {
		selected_cell = undefined;
		clicked_cell = undefined;
		cell_handler = undefined;
	}
}
