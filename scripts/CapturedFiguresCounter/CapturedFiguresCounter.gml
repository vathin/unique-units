
function CapturedFiguresCounter(_owner) constructor{
	figures = [];
	owner = _owner
	//last_added_figure = undefined;

	add_figure = function(new_figure) {
		array_push(figures, new_figure);
		figures_to_add = new_figure;
	}
	
	get_new_figure = function(player) {
		global.cell_click_callback = undefined;
		if Game.game_loop_controller.figures_counter.get_player_figures_amount(player) == 0 {
			FigureCapture();
		}
		else {
			load_data = Game.user_data.load(player);
			behaviour = array_pop(load_data.player_figures);
			Game.user_data.save(player, load_data);
			captured_figure = new Figure();
			captured_figure.set_behaviour(behaviour);
			captured_figure.capture(0);
			add_figure(captured_figure);
		}
	}

	export = function() {
		figures_structs = []
		for (i = 0; i < array_length(figures); i++) {array_push(figures_structs, figures[i].export())}
		export_data = {
			ex_figures_structs: figures_structs
		}
		return export_data
	}

	import = function(_import_data) {
		//new_figures = _import_data.ex_figures;
		figures = []
		for (i = 0; i < array_length(_import_data.ex_figures_structs); i++) {
			new_figure = new Figure()
			new_figure.import(_import_data.ex_figures_structs[i])
			array_push(figures, new_figure);
		}
	}
}