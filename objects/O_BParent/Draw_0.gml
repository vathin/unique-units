
if in_animation {
	image_blend = make_colour_rgb(255,
	255/cancel_animation_length*cancel_animation_frame, 
	255/cancel_animation_length*cancel_animation_frame);
	cancel_animation_frame++;
	if cancel_animation_frame == cancel_animation_length {in_animation = 0}
	}
draw_self();
image_blend = c_white
if position_meeting(mouse_x, mouse_y, self) {
	image_alpha = lerp(image_alpha, 0.7, 0.14);
	if mouse_check_button(mb_any) {image_alpha = 1}
	}
else if image_alpha < 1 {image_alpha = lerp(image_alpha, 1, 0.14)}