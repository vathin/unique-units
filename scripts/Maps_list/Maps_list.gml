// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Maps_list() constructor{
	static maps = {
		map1: new Map1()
	}
	static player1 = [];
	static player2 = [];
	
	static get_map_sprite = function(map_type) {
		return maps[$ map_type].sprite
	}

	static select_map = function(map_type) {
		var _map_key = map_type == undefined ? "map1" : string(map_type);
		var _map = variable_struct_exists(maps, _map_key) ? maps[$ _map_key] : maps.map1;
		player1 = deep_copy(_map.conquest_player1_cells);
		player2 = deep_copy(_map.conquest_player2_cells);
		return [player1, player2];
	}
	
	static start = function(map_type) {
		select_map(map_type);
		if Game.field == undefined {
			return;
		}
		for (i = 0; i < array_length(player1); i++) {
			Game.field.get_cell(player1[i][0], player1[i][1]).can_be_conquested = 1;
		}
		for (i = 0; i < array_length(player2); i++) {
			Game.field.get_cell(player2[i][0], player2[i][1]).can_be_conquested = 1;
		}
	}
	
	static get_cells_for_conquest = function() {
		if array_length(player1) <= 0 && array_length(player2) <= 0 {
			select_map(global.map);
		}
		return [player1, player2]
	}
	
}

new Maps_list();
