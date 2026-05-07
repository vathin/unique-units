dragging = true

if horizontal {
	scroll_speed = UI_controller.gui_mouse_delta_x()/(bbox_right-bbox_left)*100;
}
else {
	scroll_speed = UI_controller.gui_mouse_delta_y()/(bbox_bottom-bbox_top)*100;
}
