/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

figure_owner = undefined;
size = 400;
figures = [];
facing = 1;

sort = function() {
	figure_y_offset = 0;
	figure_x_offset = 0;
	for (i = 0; i < array_length(figures); i++) {
		if i == 6 or i == 12 or i == 18{
			figure_x_offset -= 65;
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
	alarm[0] = Settings.move_animation_length + 2;
	new_figure.start_move_animation(self, Settings.move_animation_length)
}