switch (type) {
	case "MainButton":
		O_BoardDraw.main_button_click();
		break;
	case "MoveButton":
		show_debug_message("Game UI: move button clicked");
		O_BoardDraw.move_button_click();
		break;
	case "AbilityButton":
		show_debug_message("Game UI: ability button clicked");
		O_BoardDraw.ability_button_click();
		break;
}
