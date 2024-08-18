// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function StandartMoveAbility(from_x, from_y, to_x, to_y, figure_sprite) : FigureAbilityAction() constructor{
	type = "move";
	self.from_x = from_x;
	self.from_y = from_y;
	self.to_x = to_x;
	self.to_y = to_y;
	self.figure_sprite = figure_sprite;
	O_GameField.field[to_y][to_x].set_draw_marks(0)
	
	
	execute = function() {
		O_GameField.field[to_y][to_x].fill(global.selected_cell.filled_figure, 1);
		O_GameField.field[from_y][from_x].clear();
	}
	
	draw = function() {
		draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
	}
	
	set_new_target_coordinates = function(new_x, new_y) {
		O_GameField.get_cell(to_x, to_y).set_draw_marks(1)
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0)
	}
	
}