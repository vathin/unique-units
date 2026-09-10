if position_meeting(mouse_x, mouse_y, self) and is_active{
	show_debug_message("Game UI legacy: ability button forwarded");
	O_BoardDraw.ability_button_click();
}
