/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
draw_set_font(F_test);
draw_self()
draw_set_valign(fa_center);
var _text = text;
if _text == ""{
	draw_set_alpha(0.74);
	_text = default_text
}
draw_set_halign(fa_center)
draw_text_transformed(x, y, _text, 0.8, 0.8, 0);
if selected { image_alpha = 0.55 }
else{ image_alpha = 1 }
draw_set_font(F_turn_timer);
draw_set_halign(fa_left)
draw_set_valign(fa_top);
draw_set_alpha(1);