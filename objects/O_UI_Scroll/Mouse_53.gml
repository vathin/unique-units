if scroll_element != undefined {
	var _sc = O_UI_scissor_clear.previous_scissor;
	if point_in_rectangle(mouse_x, mouse_y, _sc.x, _sc.y, _sc.x + _sc.w, _sc.y + _sc.h){
		in_scroll = 1;
	}
}