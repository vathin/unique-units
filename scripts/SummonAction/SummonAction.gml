// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function SummonAction(target_x, target_y, figure_sprite) : Action() constructor{
	type = "summon"
	self.target_x = target_x;
	self.target_y = target_y;
	self.figure_sprite = figure_sprite;
	execute = function() {
		O_GameField.field[self.target_x][self.target_y].create_figure(global.figure_to_summon)
		global.selected_cell = "";
	}
	draw = function() {
		draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[self.target_x][self.target_y].x, O_GameField.field[self.target_x][self.target_y].y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
	}
	set_new_target_coordinates = function(new_x, new_y) {
		self.target_x = new_x;
		self.target_y = new_y
	}
}