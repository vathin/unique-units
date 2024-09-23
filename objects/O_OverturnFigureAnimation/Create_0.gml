/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
event_inherited();

stop_animation = function() {
	animate_figure.image_xscale = Settings.figure_scale;
	animate_figure.overturning = 0;
}
animate = function(){
	if animate_figure.state.is_dropped {stop_animation()}
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
		if animate_figure.state.is_dropped or animate_figure.state.is_captured {
			animate_figure.image_xscale = Settings.figure_scale*0.75;
			animate_figure.image_yscale = Settings.figure_scale*0.75;
		}
	}
}

