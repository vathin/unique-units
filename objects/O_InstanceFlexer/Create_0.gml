/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
window_default_x_size = 1680;
window_default_y_size = 1050;
window_x_size = window_get_width();
window_y_size = window_get_height();
objects_xscale = window_default_x_size / window_x_size;
objects_yscale = window_default_y_size / window_y_size;
window_xscale = window_x_size / window_default_x_size;
window_yscale = window_y_size / window_default_y_size;

resize_all = function() {
	show_debug_message(objects_xscale);
	for (i = 0; i < instance_number(all); i++) {
		obj_to_resize = instance_find(all, i);
		if variable_instance_exists(obj_to_resize, "standart_scale") {
			obj_to_resize.image_xscale = objects_xscale*obj_to_resize.standart_scale;
			obj_to_resize.image_yscale = objects_yscale*obj_to_resize.standart_scale;
		}
	}
}

resize_all();