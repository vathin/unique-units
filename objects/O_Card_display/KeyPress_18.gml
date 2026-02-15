if is_active {is_active = 0;}
if point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom) and !is_active{
	is_active = 1;
}