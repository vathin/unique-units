
draw_set_font(F_test);
event_inherited();
if selected { image_alpha = 0.55 }
draw_set_valign(fa_center);
var _text = text;
if _text == ""{
	draw_set_alpha(0.74);
	_text = default_text;
}
draw_set_halign(fa_center);
gpu_set_scissor(bbox_left, bbox_top, bbox_right-bbox_left, bbox_bottom-bbox_top);
draw_text_transformed(x, y, _text, 0.8, 0.8, 0);
gpu_set_scissor(0, 0, window_get_width(), window_get_height());
draw_set_font(F_turn_timer);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);