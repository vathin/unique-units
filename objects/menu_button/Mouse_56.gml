/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
bbox_left, bbox_top, bbox_right, bbox_bottom)) {
	switch button_function {
		case "invite":
		if O_DeckManager.get_selected_deck != undefined {
				O_Server.start_invite();
			}
		break;
		case "fast_search":
			if O_DeckManager.get_selected_deck != undefined {
				O_Server.start_fast_search();
			}
		break;
		case "invite_cancel":
			O_Server.cancel_invite();
		break;
		case "search_cancel":
			O_Server.cancel_fast_search();
		break;
		case "to_menu":
			O_Server.enemy = undefined;
			room_goto(R_Main_menu);
		break;
		//deck_page
		case "deck_save":
			O_DeckManager.update_deck();
		break;
		case "deck_reset":
			O_DeckManager.switch_deck(O_DeckManager.get_selected_deck().id);
		break;
		case "deck_create":
			O_DeckManager.create_new_deck();
		break;
		case "deck_delete":
			O_DeckManager.delete_deck(O_DeckManager.get_selected_deck().id);
		break;
	}
}