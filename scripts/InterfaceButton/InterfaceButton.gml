function InterfaceButton() : InterfaceBase() constructor {
	InterfaceMouseApply();
	
	mouse.event_enter.add(function() {
		show_debug_message("enter");
	})
	mouse.event_leave.add(function() {
		show_debug_message("leave");
	})
	mouse.event_down.add(function() {
		show_debug_message("down");
	})
	mouse.event_up.add(function() {
		show_debug_message("up");
	})
	mouse.event_pressed.add(function() {
		show_debug_message("pressed");
	})
	
	event_draw.add(function() {
		var geometry = get_geometry();
		draw_rectangle(geometry.left, geometry.top, geometry.left + geometry.width, geometry.top + geometry.height, 1);
	})
}