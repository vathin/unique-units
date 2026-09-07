/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

move_button = undefined;
ability_button = undefined;
main_button = undefined;
cancel_button = undefined;
end_turn_button = undefined;
InGame_layer = "GameRoom";
profile_avatar_sprite = -1;
profile_avatar_url = "";
profile_avatar_loaded = false;
profile_avatar_source_sprite = -1;
game_view_width = room_width;
game_view_height = room_height;
game_view_base_height = 1000;
html5_window_width = 0;
html5_window_height = 0;
resize_frame = 0;
resize_ready_frame = 10;
pending_surface_resize = false;
saved_login_fields_loaded = false;
last_scissor_gui = {x: 0, y: 0, w: room_width, h: room_height};
last_scissor_window = {x: 0, y: 0, w: room_width, h: room_height};
last_scissor_debug_key = "";
last_scissor_clear_debug_key = "";
last_scissor_clear_idle_debug_key = "";
last_scissor_draw74_debug_key = "";
last_scissor_draw74_skip_debug_key = "";
local_game_text_applied = false;

sync_gui_size = function(_force = false) {
	if (os_browser != browser_not_a_browser && !_force && resize_frame < resize_ready_frame) {
		return;
	}
	
	var _window_width = max(1, window_get_width());
	var _window_height = max(1, window_get_height());
	var _aspect_width = _window_width;
	var _aspect_height = _window_height;
	var _html5_frame_json = "";
	var _html5_frame_width = 0;
	var _html5_frame_height = 0;
	var _html5_size_source = "window";
	
	if (os_browser != browser_not_a_browser && extension_exists("extension_VK")) {
		_html5_frame_json = HTML5_GetFrameSize();
		var _frame_size = json_parse(_html5_frame_json);
		if (is_struct(_frame_size) && variable_struct_exists(_frame_size, "width") && variable_struct_exists(_frame_size, "height")) {
			_html5_frame_width = max(1, _frame_size.width);
			_html5_frame_height = max(1, _frame_size.height);
			_aspect_width = _html5_frame_width;
			_aspect_height = _html5_frame_height;
			_html5_size_source = "html5_frame";
		}
	}
	
	var _width = max(1, round(game_view_base_height * _aspect_width / _aspect_height));
	var _height = game_view_base_height;
	var _surface_target_width = _window_width;
	var _surface_target_height = _window_height;
	if (os_browser != browser_not_a_browser && _html5_frame_width > 0 && _html5_frame_height > 0
	&& (_html5_frame_width != html5_window_width || _html5_frame_height != html5_window_height)) {
		window_set_rectangle(0, 0, _html5_frame_width, _html5_frame_height);
		html5_window_width = _html5_frame_width;
		html5_window_height = _html5_frame_height;
		show_debug_message("HTML5 window rectangle set: " + string(html5_window_width) + "x" + string(html5_window_height));
	}
	
	var _size_changed = (_width != game_view_width || _height != game_view_height);
	var _surface_size_changed = true;
	if (surface_exists(application_surface)) {
		_surface_size_changed = (surface_get_width(application_surface) != _surface_target_width || surface_get_height(application_surface) != _surface_target_height);
	}
	if (_force || _size_changed || _surface_size_changed || pending_surface_resize) {
		var _surface_resized = false;
		game_view_width = _width;
		game_view_height = _height;
		
		if (surface_exists(application_surface)) {
			surface_resize(application_surface, _surface_target_width, _surface_target_height);
			pending_surface_resize = false;
			_surface_resized = true;
		}
		else {
			pending_surface_resize = true;
		}
		
		display_set_gui_size(game_view_width, game_view_height);
		if (_force || _size_changed || _surface_resized) {
			var _surface_width = -1;
			var _surface_height = -1;
			if (surface_exists(application_surface)) {
				_surface_width = surface_get_width(application_surface);
				_surface_height = surface_get_height(application_surface);
			}
			show_debug_message("UI resize new size: " + string(game_view_width) + "x" + string(game_view_height));
			show_debug_message(
				"UI resize: window=" + string(_window_width) + "x" + string(_window_height)
				+ ", html5_frame=" + string(_html5_frame_width) + "x" + string(_html5_frame_height)
				+ ", html5_source=" + _html5_size_source
				+ ", aspect_source=" + string(_aspect_width) + "x" + string(_aspect_height)
				+ ", room=" + string(room_width) + "x" + string(room_height)
				+ ", gui=" + string(game_view_width) + "x" + string(game_view_height)
				+ ", surface_target=" + string(_surface_target_width) + "x" + string(_surface_target_height)
				+ ", surface_target_source=window"
				+ ", display_gui=" + string(display_get_gui_width()) + "x" + string(display_get_gui_height())
				+ ", surface=" + string(_surface_width) + "x" + string(_surface_height)
				+ ", surface_exists=" + string(surface_exists(application_surface))
				+ ", force=" + string(_force)
				+ ", size_changed=" + string(_size_changed)
				+ ", surface_size_changed=" + string(_surface_size_changed)
				+ ", pending_surface_resize=" + string(pending_surface_resize)
				+ ", resize_frame=" + string(resize_frame)
				+ ", html5_frame_json=" + _html5_frame_json
			);
		}
	}
	else {
		display_set_gui_size(game_view_width, game_view_height);
	}
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

get_ui_sprite_element = function(_layer, _panel) {
	var _node = flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel);
	var _struct = flexpanel_node_get_struct(_node);
	return _struct.layerElements[0].elementId;
}

