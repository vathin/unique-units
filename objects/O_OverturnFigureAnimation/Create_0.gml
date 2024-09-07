/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
event_inherited();
animate = function(){
	animate_figure.overturning = 1;
	if animate_figure.owner == "player2" {ov_sprite_frame = 1}
	if animation_frame > animation_length / 2 {
		animate_figure.image_xscale += Settings.figure_scale / (animation_length/2);
		animate_figure.overturning = 0;
	}
	else {
		animate_figure.image_xscale -= Settings.figure_scale / (animation_length/2);
	}
	if animation_frame >= animation_length -1{
		animate_figure.image_xscale = Settings.figure_scale;
	}
}

