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