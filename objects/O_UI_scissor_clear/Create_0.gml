default_scissor = gpu_get_scissor();
current_scissor = default_scissor
is_scissor_default = function() {
	var _s = gpu_get_scissor()
	if _s.x != 0 or _s.y != 0 or _s.h != window_get_height() or _s.w != window_get_width()
	{
		return false
	}
	return true
}
