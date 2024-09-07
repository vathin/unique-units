/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if animation_enabled {
	if animation_frame < animation_length{
		update_animation();
	}
	if animation_frame >= animation_length {instance_destroy()}
}