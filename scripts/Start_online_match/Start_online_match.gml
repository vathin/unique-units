// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Start_online_match(_server_id, _enemy, _role){
	global.cell_click_callback = undefined;
	global.selected_cell = undefined;
	global.able_to_summon = false;
	global.moving_figure = false;
	global.using_ability = false;
	global.figure_to_summon = undefined;
	global.map = "map1";
	
	
	//Game = new GameClass();
	Game.start_online(_server_id, _enemy, _role);
	
}