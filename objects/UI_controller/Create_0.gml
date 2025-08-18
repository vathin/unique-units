/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
move_button = undefined;
ability_button = undefined;
main_button = undefined;
InGame_layer = "GameRoom"

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

get_button_on_ui = function(_layer, _panel) {
	var _l = layer_get_flexpanel_node(_layer);
	var _p = flexpanel_node_get_child(_l, _panel);
	return _p
}

turn_on_button = function (_button) {
	flexpanel_node_style_set_display(_button, flexpanel_display.flex)
}

turn_off_button = function(_button) {
	flexpanel_node_style_set_display(_button, flexpanel_display.none)
}

clear_ingame_layer = function() {
	turn_off_button(main_button);
	turn_off_button(move_button);
	turn_off_button(ability_button);
}

main_button = get_button_on_ui(InGame_layer, "MainButton");
move_button = get_button_on_ui(InGame_layer, "MoveButton");
ability_button = get_button_on_ui(InGame_layer, "AbilityButton");


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
	case R_Test:
		layer_set_visible(InGame_layer, 1)
		break;
	}
}