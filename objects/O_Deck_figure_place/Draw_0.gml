draw_set_alpha(0.8)
draw_rectangle_color(bbox_left-3, bbox_top-3, bbox_right+3, bbox_bottom+3, c_dkgray, c_dkgray, c_dkgray, c_dkgray, 0)
//draw_rectangle(x - 150, y - 150, x + 150, y + 150, 0)
draw_set_alpha(1)
draw_self();
draw_text(bbox_right-5, bbox_bottom-5, figure_amount)