// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function StandartMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) : FigureAbilityAction() constructor{
	O_EndTurn.unblock();
	self.from_x = from_x;
	self.from_y = from_y;
	self.to_x = to_x;
	self.to_y = to_y;
	self.figure_sprite = figure_sprite;
	O_GameField.field[to_y][to_x].set_draw_marks(0)
	O_SummonButton.set_back();
	from_move = O_GameField.get_cell(from_x, from_y);
	to_move = O_GameField.get_cell(to_x, to_y);
	draw_previous_cell = false;
	
	
	execute = function() {
		to_move.fill(O_GameField.get_cell(from_x, from_y).filled_figure, 1);
		from_move.clear();
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(self.figure_sprite, 0, to_move.x, to_move.y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if draw_previous_cell{
			draw_sprite_ext(S_cycle_rule, 0, from_move.filled_figure.previous_move_cell.x, from_move.filled_figure.previous_move_cell.y,
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	
	set_new_target_coordinates = function(new_x, new_y) {
		if draw_previous_cell {
			from_move.filled_figure.previous_move_cell.marked = 0;
		}
		if to_x != undefined {to_move.set_draw_marks(1)}
		self.to_x = new_x;
		self.to_y = new_y;
		to_move = O_GameField.get_cell(new_x, new_y);
		to_move.set_draw_marks(0)
		O_EndTurn.unblock()
	}
	
	back = function() {
		if to_x != undefined {
			to_move.set_draw_marks(1)
			to_x = undefined;
			to_y = undefined;
			to_move = undefined;
			O_EndTurn.block()
		}
		else {
			O_GameLoopController.quit_from_action();
		}
	}
	export = function() {
		export_data = {
			action: StandartMoveAbility,
			type: "move_ability",
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_from_x: from_x,
			ex_from_y: from_y
		}
		return export_data
	}
	import = function(import_data) {
		to_x = import_data.ex_to_x;
		to_y = import_data.ex_to_y;
		from_x = import_data.ex_from_x;
		from_y = import_data.ex_from_y;
	}
}