/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if window_x_size != window_get_width() or window_y_size != window_get_height() {
	objects_xscale = window_default_x_size / window_get_width();
	objects_yscale = window_default_y_size / window_get_height();
	resize_all();
}
window_x_size = window_get_width();
window_y_size = window_get_height();
objects_xscale = window_default_x_size / window_x_size;
objects_yscale = window_default_y_size / window_y_size;
window_xscale = window_x_size / window_default_x_size;
window_yscale = window_y_size / window_default_y_size;