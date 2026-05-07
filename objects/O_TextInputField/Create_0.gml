event_inherited();
image_speed = 0
selected = false;
text = "";

set_text = function(_text) {
	try {
		text = string(_text);
	}
	catch(_exception) {
		show_debug_message("set_text() error");
	}
}

get_text = function() {
	return text
}

clear_text = function() {
	text = ""
}

delete_last_character = function() {
	var _len = string_length(text);
	if _len > 0 {
		text = string_delete(text, _len, 1);
	}
}
