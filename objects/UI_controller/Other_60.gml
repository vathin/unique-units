var _is_profile_avatar = async_load[? "id"] == profile_avatar_source_sprite;
var _is_opponent_avatar = async_load[? "id"] == opponent_avatar_source_sprite;
if (_is_profile_avatar || _is_opponent_avatar) {
	var _status = async_load[? "status"];
	var _http_status = 200;
	
	if (ds_map_exists(async_load, "http_status")) {
		_http_status = async_load[? "http_status"];
	}
	
	if (_status >= 0) {
		var _source_sprite = profile_avatar_source_sprite;
		if (_is_opponent_avatar) {
			_source_sprite = opponent_avatar_source_sprite;
		}
		var _round_sprite = create_round_profile_avatar(_source_sprite);
		if (_round_sprite != -1) {
			sprite_delete(_source_sprite);
			if (_is_profile_avatar) {
				profile_avatar_source_sprite = -1;
				profile_avatar_sprite = _round_sprite;
				profile_avatar_loaded = true;
				set_profile_avatar_sprite(profile_avatar_sprite);
				show_debug_message("VK/avatar: avatar loaded as round sprite, status=" + string(_status) + ", http_status=" + string(_http_status));
			}
			else {
				opponent_avatar_source_sprite = -1;
				opponent_avatar_sprite = _round_sprite;
				opponent_avatar_loaded = true;
				set_opponent_avatar_sprite(opponent_avatar_sprite);
				show_debug_message("Opponent avatar: loaded as round sprite, status=" + string(_status) + ", http_status=" + string(_http_status));
			}
		}
		else {
			show_debug_message("Avatar: round avatar creation failed");
			if (_is_profile_avatar) {
				profile_avatar_loaded = false;
			}
			else {
				opponent_avatar_loaded = false;
			}
		}
	}
	else {
		show_debug_message("Avatar load failed, status=" + string(_status) + ", http_status=" + string(_http_status));
		if (_is_profile_avatar) {
			profile_avatar_loaded = false;
			profile_avatar_sprite = -1;
			profile_avatar_source_sprite = -1;
		}
		else {
			opponent_avatar_loaded = false;
			opponent_avatar_sprite = -1;
			opponent_avatar_source_sprite = -1;
		}
	}
}
