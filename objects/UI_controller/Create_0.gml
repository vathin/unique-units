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

get_element_on_ui = function(_layer, _panel) {
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

set_ui_sprite_alpha = function(_layer, _panel, _alpha) {
	layer_sprite_alpha(flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer),
	_panel)).layerElements[0].elementId, _alpha);
}

set_ui_text_alpha = function(_layer, _panel, _alpha) {
	layer_text_alpha(flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel)).layerElements[0].elementId, _alpha)
}

ui_scissor = function(_layer, _panel) {
	var _p = flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel));
	var _width = _p.width;
	var _height = _p.height;
	gpu_set_scissor(window_get_width()/2-_width/2, window_get_height()/2-_height/2, _width, _height)
}

main_button = get_element_on_ui(InGame_layer, "MainButton");
move_button = get_element_on_ui(InGame_layer, "MoveButton");
ability_button = get_element_on_ui(InGame_layer, "AbilityButton");
cancel_button = get_element_on_ui(InGame_layer, "CancelButton");
end_turn_button = get_element_on_ui(InGame_layer, "EndTurnButton");

login_button = get_element_on_ui("LoginWindow", "LoginButton");
register_button = get_element_on_ui("LoginWindow", "RegistrationButton");
login_text_field = get_button_instance((get_element_on_ui("LoginWindow", "LoginField")))
email_text_field = get_button_instance((get_element_on_ui("LoginWindow", "EmailField")))
password_text_field = get_button_instance((get_element_on_ui("LoginWindow", "PasswordField")))
nickname_panel = get_element_on_ui("MainMenu", "Nickname")
turn_off_button(register_button);

#region Main_menu
menu_layers = ["MenuHome", "MenuBattlePass", "MenuDeckSettings", "MenuSettings", "MenuShop", "MenuProfile", "MenuDeckSettings"];
menu_icons_panels = ["HomeIcon", "BattlePassIcon", "DeckIcon", "SettingsIcon", "ShopIcon"];
menu_scrollable_pages = ["MenuBattlePass", "MenuSettings", "MenuShop", "MenuDeck", "MenuDeckSettings"]

enum menu_pages {
	HomePage,
	BattlePassPage,
	DeckPage,
	SettingsPage,
	ShopPage,
	ProfilePage,
	DeckSettingsPage
}

menu_scroll_position = 0;
current_page = menu_pages.HomePage;
default_window_percent_size = 65;

enum LOGIN_MODES {
	login,
	register
}
login_mode = LOGIN_MODES.register;
switch_login_mode = function() {
	set_ui_text_alpha("LoginWindow", "RegistrationBText", 0);
	set_ui_text_alpha("LoginWindow", "LoginBText", 0);
	if login_mode == LOGIN_MODES.login {
		login_mode = LOGIN_MODES.register;
		turn_off_button(login_button);
		turn_on_button(register_button);
		set_ui_text_alpha("LoginWindow", "RegistrationBText", 1)
	}
	else {
		login_mode = LOGIN_MODES.login;
		turn_on_button(login_button);
		turn_off_button(register_button);
		set_ui_text_alpha("LoginWindow", "LoginBText", 1)
	}
}
switch_login_mode();

get_login_text = function() {
	return login_text_field.get_text()
}
get_email_text = function() {
	return email_text_field.get_text()
}
get_password_text = function() {
	return password_text_field.get_text()
}

check_scroll = function() {
	if layer_get_visible(layer_get_id("MainMenu")) 
	and page_is_scrollable(current_page) {return current_page}
	return undefined;
}

get_upper_percent_border = function(_page){
	return (flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(menu_layers[_page]), "Window")).height/window_get_height()*100 -default_window_percent_size)/2
}

switch_menu_page = function(_new_page) {
	current_page = _new_page;
	check_layers();
	menu_scroll_position = 0;
	if (page_is_scrollable(_new_page)) {
		menu_scroll_position = get_upper_percent_border(_new_page);
	}
	scroll_menu_page(current_page, 0);
	O_LoginController.delete_invite_text_field();
}

get_current_page = function() {
	return current_page
}

get_page_from_array = function(_page) {
	return menu_layers[_page]
}

clear_menu_layers = function() {
	for (i = 0; i < array_length(menu_icons_panels); i++) {
		set_ui_sprite_alpha("MainMenu", menu_icons_panels[i], 1);
	}
	if (current_page < menu_pages.ProfilePage) {
		set_ui_sprite_alpha("MainMenu", menu_icons_panels[current_page], 0.45);
	}
	for (i = 0; i < array_length(menu_layers); i++) {
		layer_set_visible(menu_layers[i], 0);
	}
}

turn_on_menu_layer = function() {
	layer_set_visible(menu_layers[current_page], 1)
}

scroll_menu_page = function(_page, _direction, _scroll_speed = undefined) {
	if _scroll_speed != undefined {menu_scroll_position += _scroll_speed}
	else {menu_scroll_position += _direction*5;}
	var _layer = menu_layers[_page];
	var _panel = flexpanel_node_get_child(layer_get_flexpanel_node(_layer), "Window");
	if menu_scroll_position < -25 {menu_scroll_position = -25}
	else if menu_scroll_position > get_upper_percent_border(current_page) {menu_scroll_position = get_upper_percent_border(current_page)}
	flexpanel_node_style_set_position(_panel, flexpanel_edge.top, menu_scroll_position, flexpanel_unit.percent)
}

page_is_scrollable = function(_page) {
	if array_get_index(menu_scrollable_pages, menu_layers[_page]) != -1 {return true}
	return false;
}

is_current_page_scrollable = function() {
	if page_is_scrollable(current_page) {return true}
	return false
}

#endregion



clear_ingame_layer = function(_full_clear = 0) {
	turn_off_button(main_button);
	get_button_instance(main_button).clear(_full_clear);
	turn_off_button(move_button);
	get_button_instance(move_button).clear(_full_clear);
	turn_off_button(ability_button);
	get_button_instance(ability_button).clear(_full_clear);
	get_button_instance(cancel_button).clear(_full_clear);
	get_button_instance(end_turn_button).clear(_full_clear);
}

turn_off_layers = function() {
	layer_set_visible("HomeMenu", 0);
	layer_set_visible("MainMenu", 0);
	layer_set_visible("LoginWindow", 0);
	layer_set_visible("InviteWindow", 0);
	layer_set_visible("InviteRoom", 0);
	layer_set_visible("SearchRoom", 0);
	layer_set_visible("GameEndRoom", 0);
	layer_set_visible(InGame_layer, 0);
	clear_menu_layers();
}

check_layers = function() {
	turn_off_layers();
	switch room {
	case R_Main_menu:
		if O_LoginController.logged_in{
			layer_set_visible(layer_get_id("MainMenu"), 1);
			turn_on_menu_layer();
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

//_panel = flexpanel_create_node(flexpanel_node_get_struct(get_element_on_ui("MenuDeck", "Deck1")));
//_panel2_struct = flexpanel_node_get_struct(get_element_on_ui("MenuDeck", "Deck1"));
//_panel2_struct.nodes[0].layerElements[0].textText = "Test_n2";
//_panel2_struct.name = "Deck5";
//_panel2 = flexpanel_create_node(_panel2_struct);
//flexpanel_node_insert_child(get_element_on_ui("MenuDeck", "DecksList"), _panel, 1);
//flexpanel_node_insert_child(get_element_on_ui("MenuDeck", "DecksList"), _panel2, 0);
//show_message(flexpanel_node_get_struct(get_element_on_ui("MenuDeck", "Deck5")));