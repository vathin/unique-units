switch type {
	case "accept":
		if O_DeckManager.get_selected_deck != undefined {
			O_Server.invite_accept();
		}
	break;
	case "decline":
		O_Server.invite_decline();
	break;
}