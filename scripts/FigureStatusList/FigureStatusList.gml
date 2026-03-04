function FigureStatusList() constructor{
	enum FIGURE_STATUS_LIST {
		will_be_captured,
		will_be_dropped,
		will_be_filled,
		will_be_moved,
		will_conquest,
		will_be_summoned,
		selected
	}
	
	static status_sprites_list = {
		will_be_captured: S_surrounded, //
		will_be_dropped: S_dropped, //
		will_be_moved: S_moved, //
		will_be_filled: S_moved, //
		will_conquest: S_conquest, //
		will_be_summoned: S_summoned, //
		selected: undefined //
	}
	
	static figure_status_array = ["will_be_captured", "will_be_dropped", "will_be_filled", "will_be_moved",
	"will_conquest", "will_be_summoned", "selected"];
	
	static status = function(_status) {
		return figure_status_array[_status];
	}
	
	static get_status_sprite = function(_status) {
		return status_sprites_list[$ _status]
	}
}

new FigureStatusList();