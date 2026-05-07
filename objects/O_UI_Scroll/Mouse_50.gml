if in_scroll and UI_controller.is_current_page_scrollable(){
	scroll_speed = UI_controller.gui_mouse_delta_y()/UI_controller.gui_height()*100;
	UI_controller.scroll_menu_page(scroll_element, 1, scroll_speed);
}
