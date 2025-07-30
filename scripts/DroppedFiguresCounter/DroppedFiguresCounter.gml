// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function DroppedFiguresCounter(_owner) constructor{
	figures = [];
	owner = _owner;
	//last_added_figure = undefined;

	add_figure = function(new_figure, animation) {
		array_push(figures, new_figure);
		figures_to_add = new_figure;
		if animation {
			var from_x = new_figure.draw_x;
			var from_y = new_figure.draw_y;
			if new_figure.have_animation() {
				from_x = array_get(new_figure.animation_queue, array_length(new_figure.animation_queue)-1).x_to;
				from_y = array_get(new_figure.animation_queue, array_length(new_figure.animation_queue)-1).y_to;
			}
			figure_animation = new MoveAnimationController();
			figure_animation.start_animation(from_x, from_y, O_BoardDraw.drop_cord[0], 
			O_BoardDraw.drop_cord[1], Settings.move_animation_length*2);
			new_figure.add_animation(figure_animation);
		}
		else {
			new_figure.draw_x = O_BoardDraw.drop_cord[0]
			new_figure.draw_y = O_BoardDraw.drop_cord[1]
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
		figures = []
		for (i = 0; i < array_length(_import_data.ex_figures_structs); i++) {
			new_figure = new Figure();
			new_figure.import(_import_data.ex_figures_structs[i]);
			add_figure(new_figure, false);
		}
	}
}