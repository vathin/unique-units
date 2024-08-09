// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Turn() constructor{
	actions = [];
	
	execute = function() {
		for (i = 0; i < array_length(actions); i++) {
			actions[i].execute();
		}
	}
	
	clear = function() {}
	add = function(action) {
		array_push(actions, action)
	}
}