set_ui_sprite_on_ui_layer = function(_layer, _panel, _sprite) {
	layer_sprite_change(get_ui_sprite_element(_layer, _panel), _sprite);
}

create_round_profile_avatar = function(_source_sprite) {
	if (_source_sprite == -1) {
		return -1;
	}
	var _source_width = sprite_get_width(_source_sprite);
	var _source_height = sprite_get_height(_source_sprite);
	var _size = min(_source_width, _source_height);
	if (_size <= 0) {
		return -1;
	}

	sprite_set_offset(_source_sprite, _source_width / 2, _source_height / 2);
	var _surface = surface_create(_size, _size);
	if (!surface_exists(_surface)) {
		return -1;
	}
	surface_set_target(_surface);
	draw_clear_alpha(c_black, 0);
	draw_set_color(c_white);
	draw_circle(_size / 2, _size / 2, _size / 2, false);

	// Keep avatar pixels only where the opaque circle was drawn.
	gpu_set_blendmode_ext(bm_dest_alpha, bm_zero);
	var _scale = max(_size / _source_width, _size / _source_height);
	draw_sprite_ext(_source_sprite, 0, _size / 2, _size / 2, _scale, _scale, 0, c_white, 1);
	gpu_set_blendmode(bm_normal);
	surface_reset_target();

	var _round_sprite = sprite_create_from_surface(_surface, 0, 0, _size, _size, false, false, _size / 2, _size / 2);
	surface_free(_surface);
	return _round_sprite;
}

set_profile_avatar_from_url = function(_url) {
	if (!is_string(_url) || _url == "") {
		show_debug_message("VK/avatar: empty avatar url");
		return false;
	}
	
	if (_url == profile_avatar_url && profile_avatar_sprite != -1 && profile_avatar_loaded) {
		set_ui_sprite_on_ui_layer("MenuHome", "ProfilePicture", profile_avatar_sprite);
		return true;
	}
	
	profile_avatar_url = _url;
	profile_avatar_loaded = false;
	if (profile_avatar_sprite != -1) {
		sprite_delete(profile_avatar_sprite);
		profile_avatar_sprite = -1;
	}
	profile_avatar_source_sprite = sprite_add_ext(_url, 1, 0, 0, true);
	profile_avatar_sprite = profile_avatar_source_sprite;
	show_debug_message("VK/avatar: loading avatar sprite from " + _url);
	return true;
}

