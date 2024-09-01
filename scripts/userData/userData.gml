// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function userData() constructor {
	
	standart_data_struct = {
		player_cards: ["trader", "archer", "shieldbearer", "warrior", "spearman"],
		player_figures: ["trader", "archer", "archer", "archer", "archer", "shieldbearer", 
		"shieldbearer", "shieldbearer", "shieldbearer", "warrior", "warrior", "warrior", 
		"warrior", "warrior", "warrior", "warrior", "spearman", "spearman", "spearman", "spearman"]
	}
	randomize();
	standart_data_struct.player_figures = array_shuffle(standart_data_struct.player_figures);
	
	
	load = function(player) {
		if player = "player1" {
			try {
				file = file_text_open_read("player1_data.json");
				data = json_parse(file_text_read_string(file))
				file_text_close(file);
				return data
			}
			catch(exception) {
				return standart_data_struct
			}
		}
		if player = "player2" {
			try {
				file = file_text_open_read("player2_data.json");
				data = json_parse(file_text_read_string(file))
				file_text_close(file);
				return data
			}
			catch(exception) {
				return standart_data_struct
		}
	
	}
	}
	
	save = function(player, data_struct) {
		if player = "player1" {
				file = file_text_open_write("player1_data.json");
				data = json_stringify(data_struct);
				file_text_write_string(file, data)
				file_text_close(file);
		}
		if player = "player2" {
				file = file_text_open_write("player2_data.json");
				data = json_stringify(data_struct);
				file_text_write_string(file, data)
				file_text_close(file);
		}
	}
	save("player1", standart_data_struct);
	randomize();
	standart_data_struct.player_figures = array_shuffle(standart_data_struct.player_figures)
	save("player2", standart_data_struct);

}