// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorMoveAndAbility(from_x, from_y, to_x, to_y, figure_sprite) : FigureAbilityAction() constructor{
	self.from_x = from_x;
	self.from_y = from_y;
	self.to_x = to_x;
	self.to_y = to_y;
	self.figure_sprite = figure_sprite;
	using_cell = O_GameField.get_cell(from_x, from_y);
	target_cell = undefined;
	using_figure = using_cell.filled_figure;
	using_ability = false;
	figure_controller = instance_create_depth(0, 0, 0, O_FigureActionController);
	figure_controller.move_and_ability = 1;
	O_GameField.check_clear_move_cells(from_x, from_y)
	O_GameField.get_cell(from_x, from_y).set_draw_marks(0);
	O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
	
	change_move_button_to_summon = function() {
		O_SummonButton.x = figure_controller.move_button.x;
		O_SummonButton.y = figure_controller.move_button.y;
		O_SummonButton.change_sprite(S_Back, 0.128);
		O_SummonButton.back = 1;
		figure_controller.move_button.y = -450; 
	}
	
	change_move_button_to_summon();
	
	execute = function() {
		global.moving_figure = 1;
		O_GameField.get_cell(to_x, to_y).fill(using_figure, 1);
		O_GameField.get_cell(from_x, from_y).clear();
		O_GameLoopController.alarm[0] = 35;
		if using_ability {
			using_figure.start_move_animation(O_GameField.get_cell(to_x, to_y), Settings.move_animation_length)
			using_figure.state.is_active = 0;
			using_figure.state.is_dropped = 1;
			using_figure.alarm[0] = Settings.move_animation_length + 3;
			target_cell.filled_figure.alarm[0] = Settings.ability_animation_length + 1;
		}
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			if target_cell != undefined {
				draw_sprite_ext(S_Back_Action_Target, 0, target_cell.x, target_cell.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			}
		}
		if global.moving_figure and draw_previous_cell{
			draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_move_cell.x, using_figure.previous_move_cell.y,
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			if using_figure.previous_move_cell.marked {using_figure.previous_move_cell.marked = 0}
		}
	}
	
	set_new_target_coordinates = function(new_x, new_y) {
		if to_x != undefined {O_GameField.get_cell(to_x, to_y).set_draw_marks(1);}
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0);
		if !check_ability_targets(0, 0) {figure_controller.ability_button.block()}
		else {figure_controller.ability_button.unblock()}
		O_EndTurn.unblock();
	}
	
	set_target = function(target_figure, target_cell) {
		O_SummonButton.change_sprite(S_Back, 0.128);
		O_SummonButton.back = 1;
		if self.target_cell != undefined {self.target_cell.set_draw_marks(1)}
		self.target_cell = target_cell;
		self.target_cell.set_draw_marks(0)
		O_SummonButton.set_back();
		O_EndTurn.unblock()
	}
	
	check_ability_targets = function(check, a) {
		found_cells = false;
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = O_GameField.get_cell(to_x + i, to_y + m);
				if cell != undefined {
					if cell.is_filled() and cell != using_cell and !cell.filled_figure.state.is_conquesting{
						if check {cell.marked = 1}
						found_cells = 1;
					}
				}
			}
		}
		return(found_cells)
	}
	
	if !check_ability_targets(0, 0) {figure_controller.ability_button.block()}
	else {figure_controller.ability_button.unblock()}
	
	back = function() {
		if using_ability {
			if target_cell!= undefined{
				target_cell.set_draw_marks(1);
				target_cell = undefined;
				O_EndTurn.block()
			}
			else {
				figure_controller = instance_create_depth(0, 0, 0, O_FigureActionController);
				figure_controller.revert_move_and_ability();
				figure_controller.move_and_ability = 1;
				figure_controller.move_button.block();
				using_ability = 0;
				if target_cell != undefined {target_cell.set_draw_marks(1)}
				target_cell = undefined;
				global.cell_click_callback = O_GameField.get_cell(to_x, to_y);
				O_GameField.check_clear_move_cells(from_x, from_y);
				change_move_button_to_summon();
				global.using_ability = 0;
				global.moving_figure = 1;
				O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
			}
		}
		else {
			if to_x != undefined {
				O_GameField.field[to_y][to_x].set_draw_marks(1)
				to_x = undefined;
				to_y = undefined;
				O_EndTurn.block()
				figure_controller.ability_button.block();
			}
			else {
				if instance_exists(figure_controller) {
					figure_controller.clear_buttons();
					instance_destroy(figure_controller)
					}
				O_GameLoopController.quit_from_action();
			}
		}
	}
	
	export = function() {
		export_data = {
			action: WarriorMoveAndAbility,
			type: "move_action",
			ex_from_x: from_x,
			ex_from_y: from_y,
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_using_ability: using_ability,
			ex_target_cell: target_cell,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(import_data) {
		using_ability = import_data.ex_using_ability;
		target_cell = import_data.target_cell;
	}
}