// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameClass() constructor{
	do_every_step_list = [];
	show_debug_message(Game.do_every_step_list)
	do_every_step = function(list) {
		for (i = 0; i < array_length(list); i++) {
			//script_execute(list[i]) 
		}
	}
	game_loop_controller = new GameLoopController()
	
	field = new Field();
	data = new userData();
	game_data = new gameData()

}