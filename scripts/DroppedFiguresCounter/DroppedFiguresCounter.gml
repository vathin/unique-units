// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function DroppedFiguresCounter(_owner) constructor{
	figures = [];
	owner = _owner;
	//last_added_figure = undefined;

	add_figure = function(_new_figure, _animation) {
		array_push(figures, _new_figure);
		sort(_animation);
		
	}
	
	sort = function(_use_animation = true) {
		figure_y_offset = 0;
		figure_x_offset = 0;
		for (i = 0; i < array_length(figures); i++) {
			if i == 6 or i == 12{
				figure_x_offset -= 58;
				figure_y_offset = 0;
			}
			if figures[i].owner == Game.Player1.player_id {facing = 1}
			else {facing = -1}
			new_figure_x = O_BoardDraw.drop_cord[0] + 30 + figure_x_offset;
			new_figure_y = O_BoardDraw.drop_cord[1] + 7 + 55*facing + figure_y_offset*facing;
			figure_y_offset += 32;
			if _use_animation {
				if (new_figure_x != figures[i].draw_x or new_figure_y != figures[i].draw_y) and
				!(figures[i].have_animation() and figures[i].get_last_animation_controller().x_to == new_figure_x 
				and figures[i].get_last_animation_controller().y_to == new_figure_y){
				//!(figures[i].have_animation() 
				//and (figures[i].get_last_animation_controller().x_to == new_figure_x
				//or figures[i].get_last_animation_controller().y_to == new_figure_y)){
					figure_animation = new MoveAnimationController();
					figure_animation.start_animation(figures[i].draw_x, figures[i].draw_y, new_figure_x, 
					new_figure_y, point_distance(figures[i].draw_x, figures[i].draw_y, new_figure_x, new_figure_y)/5, Settings.figure_scale/1.2);
					figures[i].add_animation(figure_animation);
				}
			}
			else {
				figures[i].draw_x = new_figure_x;
				figures[i].draw_y = new_figure_y;
			}
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
			figures[i] = new_figure;
		}
		sort(0);
	}
}