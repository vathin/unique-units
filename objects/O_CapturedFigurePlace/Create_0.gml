/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
event_inherited()

get_new_figure = function(player) {
	global.cell_click_callback = undefined;
	if O_Figures_counter.get_player_figures_amount(player) = 0 {
		instance_create_depth(0, 0, 0, O_CaptureFigureController);
	}
	else {
		load_data = O_App.data.load(player);
		behaviour = array_pop(load_data.player_figures);
		O_App.data.save(player, load_data);
		if player = "player1" {captured_figure = instance_create_depth(1142, 930, 2, O_Figure)}
		else {captured_figure = instance_create_depth(480, 200, -1, O_Figure)}
		captured_figure.set_behaviour(behaviour);
		captured_figure.capture(0);
	}
}