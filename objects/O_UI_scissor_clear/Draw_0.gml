previous_scissor = gpu_get_scissor();
if !is_scissor_default() {
	current_scissor = gpu_get_scissor();
	gpu_set_scissor(0, 0, UI_controller.gui_width(), UI_controller.gui_height())
}
