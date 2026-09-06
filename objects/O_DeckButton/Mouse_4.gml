var _bounds = get_button_draw_bounds();
if UI_controller.gui_mouse_in_bbox(_bounds[0], _bounds[1], _bounds[2], _bounds[3]) and deck_id != "-1" and O_DeckManager.get_deck_from_id(deck_id) != undefined {
	O_DeckManager.switch_deck(deck_id);

}
