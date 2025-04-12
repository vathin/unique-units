// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Start_match(){
	#macro Game global.game

	Game = undefined
	Game = new GameClass()
	Game.init()
	O_BoardDraw.in_game = true
	
}