set_text_on_ui_layer = function(_layer_name, _panel_name, _text) {
	var _layer = layer_get_flexpanel_node(_layer_name);
	var _text_panel = flexpanel_node_get_child(_layer, _panel_name);
	var _text_struct = flexpanel_node_get_struct(_text_panel);
	var _textID = _text_struct.layerElements[0].elementId;
	layer_text_text(_textID, _text);
}

set_text_on_child_panel = function(_layer_name, _parent_panel_name, _text_panel_name, _text) {
	var _layer = layer_get_flexpanel_node(_layer_name);
	var _parent_panel = flexpanel_node_get_child(_layer, _parent_panel_name);
	var _text_panel = flexpanel_node_get_child(_parent_panel, _text_panel_name);
	var _text_struct = flexpanel_node_get_struct(_text_panel);
	if array_length(_text_struct.layerElements) > 0 {
		layer_text_text(_text_struct.layerElements[0].elementId, _text);
	}
}

set_ui_text_alpha = function(_layer, _panel, _alpha) {
	layer_text_alpha(flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel)).layerElements[0].elementId, _alpha)
}

ui_scissor = function(_layer, _panel) {
	var _node = flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel);
	var _p = flexpanel_node_get_struct(flexpanel_node_get_child(layer_get_flexpanel_node(_layer), _panel));
	//show_message(_p)
	var _gui_width = gui_width();
	var _gui_height = gui_height();
	var _width = resolve_flex_size(_p.width, _gui_width);
	var _height = resolve_flex_size(_p.height, _gui_height);
	var _x = _gui_width/2-_width/2;
	var _y = _gui_height/2-_height/2;
	var _right_position = flexpanel_node_style_get_position(_node, flexpanel_edge.right);
	var _top_position = flexpanel_node_style_get_position(_node, flexpanel_edge.top);
	var _bottom_position = flexpanel_node_style_get_position(_node, flexpanel_edge.bottom);

	if (_bottom_position.unit != 0) {
		var _offset = _bottom_position.value
		var _unit = _bottom_position.unit
		if _unit == 2 {
			_offset = _offset*_gui_height/100;
		}
		_y -= _offset;
	}
	if (_right_position.unit != 0) {
		var _offset = _right_position.value
		var _unit = _right_position.unit
		if _unit == 2 {
			_offset = _offset*_gui_width/100;
		}
		_x -= _offset;
	}
	if (_top_position.unit != 0) {
		var _offset = _top_position.value
		var _unit = _top_position.unit
		if _unit == 2 {
			_offset = _offset*_gui_height/100;
		}
		_y -= _offset;
	}
	var _left = max(0, floor(_x));
	var _top = max(0, floor(_y));
	var _right = min(_gui_width, ceil(_x + _width));
	var _bottom = min(_gui_height, ceil(_y + _height));
	var _scissor_width = max(1, _right - _left);
	var _scissor_height = max(1, _bottom - _top);
	last_scissor_gui = {x: _left, y: _top, w: _scissor_width, h: _scissor_height};
	
	var _window_width = max(1, window_get_width());
	var _window_height = max(1, window_get_height());
	var _scale_x = _window_width / max(1, _gui_width);
	var _scale_y = _window_height / max(1, _gui_height);
	var _window_left = max(0, floor(_left * _scale_x));
	var _window_top = max(0, floor(_top * _scale_y));
	var _window_right = min(_window_width, ceil((_left + _scissor_width) * _scale_x));
	var _window_bottom = min(_window_height, ceil((_top + _scissor_height) * _scale_y));
	var _window_scissor_width = max(1, _window_right - _window_left);
	var _window_scissor_height = max(1, _window_bottom - _window_top);
	var _previous_gpu_scissor = gpu_get_scissor();
	var _surface_width = -1;
	var _surface_height = -1;
	if (surface_exists(application_surface)) {
		_surface_width = surface_get_width(application_surface);
		_surface_height = surface_get_height(application_surface);
	}
	last_scissor_window = {x: _window_left, y: _window_top, w: _window_scissor_width, h: _window_scissor_height};
	
	if (_left != floor(_x) || _top != floor(_y) || _right != ceil(_x + _width) || _bottom != ceil(_y + _height)) {
		show_debug_message(
			"UI scissor clamped: layer=" + string(_layer)
			+ ", panel=" + string(_panel)
			+ ", raw=" + string(_x) + "," + string(_y) + "," + string(_width) + "," + string(_height)
			+ ", clamped=" + string(_left) + "," + string(_top) + "," + string(_scissor_width) + "," + string(_scissor_height)
			+ ", gui=" + string(_gui_width) + "x" + string(_gui_height)
			+ ", window=" + string(window_get_width()) + "x" + string(window_get_height())
			+ ", pos_units=r" + string(_right_position.unit)
			+ "/t" + string(_top_position.unit) + "/b" + string(_bottom_position.unit)
		);
	}
	
	var _debug_key = string(_layer) + ":" + string(_panel) + ":"
		+ string(_left) + "," + string(_top) + "," + string(_scissor_width) + "," + string(_scissor_height) + ":"
		+ string(_window_left) + "," + string(_window_top) + "," + string(_window_scissor_width) + "," + string(_window_scissor_height) + ":"
		+ string(_gui_width) + "x" + string(_gui_height) + ":" + string(_window_width) + "x" + string(_window_height);
	if (_debug_key != last_scissor_debug_key) {
		last_scissor_debug_key = _debug_key;
		show_debug_message(
			"UI scissor: layer=" + string(_layer)
			+ ", panel=" + string(_panel)
			+ ", gui_rect=" + string(_left) + "," + string(_top) + "," + string(_scissor_width) + "," + string(_scissor_height)
			+ ", gpu_rect=" + string(_window_left) + "," + string(_window_top) + "," + string(_window_scissor_width) + "," + string(_window_scissor_height)
			+ ", previous_gpu=" + string(_previous_gpu_scissor.x) + "," + string(_previous_gpu_scissor.y) + "," + string(_previous_gpu_scissor.w) + "," + string(_previous_gpu_scissor.h)
			+ ", gui=" + string(_gui_width) + "x" + string(_gui_height)
			+ ", window=" + string(_window_width) + "x" + string(_window_height)
			+ ", surface_exists=" + string(surface_exists(application_surface))
			+ ", surface=" + string(_surface_width) + "x" + string(_surface_height)
			+ ", scale=" + string(_scale_x) + "x" + string(_scale_y)
			+ ", pos_units=r" + string(_right_position.unit)
			+ "/t" + string(_top_position.unit) + "/b" + string(_bottom_position.unit)
		);
	}
	
	gpu_set_scissor(_window_left, _window_top, _window_scissor_width, _window_scissor_height)
}

