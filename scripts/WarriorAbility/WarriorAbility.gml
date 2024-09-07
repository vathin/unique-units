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
	
	draw = function() {
		if target_figure != undefined {
			draw_sprite_ext(S_Back_Action_Target, 0, target_figure.x, target_figure.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	
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
	
	back = function() {
		if target_figure != undefined {
			global.cell_click_callback.set_draw_marks(1)
			target_figure = undefined;
			O_EndTurn.block()
		}
		else {
			if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
			O_GameField.clear_all_marks();
			sel_cell = global.selected_cell;
			global.cell_click_callback = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_SummonButton.go_away();
			global.using_ability = 0;
			O_GameLoopController.action = undefined;
		}
	}
	
	export = function() {
		export_data = {
			ex_using_figure: using_figure,
			ex_target_figure: target_figure,
			action: WarriorAbility
		}
		return export_data
	}
	import = function(import_data) {
		target_figure = import_data.ex_target_figure;
		using_figure = import_data.ex_using_figure;
	}
}