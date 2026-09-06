
if scroll_bar != noone and !instance_exists(scroll_bar) {
	clear();
}

if scroll_bar != noone and scroll_speed != 0 and !mouse_check_button(mb_left){
	scroll_bar.scroll_speed = scroll_speed;
	scroll_bar.changing_position = 1;
	scroll_speed /= 1.2;
	if abs(scroll_speed) < 0.1 {scroll_speed = 0}
}
