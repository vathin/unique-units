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
	figure_controller = undefined;
	figure_controller = instance_create_depth(0, 0, 0, O_FigureActionController);
	figure_controller.move_and_ability = 1;
	O_SummonButton.x = figure_controller.move_button.x;
	O_SummonButton.y = figure_controller.move_button.y;
	O_SummonButton.change_sprite(S_Back, 0.128);
	O_SummonButton.back = 1;
	figure_controller.move_button.y = -450;
	O_GameField.check_clear_move_cells(from_x, from_y)
	O_GameField.get_cell(from_x, from_y).set_draw_marks(0);
	O_GameField.get_cell(to_x, to_y).set_draw_marks(0)
	
	
	
	execute = function() {
		global.moving_figure = 1;
		O_GameField.field[to_y][to_x].fill(global.selected_cell.filled_figure, 1);
		O_GameField.field[from_y][from_x].clear();
		O_GameLoopController.alarm[0] = 35;
		if using_ability {
			using_figure.start_move_animation(O_GameField.get_cell(to_x, to_y), Settings.move_animation_length)
			using_figure.alarm[0] = Settings.move_animation_length + 3;
			target_cell.filled_figure.alarm[0] = Settings.ability_animation_length + 1;
		}
	}
	
	draw = function() {
		draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		if target_cell != undefined {
			draw_sprite_ext(S_Back_Action_Target, 0, target_cell.x, target_cell.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
		}
	}
	
	set_new_target_coordinates = function(new_x, new_y) {
		O_GameField.get_cell(to_x, to_y).set_draw_marks(1);
		self.to_x = new_x;
		self.to_y = new_y;
		O_GameField.get_cell(new_x, new_y).set_draw_marks(0);
		if !check_ability_targets(0, 0) {figure_controller.ability_button.block()}
		else {figure_controller.ability_button.unblock()}
	}
	
	set_target = function(target_figure, target_cell) {
		O_SummonButton.change_sprite(S_Back, 0.128);
		O_SummonButton.back = 1;
		if self.target_cell != undefined {self.target_cell.set_draw_marks(1)}
		self.target_cell = target_cell;
		self.target_cell.set_draw_marks(0)
		O_SummonButton.set_back();
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
	
	cancel = function() {
		if (figure_controller != undefined) {
			figure_controller.clear_buttons();
			instance_destroy(figure_controller);
			}
	}
	
	back = function() {
		if using_ability {
			figure_controller = instance_create_depth(0, 0, 0, O_FigureActionController);
			figure_controller.revert_move_and_ability();
			figure_controller.move_and_ability = 1;
			figure_controller.move_button.block();
			using_ability = 0;
			if target_cell != undefined {target_cell.set_draw_marks(1)}
			target_cell = undefined;
			global.cell_click_callback = O_GameField.get_cell(from_x, from_y);
			O_GameField.check_clear_move_cells(from_x, from_y);
			O_SummonButton.x = figure_controller.move_button.x;
			O_SummonButton.y = figure_controller.move_button.y;
			O_SummonButton.back = 1;
			figure_controller.move_button.y = -450;
			O_SummonButton.change_sprite(S_Back, 0.128);
			global.using_ability = 0;
			global.moving_figure = 1;
			O_GameField.get_cell(to_x, to_y).set_draw_marks(0);
		}
		else {
			cancel();
			if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
			O_GameField.clear_all_marks();
			sel_cell = global.selected_cell;
			instance_create_depth(0, 0, 0, O_FigureActionController);
			O_SummonButton.go_away();
			global.cell_click_callback = global.selected_cell;
			O_GameLoopController.action = undefined;
		}
	}
}