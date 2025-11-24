// Inherit the parent event
if is_active {
	event_inherited();
}
else {
	draw_set_alpha(0.45);
	draw_self();
	draw_set_alpha(1);
}

