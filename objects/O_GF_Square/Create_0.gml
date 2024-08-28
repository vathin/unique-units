/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редактор
can_be_conquested = false;
draw_mark = true;
marked = false;
filled_figure = undefined;
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
		O_Figures_counter.change_field_figures_amount(global.turn_owner, +1);
	}
}
clear = function() {
	filled_figure = undefined;
}
fill = function(new_figure, is_moving) {
	filled_figure = new_figure
	if !is_moving {
		new_figure.x = self.x;
		new_figure.y = self.y;
	}
	self.draw_mark = 1;
}
is_filled = function() {
	return filled_figure != undefined
}

is_under_control = function(player) {
	result = false
	neightbors = O_GameField.cell_get_neightbors(self);
	for (i = 0; i < array_length(neightbors); i++) {
		if neightbors[i].is_filled() {
			if neightbors[i].filled_figure.owner = player {
				result = 1
			}
		}
	}
	return result;
}

get_cord = function() {
	return [ycord, xcord]
}

update_filled_figure_state = function() {
	if filled_figure.state.is_active {
		found_clear_figures = 0
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <=1; m++) {
				cell = O_GameField.get_cell(xcord + i, ycord +m);
				if cell != undefined{
					if !cell.is_filled() and cell != O_GameField.get_cell(xcord, ycord) {found_clear_figures += 1}
				}
			}
		}
		if found_clear_figures = 0 {
			filled_figure.capture(1);
			clear();
		}
	}
}
