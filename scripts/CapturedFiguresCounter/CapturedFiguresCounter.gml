
function CapturedFiguresCounter(_owner) constructor{
	figures = [];
	owner = _owner
	//last_added_figure = undefined;

	add_figure = function(new_figure, animation) {
		if !animation {
			new_figure.draw_x = O_BoardDraw.capture_cord[0]
			new_figure.draw_y = O_BoardDraw.capture_cord[1]
		}
		else {
			figure_animation = new MoveAnimationController();
			figure_animation.start_animation(new_figure.draw_x, new_figure.draw_y, O_BoardDraw.capture_cord[0],
			O_BoardDraw.capture_cord[1], Settings.move_animation_length*2);
			new_figure.add_animation(figure_animation)
		}
		array_push(figures, new_figure);
		figures_to_add = new_figure;
	}
	
	get_new_figure = function(player) {
		global.cell_click_callback = undefined;
		if Game.game_loop_controller.figures_counter.get_player_figures_amount(player) == 0 {
			FigureCapture();
			Game.game_loop_controller.change_turn_owner = 0;
		}
		else {
			load_data = Game.user_data.load(player);
			behaviour = array_pop(load_data.player_figures);
			Game.user_data.save(player, load_data);
			captured_figure = new Figure();
			captured_figure.owner = player;
			captured_figure.set_behaviour(behaviour);
			captured_figure.capture(0);
			add_figure(captured_figure, false);
		}
	}

	export = function() {
		figures_structs = [];
		for (i = 0; i < array_length(figures); i++) {array_push(figures_structs, figures[i].export())}
		export_data = {
			ex_figures_structs: figures_structs
		}
		return export_data
	}
	
	import = function(_import_data) {
		figures = [];
		for (i = 0; i < array_length(_import_data.ex_figures_structs); i++) {
			new_figure = new Figure();
			new_figure.import(_import_data.ex_figures_structs[i]);
			add_figure(new_figure, false)
		}
	}
}