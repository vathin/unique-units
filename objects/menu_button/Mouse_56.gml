/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if UI_controller.gui_mouse_in_bbox(bbox_left, bbox_top, bbox_right, bbox_bottom) {
	switch button_function {
		case "invite":
		if O_DeckManager.get_selected_deck() != undefined {
				O_Server.start_invite();
			}
		break;
		case "fast_search":
			if O_DeckManager.get_selected_deck() != undefined {
				O_Server.start_fast_search();
			}
		break;
		case "start_local":
			Start_match("local_vs_local");
		break;
		case "start_local_vs_local":
			Start_match("local_vs_local");
		break;
		case "start_local_vs_bot":
			Start_match("local_vs_bot");
		break;
		case "start_bot_vs_bot":
			Start_match("bot_vs_bot");
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
			var _deck_reset = O_DeckManager.get_selected_deck();
			if _deck_reset != undefined {
				O_DeckManager.switch_deck(_deck_reset.id);
			}
		break;
		case "deck_create":
			O_DeckManager.create_new_deck();
		break;
		case "deck_delete":
			var _deck_delete = O_DeckManager.get_selected_deck();
			if _deck_delete != undefined {
				O_DeckManager.delete_deck(_deck_delete.id);
			}
		break;
	}
}
