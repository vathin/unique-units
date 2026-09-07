if (async_load[? "id"] == profile_avatar_source_sprite) {
	var _status = async_load[? "status"];
	var _http_status = 200;
	
	if (ds_map_exists(async_load, "http_status")) {
		_http_status = async_load[? "http_status"];
	}
	
	if (_status >= 0) {
		var _round_sprite = create_round_profile_avatar(profile_avatar_source_sprite);
		if (_round_sprite != -1) {
			sprite_delete(profile_avatar_source_sprite);
			profile_avatar_source_sprite = -1;
			profile_avatar_sprite = _round_sprite;
			profile_avatar_loaded = true;
			set_ui_sprite_on_ui_layer("MenuHome", "ProfilePicture", profile_avatar_sprite);
			show_debug_message("VK/avatar: avatar loaded as round sprite, status=" + string(_status) + ", http_status=" + string(_http_status));
		}
		else {
			show_debug_message("VK/avatar: round avatar creation failed");
			profile_avatar_loaded = false;
		}
	}
	else {
		show_debug_message("VK/avatar: avatar load failed, status=" + string(_status) + ", http_status=" + string(_http_status));
		profile_avatar_loaded = false;
		profile_avatar_sprite = -1;
		profile_avatar_source_sprite = -1;
	}
}
