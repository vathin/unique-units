if in_scroll and UI_controller.is_current_page_scrollable(){
	scroll_speed = window_mouse_get_delta_y()/window_get_height()*100;
	UI_controller.scroll_menu_page(scroll_element, 1, scroll_speed);
}
