previous_scissor = UI_controller.last_scissor_gui;
if !is_scissor_default() {
	current_scissor = gpu_get_scissor();
	var _debug_key = string(current_scissor.x) + "," + string(current_scissor.y) + "," + string(current_scissor.w) + "," + string(current_scissor.h)
		+ ":" + string(UI_controller.gui_width()) + "x" + string(UI_controller.gui_height())
		+ ":" + string(window_get_width()) + "x" + string(window_get_height());
	if (_debug_key != UI_controller.last_scissor_clear_debug_key) {
		UI_controller.last_scissor_clear_debug_key = _debug_key;
		show_debug_message(
			"UI scissor clear: previous_gpu=" + string(current_scissor.x) + "," + string(current_scissor.y) + "," + string(current_scissor.w) + "," + string(current_scissor.h)
			+ ", reset_gpu=0,0," + string(window_get_width()) + "," + string(window_get_height())
			+ ", previous_gui=" + string(previous_scissor.x) + "," + string(previous_scissor.y) + "," + string(previous_scissor.w) + "," + string(previous_scissor.h)
			+ ", gui=" + string(UI_controller.gui_width()) + "x" + string(UI_controller.gui_height())
			+ ", window=" + string(window_get_width()) + "x" + string(window_get_height())
		);
	}
	gpu_set_scissor(0, 0, window_get_width(), window_get_height())
}
else {
	current_scissor = gpu_get_scissor();
	var _debug_key = string(current_scissor.x) + "," + string(current_scissor.y) + "," + string(current_scissor.w) + "," + string(current_scissor.h)
		+ ":" + string(UI_controller.gui_width()) + "x" + string(UI_controller.gui_height())
		+ ":" + string(window_get_width()) + "x" + string(window_get_height());
	if (_debug_key != UI_controller.last_scissor_clear_idle_debug_key) {
		UI_controller.last_scissor_clear_idle_debug_key = _debug_key;
		show_debug_message(
			"UI scissor clear idle: current_gpu=" + string(current_scissor.x) + "," + string(current_scissor.y) + "," + string(current_scissor.w) + "," + string(current_scissor.h)
			+ ", previous_gui=" + string(previous_scissor.x) + "," + string(previous_scissor.y) + "," + string(previous_scissor.w) + "," + string(previous_scissor.h)
			+ ", gui=" + string(UI_controller.gui_width()) + "x" + string(UI_controller.gui_height())
			+ ", window=" + string(window_get_width()) + "x" + string(window_get_height())
		);
	}
}
