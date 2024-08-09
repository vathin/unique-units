// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function MoveAction(from_x, from_y, to_x, to_y, moving_figure) : Action() constructor{
	type = "Move";
	self.from_x = from_x;
	self.from_y = from_y;
	self.to_x = to_x;
	self.to_y = to_y;
	self.moving_figure = moving_figure;
	
	execute = function() {
		O_GameField.field[from_x][from_y].clear();
		O_GameField.field[to_x][to_y].fill(moving_figure);
	}
	
	
	draw = function() {
		draw_sprite_ext(self.moving_figure.sprite_index, 0, O_GameField.field[self.to_x][self.to_y].x, O_GameField.field[self.to_x][self.to_y].y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
	}
}