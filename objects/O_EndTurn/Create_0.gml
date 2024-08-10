/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

image_xscale = 0.47;
image_yscale = 0.47;
image_speed = 0;
active = true
clear_all = function() {
	global.moving_figure = 0;
	global.chosen_figure = "";
	global.selected_cell = "";
	O_SummonButton.go_to_standart_mode();
	O_GameField.clear_all_marks();
}