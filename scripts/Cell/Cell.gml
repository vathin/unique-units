// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Cell() constructor{
	standart_scale = 1;
	can_be_conquested = false;
	draw_mark = true;
	marked = false;
	filled_figure = undefined;
	xcord = 0;
	ycord = 0;
	
	set_coordinates = function(new_xcord, new_ycord) {
		xcord = new_xcord;
		ycord = new_ycord;
	}
	
	get_coordinates = function() {
		return [xcord, ycord]
	}
	
	set_draw_marks = function(value) 
	{
		draw_mark = value
	}
	
	is_marked = function() {
		if marked return true
		else return false
	}
	
	clear = function() 
	{
		filled_figure = undefined;
	}
	
	fill = function(new_figure) 
	{
		filled_figure = new_figure
	}
	
	is_filled = function() {
		return filled_figure != undefined
	}

	is_under_control = function(player) {
		result = false
		neightbors = Game.field.cell_get_neightbors(self);
		for (i = 0; i < array_length(neightbors); i++) {
			if neightbors[i].is_filled() {
				if neightbors[i].filled_figure.owner = player {
					result = 1
				}
			}
		}
	
		return result;
	}
	
	update_filled_figure_state = function() {
		filled_figure.check_cycle_rule();
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
			ex_filled_figure_struct: filled_figure_struct
		}
		return export_data
	}

	import = function(import_data) {
		clear();
		can_be_conquested = import_data.ex_can_be_conquested;
		ex_draw_mark = import_data.ex_draw_mark;
		if import_data.ex_filled_figure_struct != undefined {
			//create_figure(import_data.ex_filled_figure_struct.ex_behaviour);
			filled_figure = new Figure()
			filled_figure.behaviour = import_data.ex_filled_figure_struct.ex_behaviour
			Game.game_loop_controller.figures_counter.change_field_figures_amount(global.turn_owner, -1);
			filled_figure.import(import_data.ex_filled_figure_struct);
		}
	}
}