// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Start_match(){
	global.cell_click_callback = undefined;
	global.selected_cell = undefined;
	global.able_to_summon = false;
	global.moving_figure = false;
	global.using_ability = false;
	global.figure_to_summon = undefined;
	global.map = "map1";
	
	//#macro Game global.game
	//Game = undefined
	//Game = new GameClass()
	Game.init()
	O_BoardDraw.in_game = true
	

}