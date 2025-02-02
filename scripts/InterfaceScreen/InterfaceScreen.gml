// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceScreen() : InterfaceBase() constructor {

    window_w = 0;
    window_h = 0;
    
    static base_height = 1920;
    static base_width = 1344;
    gui_width = 0;
    gui_height = 0;
    
    color_override = c_white;
    alpha_override = 1;
	
	mouse = new InterfaceScreenMouse();
    
    event_create.add(function() {
        set_align_across(flexpanel_align.center);
        set_justify_across(flexpanel_justify.center);
        set_justify(flexpanel_justify.space_evenly);
        set_flex_direction(flexpanel_flex_direction.column);
    });
    event_step_begin.add(function() {
        if (window_get_width() != window_w || window_get_height() != window_h) {
            window_w = window_get_width();
            window_h = window_get_height();
            
            recalculate_screen();
        }

	})
	event_step.add(function() {
		mouse.step();		
	})
    recalculate_screen = function() {
        gui_height = base_height;
        gui_width = window_w * (gui_height / window_h);
        
        display_set_gui_size(gui_width, gui_height);
        set_width(gui_width);
        set_height(gui_height);
    }
    
}

function InterfaceScreenMouse() constructor {
	position = new Point();
	position_previous = new Point();
	delta = new Point();
	press_position = new Point();
	
	selected_element = undefined;
	hovered_elements = [];
	
	static step = function() {
		position_previous.set_from_point(position);
		position.set(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
		
		delta.set_from_point(position);
		delta.subtract(position_previous);
		
		handle_elements();
	}
	static handle_elements = function() {
		var under_mouse = InterfaceRaycast.Raycast(position.x, position.y);
		
		for(var i = array_length(under_mouse) - 1; i >= 0; i--) {
			var element = under_mouse[i];
			
			if (is_instanceof(element, InterfaceScreen))
				continue;
			
			var element_mouse = element[$ "mouse"];
			if (element_mouse == undefined)
				continue;
				
			if (element_mouse.disabled)
				continue;
				
			var was = array_get_index(hovered_elements, element) >= 0;
			if (was)
				continue;
				
			element_mouse._enter();
			array_push(hovered_elements, element);
			
			if (element_mouse.opaque)
				break;
		}
		
		for(var i = array_length(hovered_elements) - 1; i >= 0; i--) {
			var element = hovered_elements[i];
			var leave = array_get_index(under_mouse, element) < 0;
			
			if (leave) {
				element.mouse._leave();
				array_delete(hovered_elements, i, 1);
			}
		}
		
		var selected = array_length(hovered_elements) == 0 ? undefined : hovered_elements[array_length(hovered_elements) - 1];
		if (selected == selected_element)
			return;
			
		if (!is_undefined(selected_element)) {
			selected_element.mouse._unselect();
		}
		selected_element = selected;
		if (!is_undefined(selected_element)) {
			selected_element.mouse._select();
		}
	}
}