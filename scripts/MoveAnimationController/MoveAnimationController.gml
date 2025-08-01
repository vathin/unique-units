// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function MoveAnimationController() : FigureAnimationController() constructor{
	anim_type = "move"
	animate = function() {
		if animation_frame < ((animation_length)/4*(Settings.move_animation_length/animation_length)) {
			figure_alpha -= 0.05;
			figure_xscale += 0.0025;
			figure_yscale += 0.0025;
		}
		if animation_frame > animation_length - ((animation_length)/4*(Settings.move_animation_length/animation_length)){
			figure_alpha += 0.05;
			figure_xscale -= 0.0025;
			figure_yscale -= 0.0025;
		}
		figure_x = lerp(x_from, x_to, percent);
		figure_y = lerp(y_from, y_to, percent);
		if animation_frame >= (animation_length-1) {
			figure_x = x_to;
			figure_y = y_to;
		}
	}
}