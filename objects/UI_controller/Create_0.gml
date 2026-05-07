/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

move_button = undefined;
ability_button = undefined;
main_button = undefined;
cancel_button = undefined;
end_turn_button = undefined;
InGame_layer = "GameRoom";

sync_gui_size = function() {
	display_set_gui_size(room_width, room_height);
}

gui_width = function() {
	return display_get_gui_width();
}

gui_height = function() {
	return display_get_gui_height();
}

gui_mouse_x = function() {
	return device_mouse_x_to_gui(0);
}

gui_mouse_y = function() {
	return device_mouse_y_to_gui(0);
}

gui_mouse_delta_x = function() {
	return window_mouse_get_delta_x()*gui_width()/max(1, window_get_width());
}

gui_mouse_delta_y = function() {
	return window_mouse_get_delta_y()*gui_height()/max(1, window_get_height());
}

gui_mouse_in_bbox = function(_left, _top, _right, _bottom) {
	return point_in_rectangle(gui_mouse_x(), gui_mouse_y(), _left, _top, _right, _bottom);
}

resolve_flex_size = function(_size, _full_size) {
	if is_real(_size) {
		return _size;
	}
	if is_string(_size) {
		return _full_size*real(_size)/100;
	}
	if is_struct(_size) {
		var _unit = 1;
		var _value = 0;
		if variable_struct_exists(_size, "unit") {
			_unit = _size.unit;
		}
		if variable_struct_exists(_size, "value") {
			_value = _size.value;
		}
		if _unit == 2 {
			return _full_size*_value/100;
		}
		return _value;
	}
	return _full_size;
}

sync_gui_size();

if os_browser != browser_not_a_browser {
	browser_input_capture(true);
}



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

set_text_on_ui_layer = function(_layer_name, _panel_name, _text) {
	var _layer = layer_get_flexpanel_node(_layer_name);
	var _text_panel = flexpanel_node_get_child(_layer, _panel_name);
	var _text_struct = flexpanel_node_get_struct(_text_panel);
	var _textID = _text_struct.layerElements[0].elementId;
	layer_text_text(_textID, _text);
}

set_ui_text_alpha = function(_layer, _panel, _alpha) {
	layer_text_alpha(flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel)).layerElements[0].elementId, _alpha)
}

ui_scissor = function(_layer, _panel) {
	var _node = flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel);
	var _p = flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel));
	//show_message(_p)
	var _width = resolve_flex_size(_p.width, gui_width());
	var _height = resolve_flex_size(_p.height, gui_height());
	var _x = gui_width()/2-_width/2;
	var _y = gui_height()/2-_height/2;
	if (flexpanel_node_style_get_position(_node, flexpanel_edge.bottom).unit != 0) {
		var _offset = flexpanel_node_style_get_position(_node, flexpanel_edge.bottom).value
		var _unit = flexpanel_node_style_get_position(_node, flexpanel_edge.bottom).unit
		if _unit == 2 {
			_offset = _offset*gui_height()/100;
		}
		_y -= _offset;
	}
	gpu_set_scissor(_x, _y, _width, _height)
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


enum menu_pages {
	HomePage,
	BattlePassPage,
	DeckPage,
	SettingsPage,
	ShopPage,
	ProfilePage,
	DeckSettingsPage
}

set_element_position = function(_layer, _element, _position, _edge, _unit = 2, _offset = 0) {
	if _position < 0 {_position = 0}
	if _position > 1 {_position = 1}
	var _el = get_element_on_ui(_layer, _element);
	flexpanel_node_style_set_position(_el, _edge, (_position+_offset)*100, _unit)
}

menu_scroll_position = 0;
current_page = menu_pages.HomePage;

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

switch_menu_page = function(_new_page) {
	current_page = _new_page;
	check_layers();
	O_Server.delete_invite_text_field();
}

get_current_page = function() {
	return current_page
}

get_page_from_array = function(_page) {
	return menu_layers[_page]
}

set_layer_visible_safe = function(_layer, _visible) {
	if is_string(_layer) {
		if _layer == "HomeMenu" {
			return;
		}
		layer_set_visible(_layer, _visible);
		return;
	}
	if is_real(_layer) and _layer != -1 {
		layer_set_visible(_layer, _visible);
	}
}

clear_menu_layers = function() {
	for (i = 0; i < array_length(menu_icons_panels); i++) {
		set_ui_sprite_alpha("MainMenu", menu_icons_panels[i], 1);
	}
	if (current_page < menu_pages.ProfilePage) {
		set_ui_sprite_alpha("MainMenu", menu_icons_panels[current_page], 0.45);
	}
	for (i = 0; i < array_length(menu_layers); i++) {
		set_layer_visible_safe(menu_layers[i], 0);
	}
}

turn_on_menu_layer = function() {
	set_layer_visible_safe(menu_layers[current_page], 1)
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
	Game.game_loop_controller.figures_counter.clear_available_figures_text();
}

turn_off_layers = function() {
	set_layer_visible_safe("HomeMenu", 0);
	set_layer_visible_safe("MainMenu", 0);
	set_layer_visible_safe("LoginWindow", 0);
	set_layer_visible_safe("InviteWindow", 0);
	set_layer_visible_safe("InviteRoom", 0);
	set_layer_visible_safe("SearchRoom", 0);
	set_layer_visible_safe("GameEndRoom", 0);
	set_layer_visible_safe(InGame_layer, 0);
	clear_menu_layers();
}

check_layers = function() {
	turn_off_layers();
	switch room {
	case R_Main_menu:
		if O_Server.logged_in{
			set_layer_visible_safe("MainMenu", 1);
			turn_on_menu_layer();
			if O_Server.invited {set_layer_visible_safe("InviteWindow", 1)}
			}
		else {set_layer_visible_safe("LoginWindow", 1)}
		break;
	case R_Invite:
		set_layer_visible_safe("InviteRoom", 1);
		break;
	case R_Game_search:
		set_layer_visible_safe("SearchRoom", 1);
		break;
	case R_Game_end:
		set_layer_visible_safe("GameEndRoom", 1);
		break;
	case R_Test:
		set_layer_visible_safe(InGame_layer, 1)
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
