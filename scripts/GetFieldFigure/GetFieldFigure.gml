// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GetFieldFigure() constructor{
	O_EndTurn.block();
	O_GameField.can_cancel = 0;
	target = undefined
	execute = function() {
		target.filled_figure.capture();
		global.cell_click_callback.clear();
	}
	
	set_target = function(new_target) {
		target = new_target;
		O_EndTurn.unblock();
	}
	
	draw = function() {}
}