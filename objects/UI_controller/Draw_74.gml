var _s = gpu_get_scissor();
var _window_width = window_get_width();
var _window_height = window_get_height();
if (_s.x != 0 || _s.y != 0 || _s.w != _window_width || _s.h != _window_height) {
	var _debug_key = string(_s.x) + "," + string(_s.y) + "," + string(_s.w) + "," + string(_s.h)
		+ ":" + string(gui_width()) + "x" + string(gui_height())
		+ ":" + string(_window_width) + "x" + string(_window_height);
	if (_debug_key != last_scissor_draw74_debug_key) {
		last_scissor_draw74_debug_key = _debug_key;
		show_debug_message(
			"UI scissor draw74 reset: previous_gpu="
			+ string(_s.x) + "," + string(_s.y) + "," + string(_s.w) + "," + string(_s.h)
			+ ", reset_gpu=0,0," + string(_window_width) + "," + string(_window_height)
			+ ", gui=" + string(gui_width()) + "x" + string(gui_height())
			+ ", window=" + string(_window_width) + "x" + string(_window_height)
		);
	}
	gpu_set_scissor(0, 0, _window_width, _window_height);
}
