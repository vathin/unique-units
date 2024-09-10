// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function StandartMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) : FigureAbilityAction() constructor{
	type = "move";
	O_EndTurn.unblock();
	self.from_x = from_x;
	self.from_y = from_y;
	self.to_x = to_x;
	self.to_y = to_y;
	self.figure_sprite = figure_sprite;
	O_GameField.field[to_y][to_x].set_draw_marks(0)
	O_SummonButton.set_back();
	
	execute = function() {
		O_GameField.get_cell(to_x, to_y).fill(O_GameField.get_cell(from_x, from_y).filled_figure, 1);
		O_GameField.get_cell(from_x, from_y).clear();
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	
	set_new_target_coordinates = function(new_x, new_y) {
		if to_x != undefined {O_GameField.get_cell(to_x, to_y).set_draw_marks(1)}
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0)
		O_EndTurn.unblock()
	}
	
	back = function() {
		if to_x != undefined {
			O_GameField.field[to_y][to_x].set_draw_marks(1)
			to_x = undefined;
			to_y = undefined;
			O_EndTurn.block()
		}
		else {
			if instance_exists(O_MoveInputController) {instance_destroy(O_MoveInputController)}
			O_GameField.clear_all_marks();
			global.cell_click_callback = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_SummonButton.go_away();
			global.moving_figure = 0;
			O_GameLoopController.action = undefined;
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