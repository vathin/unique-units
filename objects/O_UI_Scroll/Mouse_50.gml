
if scroll_element != undefined {
	var _sc = O_UI_scissor_clear.previous_scissor;
	if point_in_rectangle(mouse_x, mouse_y, _sc.x, _sc.y, _sc.x + _sc.w, _sc.y + _sc.h){
		scroll_speed = window_mouse_get_delta_y()/window_get_height()*100;
		UI_controller.scroll_menu_page(scroll_element, 1, scroll_speed);
	}
}
