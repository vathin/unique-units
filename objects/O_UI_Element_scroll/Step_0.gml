scroll_element = UI_controller.check_scroll();
if scroll_element != undefined and scroll_speed != 0 and !mouse_check_button(mb_left){
	UI_controller.scroll_menu_page(scroll_element, 1, scroll_speed);
	scroll_speed /= 1.2;
	if abs(scroll_speed) < 0.1 {scroll_speed = 0}
}