ui_scissor_for_node = function(_node, _debug_name = "") {
	if (_node == undefined) {
		return undefined;
	}
	
	var _layout = flexpanel_node_layout_get_position(_node, false);
	var _gui_width = gui_width();
	var _gui_height = gui_height();
	var _left = max(0, floor(_layout.left));
	var _top = max(0, floor(_layout.top));
	var _right = min(_gui_width, ceil(_layout.left + _layout.width));
	var _bottom = min(_gui_height, ceil(_layout.top + _layout.height));
	var _scissor_width = max(1, _right - _left);
	var _scissor_height = max(1, _bottom - _top);
	
	last_scissor_gui = {x: _left, y: _top, w: _scissor_width, h: _scissor_height};
	
	var _window_width = max(1, window_get_width());
	var _window_height = max(1, window_get_height());
	var _scale_x = _window_width / max(1, _gui_width);
	var _scale_y = _window_height / max(1, _gui_height);
	var _window_left = max(0, floor(_left * _scale_x));
	var _window_top = max(0, floor(_top * _scale_y));
	var _window_right = min(_window_width, ceil((_left + _scissor_width) * _scale_x));
	var _window_bottom = min(_window_height, ceil((_top + _scissor_height) * _scale_y));
	var _window_scissor_width = max(1, _window_right - _window_left);
	var _window_scissor_height = max(1, _window_bottom - _window_top);
	
	last_scissor_window = {x: _window_left, y: _window_top, w: _window_scissor_width, h: _window_scissor_height};
	
	var _debug_key = "node:" + string(_debug_name) + ":"
		+ string(_left) + "," + string(_top) + "," + string(_scissor_width) + "," + string(_scissor_height) + ":"
		+ string(_window_left) + "," + string(_window_top) + "," + string(_window_scissor_width) + "," + string(_window_scissor_height) + ":"
		+ string(_gui_width) + "x" + string(_gui_height) + ":" + string(_window_width) + "x" + string(_window_height);
	if (_debug_key != last_scissor_debug_key) {
		last_scissor_debug_key = _debug_key;
		show_debug_message(
			"UI scroll viewport: name=" + string(_debug_name)
			+ ", layout=" + string(_layout.left) + "," + string(_layout.top) + "," + string(_layout.width) + "," + string(_layout.height)
			+ ", gui_rect=" + string(_left) + "," + string(_top) + "," + string(_scissor_width) + "," + string(_scissor_height)
			+ ", gpu_rect=" + string(_window_left) + "," + string(_window_top) + "," + string(_window_scissor_width) + "," + string(_window_scissor_height)
			+ ", gui=" + string(_gui_width) + "x" + string(_gui_height)
			+ ", window=" + string(_window_width) + "x" + string(_window_height)
			+ ", scale=" + string(_scale_x) + "x" + string(_scale_y)
		);
	}
	
	return last_scissor_gui;
}

