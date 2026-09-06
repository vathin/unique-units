if in_scroll and instance_exists(scroll_bar){
	if scroll_bar.horizontal {
		scroll_speed = UI_controller.gui_mouse_delta_x()/UI_controller.gui_width()*100;
	}
	else {
		scroll_speed = UI_controller.gui_mouse_delta_y()/UI_controller.gui_height()*100;
	}
	scroll_bar.scroll_speed = scroll_speed;
	scroll_bar.changing_position = 1;
}
