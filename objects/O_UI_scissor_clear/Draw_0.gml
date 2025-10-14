previous_scissor = gpu_get_scissor();
if !is_scissor_default() {
	current_scissor = gpu_get_scissor();
	gpu_set_scissor(0, 0, window_get_width(), window_get_height())
}