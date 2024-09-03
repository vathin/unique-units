/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if O_GameLoopController.displaying_card {
	if (exit_button != undefined) and !(position_meeting(mouse_x, mouse_y, self)) {stop_display_card()}
}