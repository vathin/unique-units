in_scroll = 0;
scroll_element = undefined;
scroll_bar = noone;

with (ScrollBar) {
	if (viewport_has_scissor) {
		var _sc = viewport_gui;
		if point_in_rectangle(UI_controller.gui_mouse_x(), UI_controller.gui_mouse_y(), _sc.x, _sc.y, _sc.x + _sc.w, _sc.y + _sc.h) {
			other.in_scroll = 1;
			other.scroll_element = controlled_element;
			other.scroll_bar = id;
		}
	}
}
