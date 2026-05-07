
draw_set_font(F_test);
event_inherited();
if selected { image_alpha = 0.55 }
draw_set_valign(fa_center);
var _text = text;
var _text_alpha = 1;
if _text == ""{
	_text_alpha = 0.74;
	_text = default_text;
}
draw_set_halign(fa_center);
draw_set_colour(c_white);
draw_set_alpha(_text_alpha);
draw_text_transformed(x, y, _text, 0.8, 0.8, 0);
draw_set_font(F_turn_timer);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
