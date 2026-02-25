if have_overlay {
	set_sprite(default_sprite, 0);
	have_overlay = 0;
}
if type == "MainButton" {
	UI_controller.set_ui_text_alpha(UI_controller.InGame_layer, "AvailableFiguresCount", image_alpha);
}