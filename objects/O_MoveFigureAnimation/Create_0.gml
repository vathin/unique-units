/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

// Inherit the parent event
event_inherited();


animate = function() {
	if animation_frame < (animation_length)/4 {
		animate_figure.image_alpha -= 0.05
		animate_figure.image_xscale += 0.0025;
		animate_figure.image_yscale += 0.0025;
	}
	if animation_frame > 3*(animation_length+1)/4 {
		animate_figure.image_alpha += 0.05;
		animate_figure.image_xscale -= 0.0025;
		animate_figure.image_yscale -= 0.0025;
	}
	animate_figure.x = lerp(x_from, x_to, percent);
	animate_figure.y = lerp(y_from, y_to, percent);
}