// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorAbility(_using_figure=undefined, _using_cell=undefined) : FigureAbilityAction() constructor{
	using_figure = _using_figure;
	using_cell = _using_cell;
	target_figure = undefined;
	target_cell = undefined;
	
	execute = function() {
		using_figure.drop();
		target_figure.drop();
	}
	
	draw = function() {
		if target_figure != undefined {
			//draw_sprite_ext(S_Back_Action_Target, 0, target_figure.x, target_figure.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	
	set_target = function(_new_target, _new_cell) {
		target_figure = _new_target;
		target_cell = _new_cell
		O_BoardDraw.unblock_end_button();
	}
	
	check_ability_targets = function(a, b) {
		found_cell = false;
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = Game.field.get_cell(using_cell.xcord + i, using_cell.ycord + m)
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
	
	
	back = function() {
		if target_figure != undefined {
			global.cell_click_callback.set_draw_marks(1)
			target_figure = undefined;
			O_BoardDraw.block_end_button();
		}
		else {
			Game.game_loop_controller.quit_from_action();
		}
	}
	
	export = function() {
		export_data = {
			action: WarriorAbility,
			type: "act_ability",
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_target_cell: [target_cell.xcord, target_cell.ycord],
			ex_using_figure: undefined,
			ex_target_figure: undefined,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(_import_data) {
		target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
		using_cell = Game.field.get_cell(_import_data.ex_using_cell[0], _import_data.ex_using_cell[1]);
		target_figure = target_cell.filled_figure;
		using_figure = using_cell.filled_figure;
	}
}