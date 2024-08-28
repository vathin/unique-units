/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
figure_owner = undefined;
size = 400;
figures = [];
facing = 1;

sort = function() {
	figure_y_offset = 0;
	for (i = 0; i < array_length(figures); i++) {
		figures[i].x = x;
		figures[i].y = y + figure_y_offset;
		if array_length(figures) > 8{
			figure_y_offset += (size / array_length(figures))/2*facing;
		}
		else {
			figure_y_offset += 30*facing;
		}
	}
}

add_figure = function(new_figure) {
	array_push(figures, new_figure);
	alarm[0] = Settings.move_animation_lenght + 2;
	new_figure.start_move_animation(self, Settings.move_animation_lenght)
}

get_new_figure = function(player) {
	global.cell_click_callback = undefined;
	if global.current_player_figures = 0 {
		instance_create_depth(0, 0, 0, O_CaptureFigureController);
	}
	else {
		load_data = O_App.data.load(player);
		behaviour = array_pop(load_data.player_figures);
		O_App.data.save(player, load_data);
		if player = "player1" {captured_figure = instance_create_depth(1142, 930, 2, O_Figure)}
		else {captured_figure = instance_create_depth(480, 200, 2, O_Figure)}
		captured_figure.set_behaviour(behaviour);
		captured_figure.capture(0);
	}
}