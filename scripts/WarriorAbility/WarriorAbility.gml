// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	self.target_figure = undefined;
	
	execute = function() {
		using_figure.drop();
		target_figure.drop();
	}
	
	draw = function() {}
	
	set_target = function(new_target, new_cell) {
		target_figure = new_target;
	}
	
	check_ability_targets = function(a, b) {
		found_cell = false;
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = O_GameField.get_cell(using_cell.xcord + i, using_cell.ycord + m)
				if cell != undefined {
					if cell.is_filled() and cell.filled_figure != using_cell.filled_figure and !cell.filled_figure.state.is_conquesting {
						cell.marked = 1;
						found_cell = 1;
					}
				}
			}
		}
		return found_cell;
	}
	
	cancel = function() {}
}