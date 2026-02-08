cancel_animation_frame = 0;
cancel_animation_length = 45;
in_animation = 0;

start_cancel_animation = function(_length = cancel_animation_length) {
	in_animation = 1;
	cancel_animation_frame = 0
}