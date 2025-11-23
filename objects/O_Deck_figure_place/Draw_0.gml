draw_set_alpha(0.8)
draw_rectangle_color(bbox_left-3, bbox_top-3, bbox_right+3, bbox_bottom+3, c_dkgray, c_dkgray, c_dkgray, c_dkgray, 0)
//draw_rectangle(x - 150, y - 150, x + 150, y + 150, 0)
draw_set_alpha(1)
event_inherited()
draw_set_halign(fa_center);
draw_text(bbox_right/2 + bbox_left/2, bbox_bottom-5, string(figure_amount) + " / " + string(figure_max_amount));
draw_set_halign(fa_left);