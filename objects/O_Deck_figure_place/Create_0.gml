event_inherited();
figure_inside = undefined;
figure_amount = 0;
figure_max_amount = 1;
image_speed = 0;

begin_button_draw = function() {
	if in_animation {
		image_blend = make_colour_rgb(255,
		255/cancel_animation_length*cancel_animation_frame,
		255/cancel_animation_length*cancel_animation_frame);
		cancel_animation_frame++;
		if cancel_animation_frame == cancel_animation_length {in_animation = 0}
	}
}

get_button_draw_bounds = function(_padding = 0) {
	var _width = bbox_right - bbox_left + 1;
	var _height = bbox_bottom - bbox_top + 1;
	if variable_instance_exists(id, "layout_width") {
		_width = layout_width;
	}
	if variable_instance_exists(id, "layout_height") {
		_height = layout_height;
	}
	_width = max(1, _width - _padding*2);
	_height = max(1, _height - _padding*2);
	var _left = x - _width/2;
	var _top = y - _height/2;
	return [_left, _top, _left + _width, _top + _height];
}

draw_sprite_in_bbox = function(_padding = 0, _keep_aspect = true) {
	if sprite_index == -1 {return;}
	var _bounds = get_button_draw_bounds(_padding);
	var _sprite_width = max(1, sprite_get_width(sprite_index));
	var _sprite_height = max(1, sprite_get_height(sprite_index));
	var _draw_width = max(1, _bounds[2] - _bounds[0]);
	var _draw_height = max(1, _bounds[3] - _bounds[1]);
	var _cx = (_bounds[0] + _bounds[2]) / 2;
	var _cy = (_bounds[1] + _bounds[3]) / 2;
	var _xscale = _draw_width / _sprite_width;
	var _yscale = _draw_height / _sprite_height;
	if _keep_aspect {
		var _scale = min(_xscale, _yscale);
		_xscale = _scale;
		_yscale = _scale;
	}
	draw_sprite_ext(sprite_index, image_index, _cx, _cy, _xscale, _yscale, image_angle, image_blend, image_alpha);
}

end_button_draw = function() {
	image_blend = c_white;
	var _bounds = get_button_draw_bounds();
	if UI_controller.gui_mouse_in_bbox(_bounds[0], _bounds[1], _bounds[2], _bounds[3]) {
		image_alpha = lerp(image_alpha, 0.7, 0.14);
		if mouse_check_button(mb_any) {image_alpha = 1}
	}
	else if image_alpha < 1 {image_alpha = lerp(image_alpha, 1, 0.14)}
}

clear = function() {
	figure_inside = undefined;
	figure_amount = 0;
	figure_max_amount = 1;
}

change_amount = function(_amount = 1) {
	figure_amount += _amount;
	if figure_amount > Behaviours.get_max_deck_amount(figure_inside) {
		figure_amount = Behaviours.get_max_deck_amount(figure_inside);
	}
	/*if figure_amount < 1 {
		clear();
	}*/
}

set_figure = function(_figure, _amount = 1) {
	figure_inside = _figure;
	figure_amount = _amount;
	figure_max_amount = Behaviours.get_max_deck_amount(figure_inside);
	sprite_index = Behaviours.get_sprite(figure_inside);
}

get_figure = function() {
	return figure_inside
}

get_amount = function() {
	return figure_amount
}

cancel = function() {
	in_animation = 1;
	current_frame = 0;
}

if variable_instance_exists(id, "initial_figure") {
	var _amount = 1;
	if variable_instance_exists(id, "initial_figure_amount") {
		_amount = initial_figure_amount;
	}
	set_figure(initial_figure, _amount);
}
