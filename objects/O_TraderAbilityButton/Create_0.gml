/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
image_speed = 0;
image_xscale = 0.15;
image_yscale = 0.15;
figure_type = undefined;
ability = undefined;

set_sprite = function(behaviour) {
	sprite_index = Behaviours.get_sprite(behaviour);
	figure_type = behaviour;
}