/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) and O_GameLoopController.can_cancel {
	O_GameLoopController.cancel_action()
}