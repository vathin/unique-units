begin_button_draw();
draw_sprite_in_bbox(4, true);
end_button_draw();
draw_set_halign(fa_center);
var _text = deck_name;
if string_length(_text) > 7 {_text = string_copy(deck_name, 0, 7) + "..."}
var _bounds = get_button_draw_bounds();
draw_text_transformed((_bounds[0] + _bounds[2]) / 2, y, _text, 0.85, 0.85, 0);
draw_set_halign(fa_left);
