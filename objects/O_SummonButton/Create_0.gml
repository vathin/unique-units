/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
standart_sprite = S_Summon_button
standart_scale = 0.21;
standart_x = x;
standart_y = y;
image_xscale = standart_scale;
image_yscale = standart_scale;
image_speed = 0;
image_index = 1;
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
	x = standart_x;
	y = standart_y;
}
block = function() {
	is_active = 0
	image_index = 2
}
unblock = function() {
	is_active = 1
	image_index = 1
}
is_blocked = function() {
	return !is_active
}

go_away = function() {
	x = -200;
	y = -200;
	block();
}