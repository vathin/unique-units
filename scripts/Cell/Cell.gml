// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Cell() constructor{
	filled_figure_status = new FilledFigureStatus();
	standart_scale = 1;
	can_be_conquested = false;
	draw_mark = true;
	marked = false;
	filled_figure = undefined;
	xcord = 0;
	ycord = 0;
	
	set_coordinates = function(_new_xcord, _new_ycord) {
		xcord = _new_xcord;
		ycord = _new_ycord;
	}
	
	get_coordinates = function() {
		return [xcord, ycord]
	}
	
	set_draw_marks = function(_value) 
	{
		draw_mark = _value
	}
	
	is_marked = function() {
		return marked;
	}
	
	clear = function() 
	{
		filled_figure = undefined;
		filled_figure_status.start();
	}
	
	fill = function(_new_figure, animation) 
	{
		filled_figure = _new_figure;
		if !animation {
			filled_figure.draw_x = Game.field.get_cell_xy(self)[0];
			filled_figure.draw_y = Game.field.get_cell_xy(self)[1];
		}
	}
	
	is_filled = function() {
		return filled_figure != undefined
	}

	is_under_control = function(_player) {
		result = false
		neightbors = Game.field.cell_get_neightbors(self);
		for (i = 0; i < array_length(neightbors); i++) {
			if neightbors[i].is_filled() {
				if neightbors[i].filled_figure.owner = _player {
					result = 1;
				}
			}
		}
	
		return result;
	}
	
	update_filled_figure_state = function() {
			found_clear_cells = 0
			for (i = -1; i <= 1; i++) {
				for (m = -1; m <=1; m++) {
					cell = Game.field.get_cell(xcord + i, ycord +m);
					if cell != undefined{
						if cell != Game.field.get_cell(xcord, ycord) {
							if !cell.is_filled() {found_clear_cells++}
							else {
								if cell.filled_figure.state.is_dropped {found_clear_cells++}
							}
						}
					}
				}
			}
			if found_clear_cells == 0 {
				Game.game_loop_controller.figures_counter.add_figure_to_capture(filled_figure, self);
			}
	}

	export = function() {
		filled_figure_struct = undefined
		if is_filled() {filled_figure_struct = filled_figure.export()}
		export_data = {
			ex_can_be_conquested: can_be_conquested,
			ex_draw_mark: draw_mark,
			ex_filled_figure: filled_figure,
			ex_filled_figure_struct: filled_figure_struct,
			ex_xcord: xcord,
			ex_ycord: ycord
		}
		return export_data
	}

	import = function(_import_data) {
		clear();
		can_be_conquested = _import_data.ex_can_be_conquested;
		ex_draw_mark = _import_data.ex_draw_mark;
		if _import_data.ex_filled_figure_struct != undefined {
			_figure = new Figure();
			_figure.behaviour = _import_data.ex_filled_figure_struct.ex_behaviour;
			//Game.game_loop_controller.figures_counter.change_field_figures_amount(global.turn_owner, -1);
			_figure.import(_import_data.ex_filled_figure_struct);
			fill(_figure, 0);
		}
	}
}