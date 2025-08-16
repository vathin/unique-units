/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
enum INGAMEBUTTONFRAMES {
	opponent_turn,
	can_summon,
	cant_summon,
	can_move,
	cant_move,
	can_use_ability,
	cant_use_ability
}

turn_off_layers = function() {
	layer_set_visible("MainMenu", 0);
	layer_set_visible("LoginWindow", 0);
	layer_set_visible("InviteWindow", 0);
	layer_set_visible("InviteRoom", 0);
	layer_set_visible("SearchRoom", 0);
	layer_set_visible("GameEndRoom", 0);
}

check_layers = function() {
	turn_off_layers();
	switch room {
	case R_Main_menu:
		if O_LoginController.logged_in{
			layer_set_visible(layer_get_id("MainMenu"), 1);
			if O_LoginController.invited {layer_set_visible("InviteWindow", 1)}
			}
		else {layer_set_visible("LoginWindow", 1)}
		break;
	case R_Invite:
		layer_set_visible("InviteRoom", 1);
		break;
	case R_Game_search:
		layer_set_visible("SearchRoom", 1);
		break;
	case R_Game_end:
		layer_set_visible("GameEndRoom", 1);
		break;
	}
}