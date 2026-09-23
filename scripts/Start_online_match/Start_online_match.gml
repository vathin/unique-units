
function Start_online_match(_server_id, _enemy, _role){
	if Game != undefined && Game.input_session != undefined {
		Game.input_session.clear();
	}
	global.able_to_summon = false;
	global.moving_figure = false;
	global.using_ability = false;
	global.figure_to_summon = undefined;
	global.map = "map1";
	
	
	//Game = new GameClass();
	Game.start_online(_server_id, _enemy, _role);
	
}
