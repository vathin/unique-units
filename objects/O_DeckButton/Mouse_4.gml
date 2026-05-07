var _bounds = get_button_draw_bounds();
if UI_controller.gui_mouse_in_bbox(_bounds[0], _bounds[1], _bounds[2], _bounds[3]) {
	O_DeckManager.switch_deck(deck_id);
}
