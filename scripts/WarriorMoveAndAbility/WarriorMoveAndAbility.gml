// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorMoveAndAbility(_from_x, _from_y, _to_x, _to_y, _figure_sprite=undefined) : FigureAbilityAction() constructor{
	from_x = _from_x;
	from_y = _from_y;
	to_x = _to_x;
	to_y = _to_y;
	figure_sprite = S_Warrior;
	using_cell = Game.field.get_cell(_from_x, _from_y);
	target_cell = undefined;
	using_figure = using_cell.filled_figure;
	using_ability = false;
	if using_figure.owner == O_Server._id {
		Game.figure_action_controller = new FigureActionController();
		Game.figure_action_controller.move_and_ability = 1;
		Game.figure_action_controller.figure_can_move = 0;
	}
	Game.move_input_controller = undefined
	Game.game_loop_controller.state = STATE_LIST.figure_action
	Game.field.check_clear_move_cells(_from_x, _from_y);
	Game.field.get_cell(_from_x, _from_y).set_draw_marks(0);
	Game.field.get_cell(_to_x, _to_y).set_draw_marks(0);
	O_BoardDraw.unblock_end_button();
	previous_move_cell = undefined;
	draw_previous_cell = 0;

	
	execute = function() {
		//global.moving_figure = 1;
		to_move = Game.field.get_cell(to_x, to_y);
		from_move = Game.field.get_cell(from_x, from_y)
		figure_animation = new MoveAnimationController();
		figure_animation.start_animation(Game.field.get_cell_xy(from_move)[0], Game.field.get_cell_xy(from_move)[1],
		Game.field.get_cell_xy(to_move)[0], Game.field.get_cell_xy(to_move)[1], Settings.move_animation_length);
		using_figure.add_animation(figure_animation);
		
		to_move.fill(using_figure, 1);
		from_move.clear();
		if using_ability {
			hit_animation = new HitAnimationController();
			hit_animation.start_animation(Game.field.get_cell_xy(to_move)[0], Game.field.get_cell_xy(to_move)[1],
			Game.field.get_cell_xy(to_move)[0], Game.field.get_cell_xy(to_move)[1], Settings.hit_animation_length);
			using_figure.add_animation(hit_animation)
			using_figure.drop()
			
			target_animation = new StandAnimationController();
			target_animation.start_animation(Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1], 
			Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1],
			Settings.move_animation_length+Settings.hit_animation_length);
			target_cell.filled_figure.add_animation(target_animation)
			target_cell.filled_figure.drop()
		}
		else {
			Game.field.add_movement(from_move, to_move, using_figure.figure_id)
		}
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(figure_sprite, using_figure.image, Game.field.get_cell_xy(Game.field.get_cell(to_x, to_y))[0],
			Game.field.get_cell_xy(Game.field.get_cell(to_x, to_y))[1], 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			if target_cell != undefined {
				draw_sprite_ext(S_Back_Action_Target, 0, Game.field.get_cell_xy(target_cell)[0],
				Game.field.get_cell_xy(target_cell)[1], Settings.figure_scale, Settings.figure_scale, 0, c_white, 1);
			}
		}
		if draw_previous_cell and previous_move_cell != undefined and target_cell == undefined{
			var _draw_x = Game.field.get_cell_xy(previous_move_cell)[0];
			var _draw_y = Game.field.get_cell_xy(previous_move_cell)[1];
			draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
		}
	}
	
	check_previous_cell = function() {
		var _previous_cell = Game.field.check_movement_array(using_figure.figure_id)
		if _previous_cell != undefined and _previous_cell.is_marked() {
			draw_previous_cell = 1;
			_previous_cell.marked = 0;
			previous_move_cell = _previous_cell;
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
		check_previous_cell();
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
		check_previous_cell()
		return(found_cells)
	}
	
	if using_figure.owner == O_Server._id {
		if !check_ability_targets(0, 0) {
			Game.figure_action_controller.figure_have_ability = 0
		}
		else {
			Game.figure_action_controller.figure_have_ability = 1
		}
	}
	
	
	back = function() {
		if using_ability {
			if target_cell!= undefined{
				target_cell.set_draw_marks(1);
				target_cell = undefined;
				O_BoardDraw.block_end_button();
			}
			else {
				Game.figure_action_controller = new FigureActionController();
				Game.figure_action_controller.revert_move_and_ability();
				Game.figure_action_controller.move_and_ability = 1;
				Game.figure_action_controller.figure_can_move = 0;
				using_ability = 0;
				if target_cell != undefined {target_cell.set_draw_marks(1)}
				target_cell = undefined;
				O_BoardDraw.unblock_end_button();
				global.cell_click_callback = Game.field.get_cell(to_x, to_y);
				Game.field.check_clear_move_cells(from_x, from_y);
				Game.field.get_cell(to_x, to_y).set_draw_marks(0);
				move_controller = new MoveInputController();
				move_controller = undefined;
				Game.game_loop_controller.state = STATE_LIST.figure_action;
				check_previous_cell();
			}
		}
		else {
			if to_x != undefined {
				Game.field.get_cell(to_x, to_y).set_draw_marks(1)
				Game.figure_action_controller.figure_have_ability = 0;
				to_x = undefined;
				to_y = undefined;
				O_BoardDraw.block_end_button();
			}
			else {
				Game.figure_action_controller.destroy_self();
				Game.game_loop_controller.quit_from_action();
			}
		}
	}
	
	export = function() {
		if (target_cell != undefined) {ex_target_cell_cord = [target_cell.xcord, target_cell.ycord]}
		else {ex_target_cell_cord = undefined}
		export_data = {
			ex_action: WarriorMoveAndAbility,
			ex_type: "move_ability",
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
		if _import_data.ex_target_cell != undefined {
			target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
		}
		to_x = _import_data.ex_to_x;
		to_y = _import_data.ex_to_y;
		from_x = _import_data.ex_from_x;
		from_y =  _import_data.ex_from_y;
		using_cell = Game.field.get_cell(from_x, from_y);
		using_figure = using_cell.filled_figure;
	}
}