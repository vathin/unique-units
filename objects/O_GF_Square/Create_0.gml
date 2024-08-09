/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редактор
controlled_by = "";
global.selected_cell = "";
ready_for_move = false;
marked_for_move = false;
filled_figure = "";
var xcord;
var ycord;


create_figure = function(figure_behaviour) {
	if (!is_filled()){
		filled_figure = instance_create_depth(self.x, self.y, -1, O_Figure);
		filled_figure.set_behaviour(figure_behaviour);
		global.able_to_summon = false;
		O_SummonButton.go_to_standart_mode();
	}
}
clear = function() {
	filled_figure = "";
}
fill = function(new_figure) {
	filled = 1
	filled_figure = new_figure
	new_figure.x = self.x;
	new_figure.y = self.y;
}
is_filled = function() {
	return filled_figure != ""
}
