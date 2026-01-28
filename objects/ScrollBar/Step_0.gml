if (scroll_speed != 0) {
	changing_position = 1;
	Scroll(scroll_speed/100);
	scroll_speed /= 1.2;
	if abs(scroll_speed) < 0.1 {scroll_speed = 0}
}
if (changing_position and controlled_element != "default"){
	UI_controller.set_element_position(controlled_el_layer, controlled_element, percentage, move_edge, 2, -1);
}
changing_position = false;