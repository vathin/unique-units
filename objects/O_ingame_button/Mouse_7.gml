if room == R_Test {
	switch (type) {
		case "MainButton":
			O_BoardDraw.main_button_click();
			break;
		case "MoveButton":
			O_BoardDraw.move_button_click();
			break;
		case "AbilityButton":
			O_BoardDraw.ability_button_click();
			break;
	}
}