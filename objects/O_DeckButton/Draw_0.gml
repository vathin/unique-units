event_inherited();
draw_set_halign(fa_center);
var _text = deck_name;
if string_length(_text) > 7 {_text = string_copy(deck_name, 0, 7) + "..."}
draw_text_transformed(bbox_right/2+bbox_left/2, y, _text, 0.85, 0.85, 0);
draw_set_halign(fa_left);