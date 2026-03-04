event_inherited();
image_speed = 0;
scale = image_xscale;
default_sprite = sprite_index;
previous_sprite = sprite_index;
have_overlay = false;

set_frame = function(_frame) {
	image_index = _frame;
}

clear = function(_sprite = 0) {
	if _sprite {
		set_sprite(default_sprite, standart_frame)
	}
	set_frame(standart_frame);
}

set_sprite = function(_sprite, _frame) {
	var _scale = sprite_width/sprite_get_width(_sprite);
	sprite_index = _sprite;
	set_frame(_frame);
	image_xscale = _scale;
	image_yscale = _scale;
}

