// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GetFieldFigure() constructor{
	O_BoardDraw.block_end_button();
	Game.field.can_cancel = 0;
	target = undefined;
	
	execute = function() {
		array_push(Game.game_loop_controller.action_export_data, self)
		target.filled_figure.capture();
		place = Game.field.get_place("capture", 
		Game.game_loop_controller.get_opponent(target.filled_figure.owner));
		place.add_figure(target.filled_figure);
		target.clear();
	}
	
	set_target = function(new_target) {
		target = new_target;
		O_BoardDraw.unblock_end_button();
	}
	
	draw = function() {}
	
	export = function() {
		export_data = {
			ex_action: GetFieldFigure,
			ex_type: "get_field_figure",
			ex_target: [target.xcord, target.ycord]
		}
	}
	
	import = function(_import_data) {
		target = Game.field.get_cell(_import_data.ex_target[0], _import_data.ex_target[1]);
	}
}