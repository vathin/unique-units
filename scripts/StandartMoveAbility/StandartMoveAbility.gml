// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function StandartMoveAbility(_from_x, _from_y, _to_x, _to_y, _figure_sprite=undefined) : FigureAbilityAction() constructor{
	from_x = _from_x;
	from_y = _from_y;
	to_x = _to_x;
	to_y = _to_y;
	figure_sprite = Behaviours.get_sprite(Game.field.get_cell(from_x, from_y).filled_figure.behaviour);
	figure_color = Game.field.get_cell(from_x, from_y).filled_figure.image
	Game.field.get_cell(_to_x, _to_y).set_draw_marks(0)
	from_move = Game.field.get_cell(_from_x, _from_y);
	to_move = Game.field.get_cell(_to_x, _to_y);
	draw_previous_cell = false;
	O_BoardDraw.unblock_end_button();
	
	
	
	execute = function() {
		using_figure = Game.field.get_cell(from_x, from_y).filled_figure;
		from_move.clear();
		to_move.fill(using_figure, true);
		figure_animation = new MoveAnimationController();
		figure_animation.start_animation(Game.field.get_cell_xy(from_move)[0], Game.field.get_cell_xy(from_move)[1],
		Game.field.get_cell_xy(to_move)[0], Game.field.get_cell_xy(to_move)[1], Settings.move_animation_length);
		using_figure.add_animation(figure_animation);
	}
	
	draw = function() {
		if to_x != undefined {
			draw_sprite_ext(figure_sprite, figure_color, Game.field.get_cell_xy(to_move)[0], Game.field.get_cell_xy(to_move)[1], 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
		if draw_previous_cell and from_move.filled_figure.previous_move_cell != undefined{
			var _draw_x = Game.field.get_cell_xy(Game.field.get_cell(from_move.filled_figure.previous_move_cell[0], from_move.filled_figure.previous_move_cell[1]))[0];
			var _draw_y = Game.field.get_cell_xy(Game.field.get_cell(from_move.filled_figure.previous_move_cell[0], from_move.filled_figure.previous_move_cell[1]))[1];
			draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
		}
	}
	
	set_new_target_coordinates = function(_new_x, _new_y) {
		if draw_previous_cell {
			from_move.filled_figure.previous_move_cell.marked = 0;
		}
		if to_x != undefined {to_move.set_draw_marks(1)}
		to_x = _new_x;
		to_y = _new_y;
		to_move = Game.field.get_cell(_new_x, _new_y);
		to_move.set_draw_marks(0)
		O_BoardDraw.unblock_end_button()
	}
	
	back = function() {
		if to_x != undefined {
			to_move.set_draw_marks(1)
			to_x = undefined;
			to_y = undefined;
			to_move = undefined;
			O_BoardDraw.block_end_button()
		}
		else {
			Game.game_loop_controller.quit_from_action();
		}
	}
	export = function() {
		export_data = {
			ex_action: StandartMoveAbility,
			ex_type: "move_ability",
			ex_to_x: to_x,
			ex_to_y: to_y,
			ex_from_x: from_x,
			ex_from_y: from_y,
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(_import_data) {
		to_x = _import_data.ex_to_x;
		to_y = _import_data.ex_to_y;
		from_x = _import_data.ex_from_x;
		from_y = _import_data.ex_from_y;
	}
}