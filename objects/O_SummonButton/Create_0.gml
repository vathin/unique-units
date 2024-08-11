/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
standart_sprite = S_Summon_button
standart_scale = 0.3;
image_xscale = standart_scale;
image_yscale = standart_scale;
image_speed = 0;
do_something = undefined;

hovering = false;
is_active = true;

change_sprite = function(new_sprite, new_scale) {
	sprite_index = new_sprite;
	image_xscale = new_scale;
	image_yscale = new_scale;
}
go_to_standart_mode = function() {
	change_sprite(standart_sprite, standart_scale);
	unblock()
}
block = function() {
	is_active = 0
}
unblock = function() {
	is_active = 1
}
is_blocked = function() {
	return !is_active
}