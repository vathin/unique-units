/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редактор
global.selected_cell = ""
ready_for_move = false;
marked_for_move = false;

var xcord;
var ycord;
filled = false


create_figure = function(figure_type) {
	if (filled = false){
		filled_figure = instance_create_depth(self.x, self.y, -1, figure_type);
		filled = true;
		global.able_to_summon = false;
		O_SummonButton.go_to_standart_mode();
	}
}
clear = function() {
	filled_figure = "";
	filled = false;
}
