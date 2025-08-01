// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function OverturnAnimationController(): FigureAnimationController() constructor{
	anim_type = "overturn"
	draw_spr_2 = 0
	start_xscale = figure_xscale
	
	animate = function(){
		if animation_frame > animation_length / 2 {
			figure_xscale += Settings.figure_scale / (animation_length/2);
			draw_spr_2 = 1;
		}
		else {
			figure_xscale -= Settings.figure_scale / (animation_length/2);
		}
		if animation_frame >= animation_length -1{
			figure_xscale = Settings.figure_scale;
		}
		if animation_frame >= (animation_length-1) {
			figure_xscale = start_xscale;
		}
	}
}