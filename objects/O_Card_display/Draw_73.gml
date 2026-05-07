if is_active {
	draw_set_alpha(0.65);
	draw_rectangle_colour(-1, -1, UI_controller.gui_width()+1, UI_controller.gui_height()+1, c_black, c_black, c_black, c_black, 0);
	draw_set_alpha(1);
	draw_sprite_ext(sprite_index, 0, UI_controller.gui_width()/2, UI_controller.gui_height()/2, 1, 1, 0, c_white, 0.8);
}
