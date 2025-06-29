// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameClass() constructor{
	do_every_step_list = [];
	do_every_step = function(list) {
		for (i = 0; i < array_length(list); i++) {
			list[i]()
		}
	}
	init = function() {
		game_loop_controller = new GameLoopController();
		field = new Field();
		user_data = new userData();
		game_data = new gameData();
		Player1 = new Player(1, "local")
		Player2 = new Player(2, "local")
		summon_controller = undefined;
		figure_action_controller = undefined;
		ability_input_controller = undefined;
		move_input_controller = undefined;
		Maps_list.start(global.map)
	}
}