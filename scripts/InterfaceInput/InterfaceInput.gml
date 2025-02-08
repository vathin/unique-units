
SequenceInterfaceClasses().register("Input", InterfaceInput);
SequenceInterfaceClasses().register("input", InterfaceInput);
function InterfaceInput() : InterfaceBase() constructor {
	InterfaceControlApply();

	value = new ObservableParameter("");

	sprite = noone;
	text_margin = [5, 5, 5, 5];

	control.event_selected.add(function() {
		keyboard_string = value.get();
	})
	mouse.event_pressed.add(function() {
		control.select();
	});
	event_step.add(function() {
		
		if (!control.is_selected()) {
			return;
		}
		
		if (mouse_check_button_pressed(mb_left)) {
			if (!mouse.hovered) {
				control.deselect();
			}
		}
		
		value.set(keyboard_string);
	});
	
	event_draw.add(function() {
		_draw_sprite();
		_draw_text();
	})
	static _draw_sprite = function() {
		if (sprite == noone)
			return;
			
		var g = get_geometry();
		draw_sprite_stretched(sprite, control.is_selected(), g.left, g.top, g.width, g.height);
	}
	static _draw_text = function() {
		var g = get_geometry();
		
		draw_set_halign(fa_left);
		draw_set_valign(fa_center);
		draw_set_color(c_white);
		draw_text(g.left + text_margin[0], g.top + g.height/2 + text_margin[1], value.get());
	}
}