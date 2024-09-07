// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Maps_list() constructor{
	static maps = {
		map1: new Map1()
	}
	
	static get_map_sprite = function(map_type) {
		return maps[$ map_type].sprite
	}
	
	static start = function(map_type) {
		check_map = maps[$ map_type];
		O_GameField.sprite_index = get_map_sprite(map_type);
		player1 = check_map.conquest_player1_cells;
		player2 = check_map.conquest_player2_cells;
		for (i = 0; i < array_length(player1); i++) {
			O_GameField.get_cell(player1[i][0], player1[i][1]).can_be_conquested = 1;
		}
		for (i = 0; i < array_length(player2); i++) {
			O_GameField.get_cell(player2[i][0], player2[i][1]).can_be_conquested = 1;
		}
	}
	
	static check_if_any_cell_conquested = function(map) {
		check_map = maps[$ map];
		player1 = check_map.conquest_player1_cells;
		player2 = check_map.conquest_player2_cells;
		for (i = 0; i < array_length(player1); i++) {
			if O_GameField.get_cell(player1[i][0], player1[i][1]).is_filled() {
				if O_GameField.get_cell(player1[i][0], player1[i][1]).filled_figure.owner == "player2" 
				and O_GameField.get_cell(player1[i][0], player1[i][1]).filled_figure.state.is_active {
					O_GameLoopController.player2_captured += 1
					O_GameField.get_cell(player1[i][0], player1[i][1]).filled_figure.alarm[1] = 30
				}
			}
		}
		for (i = 0; i < array_length(player2); i++) {
			if O_GameField.get_cell(player2[i][0], player2[i][1]).is_filled() {
				if O_GameField.get_cell(player2[i][0], player2[i][1]).filled_figure.owner == "player1" 
				and O_GameField.get_cell(player2[i][0], player2[i][1]).filled_figure.state.is_active {
					O_GameLoopController.player1_captured += 1;
					 O_GameField.get_cell(player2[i][0], player2[i][1]).filled_figure.alarm[1] = 30
				}
			}
		}
	}
}

new Maps_list();