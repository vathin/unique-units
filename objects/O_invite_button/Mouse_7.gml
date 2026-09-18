switch type {
	case "accept":
		if O_DeckManager.is_selected_deck_valid() {
			O_Server.invite_accept();
		}
	break;
	case "decline":
		O_Server.invite_decline();
	break;
}
