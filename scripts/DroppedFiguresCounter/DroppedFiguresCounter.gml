// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function DroppedFiguresCounter(_owner) constructor{
	figures = [];
	owner = _owner;
	//last_added_figure = undefined;

	add_figure = function(new_figure) {
		array_push(figures, new_figure);
		figures_to_add = new_figure
	}

	export = function() {
		figures_structs = []
		for (i = 0; i < array_length(figures); i++) {array_push(figures_structs, figures[i].export())}
		export_data = {
			ex_figures: figures,
			ex_figures_structs: figures_structs
		}
		return export_data
	}

	import = function(import_data) {
		new_figures = import_data.ex_figures;
		figures = []
		for (i = 0; i < array_length(new_figures); i++) {
			new_figure = new Figure()
			new_figure.import(import_data.ex_figures_structs[i])
			figures[i] = new_figure;
		}
	}
}