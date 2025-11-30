switch type {
	case "accept":
		if O_DeckManager.get_selected_deck != undefined {
			O_LoginController.invite_accept();
		}
	break;
	case "decline":
		O_LoginController.invite_decline();
	break;
}