/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редактор

standart_scale = 1;
image_xscale = standart_scale;
image_yscale = standart_scale;
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
	filled_figure = instance_create_depth(self.x, self.y, -1, O_Figure);
	filled_figure.set_behaviour(figure_behaviour);
	O_Figures_counter.change_field_figures_amount(global.turn_owner, +1);
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
	filled_figure.check_cycle_rule();
		found_clear_cells = 0
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <=1; m++) {
				cell = O_GameField.get_cell(xcord + i, ycord +m);
				if cell != undefined{
					if cell != O_GameField.get_cell(xcord, ycord) {
						if !cell.is_filled() {found_clear_cells++}
						else {
							if cell.filled_figure.state.is_dropped {found_clear_cells++}
						}
					}
				}
			}
		}
		if found_clear_cells == 0 {
			O_Figures_counter.add_figure_to_capture(filled_figure, self);
		}
}

export = function() {
	filled_figure_struct = undefined
	if is_filled() {filled_figure_struct = filled_figure.export()}
	export_data = {
		ex_can_be_conquested: can_be_conquested,
		ex_draw_mark: draw_mark,
		ex_filled_figure: filled_figure,
		ex_filled_figure_struct: filled_figure_struct
	}
	return export_data
}

import = function(import_data) {
	clear();
	can_be_conquested = import_data.ex_can_be_conquested;
	ex_draw_mark = import_data.ex_draw_mark;
	if import_data.ex_filled_figure_struct != undefined {
		create_figure(import_data.ex_filled_figure_struct.ex_behaviour);
		O_Figures_counter.change_field_figures_amount(global.turn_owner, -1);
		filled_figure.import(import_data.ex_filled_figure_struct);
	}
}