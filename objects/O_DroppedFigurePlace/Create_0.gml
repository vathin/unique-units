/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

size = 400;
figures = [];

sort = function() {
	figure_y_offset = 0;
	for (i = 0; i < array_length(figures); i++) {
		figures[i].x = x;
		figures[i].y = y + figure_y_offset;
		if array_length(figures) > 8{
			figure_y_offset += (size / array_length(figures))/2;
		}
		else {
			figure_y_offset += 30;
		}
	}
}

add_figure = function(new_figure) {
	array_push(figures, new_figure);
	alarm[0] = Settings.move_animation_lenght + 2;
	new_figure.start_move_animation(self, Settings.move_animation_lenght)
}