/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

x_default = x;
y_default = y;
image_xscale = 0.21;
image_yscale = 0.21;

set_sprite = function(sprite) {
	sprite_index = sprite;
}

display_card = function() {
	x = O_GameField.x;
	y = O_GameField.y;
}

stop_display = function() {
	x = x_default;
	y = y_default;
}