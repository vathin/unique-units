/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if selected {
	text += keyboard_string
	keyboard_string = ""
	if (mouse_check_button_pressed(mb_left) and not position_meeting(mouse_x, mouse_y, self)) or keyboard_check_pressed(vk_enter){selected = false}
	if keyboard_check(vk_control) and keyboard_check_pressed(ord("V")) {text += clipboard_get_text()}
}