/*dragging = true;
var _drag_min = -thumb_offset;
var _drag_max = bar_height-thumb_offset-thumb_height;
var _drag = -(event_data[?"viewstartposY"]-event_data[?"posY"]);
if(horizontal){
    _drag_max= bar_width-thumb_offset-thumb_width;
    _drag = -(event_data[?"viewstartposX"]-event_data[?"posX"]);
}
drag = clamp(_drag,_drag_min,_drag_max);
SetPosition(drag);*/
dragging = true

if horizontal {
	scroll_speed = window_mouse_get_delta_x()/(bbox_right-bbox_left)*100;
}
else {
	scroll_speed = (window_mouse_get_delta_y()/(bbox_bottom-bbox_top))*100;
}
