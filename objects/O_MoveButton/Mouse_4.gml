/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) and is_active {
	show_debug_message("Game UI legacy: move button forwarded");
	O_BoardDraw.move_button_click();
}
