/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редактор
draw_mark = true;
marked = false;
filled_figure = "";
var xcord;
var ycord;

set_draw_marks = function(value) {
	draw_mark = value
}

create_figure = function(figure_behaviour) {
	if (!is_filled()){
		filled_figure = instance_create_depth(self.x, self.y, -1, O_Figure);
		filled_figure.set_behaviour(figure_behaviour);
		global.able_to_summon = false;
		O_SummonButton.go_to_standart_mode();
	}
}
clear = function() {
	filled_figure = "";
}
fill = function(new_figure) {
	filled = 1
	filled_figure = new_figure
	new_figure.x = self.x;
	new_figure.y = self.y;
	self.draw_mark = 1;
}
is_filled = function() {
	return filled_figure != ""
}

is_under_control = function(player) {
	friendly = false;
	hostile = false;
	neightbors = O_GameField.cell_get_neightbors(self);
	for (i = 0; i < array_length(neightbors); i++) {
		if neightbors[i].filled_figure != "" {
			if neightbors[i].filled_figure.owner = player {
				friendly = 1;
			}
			else {
				hostile = 1;
			}
			if (friendly and !hostile) {
				return true;
			}
			if (friendly and hostile) and ((m = 2 and i = 2) or (m = 3 and i = 2) or (m = 2 and i = 3) or (m = 3 and i = 3)) {
				return true;
			}
		}
	}
	return false
}

get_cord = function() {
	return [ycord, xcord]
}
