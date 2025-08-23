/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
move_button = undefined;
ability_button = undefined;
main_button = undefined;
cancel_button = undefined;
end_turn_button = undefined;
InGame_layer = "GameRoom";

enum INGAMEBUTTONFRAMES {
	opponent_turn,
	can_summon,
	cant_summon,
	cant_move,
	can_move,
	cant_use_ability,
	can_use_ability,
	cancel
}

enum SIDEBUTTONFRAMES {
	end_turn_inactive,
	end_turn_active,
	cancel_inactive,
	cancel_active
}

turn_off_layers = function() {
	layer_set_visible("MainMenu", 0);
	layer_set_visible("LoginWindow", 0);
	layer_set_visible("InviteWindow", 0);
	layer_set_visible("InviteRoom", 0);
	layer_set_visible("SearchRoom", 0);
	layer_set_visible("GameEndRoom", 0);
	layer_set_visible(InGame_layer, 0);
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

get_button_instance = function(_button) {
	var _struct = flexpanel_node_get_struct(_button);
	var _instID = _struct.layerElements[0].elementId;
	return layer_instance_get_instance(_instID);
}

set_button_frame = function(_button, _frame) {
	var _button_instance = get_button_instance(_button);
	_button_instance.set_frame(_frame);
}

clear_ingame_layer = function() {
	turn_off_button(main_button);
	set_button_frame(main_button, get_button_instance(main_button).standart_frame);
	turn_off_button(move_button);
	set_button_frame(move_button, get_button_instance(move_button).standart_frame);
	turn_off_button(ability_button);
	set_button_frame(ability_button, get_button_instance(ability_button).standart_frame);
	set_button_frame(cancel_button, get_button_instance(cancel_button).standart_frame);
	set_button_frame(end_turn_button, get_button_instance(end_turn_button).standart_frame);
}

main_button = get_button_on_ui(InGame_layer, "MainButton");
move_button = get_button_on_ui(InGame_layer, "MoveButton");
ability_button = get_button_on_ui(InGame_layer, "AbilityButton");
cancel_button = get_button_on_ui(InGame_layer, "CancelButton");
end_turn_button = get_button_on_ui(InGame_layer, "EndTurnButton");


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
//show_message(get_button_instance(main_button).x)