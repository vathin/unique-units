SequenceInterfaceClasses().register("button-sprite", InterfaceButtonSprite);
SequenceInterfaceClasses().register("sprite-button", InterfaceButtonSprite);
SequenceInterfaceClasses().register("button_sprite", InterfaceButtonSprite);
SequenceInterfaceClasses().register("sprite_button", InterfaceButtonSprite);
SequenceInterfaceClasses().register("ButtonSprite", InterfaceButtonSprite);
SequenceInterfaceClasses().register("SpriteButton", InterfaceButtonSprite);
function InterfaceButtonSprite() : InterfaceButton() constructor {
	sprite = S_Button;
	text = "";
	text_color = c_dkgray;
	
	frame = 0;
	
	frame_idle = 0;
	frame_hovered = 1;
	frame_pressed = 2;
	frame_blocked = 3;
	
	static update_design = function() {
		frame = 0;
		switch (state) {
			case ButtonState.IDLE: 
				frame = frame_idle;
				break;
			case ButtonState.HOVERED: 
				frame = frame_hovered;
				break;
			case ButtonState.PRESSED: 
				frame = frame_pressed;
				break;
		}
	}
	event_draw.add(function() {
		var geometry = get_geometry();
		draw_sprite_stretched(sprite, frame, geometry.left, geometry.top, geometry.width, geometry.height);
		
		draw_set_color(text_color);
		draw_set_halign(fa_center);
		draw_set_valign(fa_center);
		draw_text(geometry.left + geometry.width/2, geometry.top + geometry.height/2, text);
	});
}

function InterfaceButton() : InterfaceBase() constructor {
	InterfaceMouseApply();
	
	state = ButtonState.IDLE;
	
	event_state = GetDelegate(self);
	event_click = GetDelegate(self);
	
	mouse.event_enter.add(function() {
		set_state(ButtonState.HOVERED);
	})
	mouse.event_leave.add(function() {
		if (!mouse.pressed) {
			set_state(ButtonState.IDLE);
		}
	})
	mouse.event_down.add(function() {
		set_state(ButtonState.PRESSED)
	})
	mouse.event_up.add(function() {
		set_state(mouse.hovered ? ButtonState.HOVERED : ButtonState.IDLE);
	})
	mouse.event_pressed.add(function() {
		event_click.call();
		show_debug_message("click")
	})
	
	static set_state = function(new_state) {
		state = new_state;
		event_state.call();
		update_design();
	}
	
	static update_design = function() {
		
	}
}

function ButtonState() constructor {
	static IDLE = "idle";
	static HOVERED = "hovered";
	static PRESSED = "pressed";
}
new ButtonState();