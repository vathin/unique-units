// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function gameData() constructor{
	save_action = function(save_data) {
		file = file_text_open_write("gameActionData.json");
		file_text_write_string(file, json_stringify(save_data));
		file_text_close(file);
	}
	load_action = function() {
		try{
			file = file_text_open_read("gameActionData.json");
			load_data = json_parse(file_text_read_string(file));
			file_text_close(file);
			return load_data;
		}
		catch(exception) {
			return undefined
		}
	}
	save_field = function(save_data) {
		file = file_text_open_write("gameFieldData.json");
		file_text_write_string(file, json_stringify(save_data));
		file_text_close(file);
	}
	
	load_field = function() {
		try{
			file = file_text_open_read("gameFieldData.json");
			load_data = json_parse(file_text_read_string(file));
			file_text_close(file);
			return load_data;
		}
		catch(exception) {
			return undefined
		}
	}
}