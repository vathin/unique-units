/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
size = 400;
figures = [];
facing = 1;
place_direction = 1;
last_added_figure = undefined;

sort = function() {
	if x < O_GameField.x {place_direction = -1}
	figure_y_offset = 0;
	figure_x_offset = 0;
	for (i = 0; i < array_length(figures); i++) {
		if i == 6 or i == 12{
			figure_x_offset += 65*place_direction;
			figure_y_offset = 0;
		}
		figures[i].depth = array_length(figures) - i;
		figures[i].x = x + figure_x_offset;
		figures[i].y = y + figure_y_offset;
		figure_y_offset += 40*facing;
	}
}

add_figure = function(new_figure) {
	array_push(figures, new_figure);
	last_added_figure = new_figure
	if !new_figure.in_move {
		alarm[1] = 1;
	}
	else {
		alarm[1] = Settings.move_animation_length + 5;
	}
}

export = function() {
	figures_structs = []
	for (i = 0; i < array_length(figures); i++) {array_push(figures_structs, figures[i].export())}
	export_data = {
		ex_figures: figures,
		ex_figures_structs: figures_structs
	}
	return export_data
}

import = function(import_data) {
	new_figures = import_data.ex_figures;
	figures = []
	for (i = 0; i < array_length(new_figures); i++) {
		new_figure = instance_create_depth(x, y, 0, O_Figure);
		new_figure.import(import_data.ex_figures_structs[i])
		figures[i] = new_figure;
	}
	sort();
}