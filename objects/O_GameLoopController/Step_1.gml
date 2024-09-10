/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if mouse_check_button_pressed(mb_left) and !position_meeting(mouse_x, mouse_y, all) and can_cancel {
	cancel_action();
}