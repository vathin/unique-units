/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

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