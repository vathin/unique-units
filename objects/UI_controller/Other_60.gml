if (async_load[? "id"] == profile_avatar_sprite) {
	var _status = async_load[? "status"];
	var _http_status = 200;
	
	if (ds_map_exists(async_load, "http_status")) {
		_http_status = async_load[? "http_status"];
	}
	
	if (_status >= 0) {
		profile_avatar_loaded = true;
		set_ui_sprite_on_ui_layer("MenuHome", "ProfilePicture", profile_avatar_sprite);
		show_debug_message("VK/avatar: avatar loaded, status=" + string(_status) + ", http_status=" + string(_http_status));
	}
	else {
		show_debug_message("VK/avatar: avatar load failed, status=" + string(_status) + ", http_status=" + string(_http_status));
		profile_avatar_loaded = false;
		profile_avatar_sprite = -1;
	}
}
