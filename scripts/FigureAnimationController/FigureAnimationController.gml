// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureAnimationController() constructor{
	animation_length = 30;
	animation_enabled = false;
	animation_frame = 0;
	figure_alpha = 1;
	figure_xscale = Settings.figure_scale;
	figure_yscale = Settings.figure_scale;
	x_from = 0;
	y_from = 0;
	x_to = 0;
	y_to = 0;
	figure_x = 0;
	figure_y = 0;
	percent = 0;

	start_animation = function(_x_from, _y_from, _x_to, _y_to, _animation_length, _figure_scale = Settings.figure_scale) {
		x_from = _x_from;
		y_from = _y_from;
		x_to = _x_to;
		y_to = _y_to;
		figure_x = x_from;
		figure_y = y_from;
		animation_length = _animation_length;
		figure_xscale = _figure_scale;
		figure_yscale = _figure_scale;
		animation_frame = 0;
		percent = 0;
	}
	

	
	//animate = function() {
	//}

	update_animation = function() {
		animation_frame++;
		percent = animation_frame / animation_length;
		animate();
	}

	
}