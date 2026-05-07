default_scissor = gpu_get_scissor();
current_scissor = default_scissor
is_scissor_default = function() {
	var _s = gpu_get_scissor()
	if _s.x != 0 or _s.y != 0 or _s.h != UI_controller.gui_height() or _s.w != UI_controller.gui_width()
	{
		return false
	}
	return true
}
