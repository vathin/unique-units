/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

x_default = x;
y_default = y;
standart_scale = 0.18
image_xscale = standart_scale;
image_yscale = standart_scale;
exit_button = undefined;
depth = -1

set_sprite = function(sprite) {
	sprite_index = sprite;
}
display_card = function() {
	x = 840;
	y = 690;
	image_xscale = 0.9;
	image_yscale = 0.9;
	exit_button = instance_create_depth(x - sprite_width*0.38, y - sprite_height*0.455, -1, O_ExitCardDisplayButton);
	exit_button.parent_card = self;
	O_GameLoopController.displaying_card = 1;
	depth = -3;
}
stop_display_card = function() {
	x = x_default;
	y = y_default;
	image_xscale = standart_scale;
	image_yscale = standart_scale;
	instance_destroy(exit_button);
	exit_button = undefined;
	O_GameLoopController.displaying_card = 0;
	depth = -2;
}