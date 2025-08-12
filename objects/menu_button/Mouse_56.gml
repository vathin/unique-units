/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
bbox_left, bbox_top, bbox_right, bbox_bottom)) {
	switch button_function {
		case "invite":
			O_LoginController.start_invite();
		break;
		case "fast_search":
			O_LoginController.start_fast_search();
		break;
		case "invite_cancel":
			O_LoginController.cancel_invite();
		break;
		case "search_cancel":
			O_LoginController.cancel_fast_search();
		break;
	}
}