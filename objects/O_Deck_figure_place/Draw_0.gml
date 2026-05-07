draw_set_alpha(0.8)
var _bounds = get_button_draw_bounds();
draw_rectangle_color(_bounds[0]-3, _bounds[1]-3, _bounds[2]+3, _bounds[3]+3, c_dkgray, c_dkgray, c_dkgray, c_dkgray, 0)
//draw_rectangle(x - 150, y - 150, x + 150, y + 150, 0)
draw_set_alpha(1)
begin_button_draw();
draw_sprite_in_bbox(6, true);
end_button_draw();
draw_set_halign(fa_center);
draw_text((_bounds[0] + _bounds[2]) / 2, _bounds[3] - 18, string(figure_amount) + " / " + string(figure_max_amount));
draw_set_halign(fa_left);
