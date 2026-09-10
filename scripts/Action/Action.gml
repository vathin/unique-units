// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Action() constructor{
	type = ""
	execute_logic = function() { return {ok: true, animation_batches: []}; }
	execute_ui = function(_result) {}
	execute = function() {
		var _result = execute_logic();
		if _result.ok {
			execute_ui(_result);
		}
		return _result;
	}
	draw = function() {};
}
