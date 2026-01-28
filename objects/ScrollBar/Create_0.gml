horizontal = false;
bar_width = sprite_width;
bar_height = sprite_height;
scroll_speed = 0;
changing_position = false;
move_edge = flexpanel_edge.top;
if(bar_width > bar_height and !keep_vertical){
    horizontal = true;
	move_edge = flexpanel_edge.left
}

scroll_top = y-bar_height/2;
scroll_bottom = y+bar_height/2;
thumb_offset = 0;
thumb_width = bar_width;
thumb_height = bar_height*step_size;

if(horizontal){
    scroll_top = x-bar_width/2;
    scroll_bottom = x+bar_width/2;
    thumb_height = bar_height;
    thumb_width = bar_width*step_size;
}

drag = 0;
dragging = false;

Scroll = function(_size){
    percentage = clamp(percentage+_size,0,1)
    if(horizontal){
        thumb_offset = percentage*(bar_width-thumb_width);
    } else {
        thumb_offset = percentage*(bar_height-thumb_height);
    }
}

SetPosition = function(_position){
	changing_position = 1;
    if(horizontal){
        percentage = clamp((mouse_x-scroll_top) / (scroll_bottom-scroll_top),0,1);
    } else {
        percentage = clamp((mouse_y-scroll_top) / (scroll_bottom-scroll_top),0,1);
    }
}

reset = function() {
	percentage = 1;
	dragging = 0;
	scroll_speed = 0;
}
