if is_active {
	draw_set_alpha(0.65);
	draw_rectangle_colour(-1, -1, window_get_width()+1, window_get_height()+1, c_black, c_black, c_black, c_black, 0);
	draw_set_alpha(1);
	draw_sprite_ext(sprite_index, 0, window_get_width()/2, window_get_height()/2, 1, 1, 0, c_white, 0.8);
}