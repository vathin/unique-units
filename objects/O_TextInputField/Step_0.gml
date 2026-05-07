
if selected {
	text += keyboard_string
	keyboard_string = ""
	if keyboard_check_pressed(vk_backspace) or keyboard_lastkey == vk_backspace {
		delete_last_character();
		keyboard_lastkey = vk_nokey;
		keyboard_lastchar = "";
	}
	if (mouse_check_button_pressed(mb_left) and not UI_controller.gui_mouse_in_bbox(bbox_left, bbox_top, bbox_right, bbox_bottom))
	or keyboard_check_pressed(vk_enter){selected = false}
	if keyboard_check(vk_control) and keyboard_check_pressed(ord("V")) {text += clipboard_get_text()}
}