ui_scissor_for_scroll = function(_layer, _controlled_element) {
	if (_layer == "default" || _controlled_element == "default") {
		return undefined;
	}
	
	var _layer_node = layer_get_flexpanel_node(_layer);
	if (_layer_node == undefined) {
		return undefined;
	}
	
	var _controlled_node = flexpanel_node_get_child(_layer_node, _controlled_element);
	if (_controlled_node == undefined) {
		return undefined;
	}
	
	var _viewport_node = flexpanel_node_get_parent(_controlled_node);
	if (_viewport_node == undefined) {
		_viewport_node = _controlled_node;
	}
	
	return ui_scissor_for_node(_viewport_node, "scroll:" + string(_layer) + "/" + string(_controlled_element));
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

load_saved_login_fields = function() {
	if (os_type != os_windows) {
		saved_login_fields_loaded = true;
		return;
	}
	
	if (!file_exists("login_data.ini")) {
		saved_login_fields_loaded = true;
		return;
	}
	
	if (!variable_instance_exists(login_text_field, "set_text") || !variable_instance_exists(email_text_field, "set_text") || !variable_instance_exists(password_text_field, "set_text")) {
		return;
	}
	
	ini_open("login_data.ini");
	login_text_field.set_text(ini_read_string("login", "nickname", ""));
	email_text_field.set_text(ini_read_string("login", "email", ""));
	password_text_field.set_text(ini_read_string("login", "password", ""));
	ini_close();
	saved_login_fields_loaded = true;
	
	show_debug_message("Login fields loaded from login_data.ini");
}

save_login_fields = function() {
	if (os_type != os_windows) {
		return;
	}
	
	if (!variable_instance_exists(login_text_field, "get_text") || !variable_instance_exists(email_text_field, "get_text") || !variable_instance_exists(password_text_field, "get_text")) {
		return;
	}
	
	ini_open("login_data.ini");
	ini_write_string("login", "nickname", login_text_field.get_text());
	ini_write_string("login", "email", email_text_field.get_text());
	ini_write_string("login", "password", password_text_field.get_text());
	ini_close();
	
	show_debug_message("Login fields saved to login_data.ini");
}

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
	if variable_instance_exists(login_text_field, "get_text") {
		return login_text_field.get_text()
	}
	return "";
}
get_email_text = function() {
	if variable_instance_exists(email_text_field, "get_text") {
		return email_text_field.get_text()
	}
	return "";
}
get_password_text = function() {
	if variable_instance_exists(password_text_field, "get_text") {
		return password_text_field.get_text()
	}
	return "";
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
