function InterfaceMouseApply() {
	if (variable_struct_exists(self, "mouse"))
		return;
		
	mouse = new InterfaceMouseComponent(self);
	mouse.init();
}

function InterfaceMouseComponent(_element) constructor {
	element = _element;
	pressed = false;
	hovered = false;
	disabled = false;
	opaque = true;
	
	pressed_position = new Point();
	time_pressed = 0;
	
	event_enter = GetDelegate(self);
	event_leave = GetDelegate(self);
	event_down = GetDelegate(self);
	event_up = GetDelegate(self);
	
	event_pressed = GetDelegate(self);
	event_hold = GetDelegate(self);
	event_double_pressed = GetDelegate(self);
	event_drag_begin = GetDelegate(self);
	event_drag = GetDelegate(self);
	event_drag_end = GetDelegate(self);
	
	event_swipe = GetDelegate(self);
	
	static init = function() {
		element.event_step.add(method(self, step));
		element.event_destroy.add(method(self, cleanup));
	}
	static step = function() {
		if (disabled)
			return;
			
		if (hovered) {
			if (mouse_check_button_pressed(mb_left)) {
				_down();
			}
		}
		if (pressed) {
			event_hold.call();
			
			if (mouse_check_button_released(mb_left)) {
				_up();
				if (hovered) {
					_press();
				}
			}
		}
	}
	static cleanup = function() {
		element = undefined;
	}
	
	static _down = function() {
		pressed = true;
		event_down.call();
	}
	static _up = function() {
		pressed = false;
		event_up.call();
	}
	static _press = function() {
		event_pressed.call();
		pressed_position.set_from_point(Interface.screen.mouse.position);
		time_pressed = get_timer();
	}
	static _select = function() {
		hovered = true;
		
		event_enter.call();
	}
	static _unselect = function() {
		hovered = false;
		
		event_leave.call();
	}
	static _enter = function() {
		
	}
	static _leave = function() {
		
	}
}