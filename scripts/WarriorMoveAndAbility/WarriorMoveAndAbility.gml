// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorMoveAndAbility(_from_x, _from_y, _to_x, _to_y, _figure_sprite=undefined) : FigureAbilityAction() constructor{
	from_x = _from_x;
	from_y = _from_y;
	to_x = _to_x;
	to_y = _to_y;
	figure_sprite = _figure_sprite;
	using_cell = Game.field.get_cell(_from_x, _from_y);
	target_cell = undefined;
	using_figure = using_cell.filled_figure;
	using_ability = false;
	Game.figure_action_controller = new FigureActionController();
	Game.move_input_controller = undefined
	Game.game_loop_controller.state = STATE_LIST.figure_action
	Game.figure_action_controller.move_and_ability = 1;
	Game.figure_action_controller.figure_can_move = 0;
	Game.field.check_clear_move_cells(_from_x, _from_y);
	Game.field.get_cell(_from_x, _from_y).set_draw_marks(0);
	Game.field.get_cell(_to_x, _to_y).set_draw_marks(0);
	O_BoardDraw.unblock_end_button();
	
	change_move_button_to_summon = function() {
		//O_SummonButton.x = figure_controller.move_button.x;
		//O_SummonButton.y = figure_controller.move_button.y;
		//O_SummonButton.change_sprite(S_Back, 0.128);
		//O_SummonButton.back = 1;
		//figure_controller.move_button.y = -450; 
	}
	
	//change_move_button_to_summon();
	
	execute = function() {
		global.moving_figure = 1;
		Game.field.get_cell(to_x, to_y).fill(using_figure, 1);
		Game.field.get_cell(from_x, from_y).clear();
		if using_ability {
			//using_figure.start_move_animation(Game.field.get_cell(to_x, to_y), Settings.move_animation_length)
			using_figure.state.is_active = 0;
			using_figure.state.is_dropped = 1;
			using_figure.drop()
			target_cell.filled_figure.drop()
		}
	}
	
	draw = function() {
		if to_x != undefined {
			//draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[to_y][to_x].x, O_GameField.field[to_y][to_x].y, 
			//Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			if target_cell != undefined {
				//draw_sprite_ext(S_Back_Action_Target, 0, target_cell.x, target_cell.y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			}
		}
		if global.moving_figure and draw_previous_cell{
			//draw_sprite_ext(S_cycle_rule, 0, using_figure.previous_move_cell.x, using_figure.previous_move_cell.y,
			//Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			if using_figure.previous_move_cell.marked {using_figure.previous_move_cell.marked = 0}
		}
	}
	
	set_new_target_coordinates = function(_new_x, _new_y) {
		if to_x != undefined {Game.field.get_cell(to_x, to_y).set_draw_marks(1);}
		to_x = _new_x;
		to_y = _new_y;
		Game.field.get_cell(_new_x, _new_y).set_draw_marks(0);
		if !check_ability_targets(0, 0) {Game.figure_action_controller.figure_have_ability = 0}
		else {Game.figure_action_controller.figure_have_ability = 1}
		O_BoardDraw.unblock_end_button()
		//Game.game_loop_controller.state = STATE_LIST.figure_action
	}
	
	set_target = function(_target_figure, _target_cell) {
		if target_cell != undefined {target_cell.set_draw_marks(1)}
		target_cell = _target_cell;
		target_cell.set_draw_marks(0);
		O_BoardDraw.unblock_end_button();
	}
	
	check_ability_targets = function(check, a) {
		found_cells = false;
		for (i = -1; i <= 1; i++) {
			for (m = -1; m <= 1; m++) {
				cell = Game.field.get_cell(to_x + i, to_y + m);
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
	
	if !check_ability_targets(0, 0) {
		Game.figure_action_controller.figure_have_ability = 0
		}
	else {
		Game.figure_action_controller.figure_have_ability = 1
		}
	
	back = function() {
		if using_ability {
			if target_cell!= undefined{
				target_cell.set_draw_marks(1);
				target_cell = undefined;
				O_BoardDraw.block_end_button();
			}
			else {
				Game.figure_action_controller = new FigureActionController()
				Game.figure_action_controller.revert_move_and_ability();
				Game.figure_action_controller.move_and_ability = 1;
				Game.figure_action_controller.figure_can_move = 0;
				using_ability = 0;
				if target_cell != undefined {target_cell.set_draw_marks(1)}
				target_cell = undefined;
				global.cell_click_callback = Game.field.get_cell(to_x, to_y);
				Game.field.check_clear_move_cells(from_x, from_y);
				change_move_button_to_summon();
				global.using_ability = 0;
				global.moving_figure = 1;
				Game.game_loop_controller.state = STATE_LIST.figure_move
				Game.field.get_cell(to_x, to_y).set_draw_marks(0);
			}
		}
		else {
			if to_x != undefined {
				Game.field.get_cell(to_x, to_y).set_draw_marks(1)
				to_x = undefined;
				to_y = undefined;
				Game.figure_action_controller.figure_have_ability = 1;
			}
			else {
				Game.figure_action_controller = undefined
				Game.game_loop_controller.quit_from_action();
			}
		}
	}
	
	export = function() {
		if (target_cell != undefined) {ex_target_cell_cord = [target_cell.xcord, target_cell.ycord]}
		else {ex_target_cell_cord = [undefined, undefined]}
		export_data = {
			action: WarriorMoveAndAbility,
			type: "move_action",
			ex_from_x: from_x,
			ex_from_y: from_y,
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_using_ability: using_ability,
			ex_target_cell: ex_target_cell_cord,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(_import_data) {
		using_ability = _import_data.ex_using_ability;
		target_cell = Game.field.get_cell(_import_data.target_cell[0], _import_data.target_cell[1]);
	}
}