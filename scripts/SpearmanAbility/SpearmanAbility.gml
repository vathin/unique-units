
function SpearmanAbility(using_figure=undefined, using_cell=undefined) : FigureAbilityAction() constructor{
	self.using_figure = using_figure;
	self.using_cell = using_cell;
	if using_figure != undefined {
		figure_sprite = Behaviours.get_sprite(using_figure.behaviour)
	}
	cell_for_move = undefined;
	target_figure = undefined;
	draw_previous_move_cell = false;
	
	execute = function() {
		//using_cell.filled_figure.start_move_animation(cell_for_move, Settings.ability_animation_length)
		using_figure = using_cell.filled_figure
		cell_for_move.fill(using_cell.filled_figure, 1);
		using_cell.clear();
		figure_animation = new MoveAnimationController();
		figure_animation.start_animation(Game.field.get_cell_xy(using_cell)[0], Game.field.get_cell_xy(using_cell)[1],
		Game.field.get_cell_xy(cell_for_move)[0], Game.field.get_cell_xy(cell_for_move)[1], Settings.move_animation_length*1.8);
		using_figure.add_animation(figure_animation);
	}
	
	set_target = function(useless_data, useless_data2) {
		cell_for_move = global.cell_click_callback;
		O_BoardDraw.unblock_end_button();
	}
	
	draw = function() {
		if global.cell_click_callback != using_cell{
			draw_sprite_ext(figure_sprite, using_cell.filled_figure.image, Game.field.get_cell_xy(cell_for_move)[0], 
			Game.field.get_cell_xy(cell_for_move)[1], 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
			if using_figure.previous_ability_cell != undefined and !using_figure.previous_ability_cell.is_filled(){
				var _draw_x = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_ability_cell[0], using_figure.previous_ability_cell[1]))[0];
				var _draw_y = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_ability_cell[0], using_figure.previous_ability_cell[1]))[1];
				draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
			}
		}
		if draw_previous_move_cell {
			var _draw_x = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_move_cell[0], using_figure.previous_move_cell[1]))[0];
			var _draw_y = Game.field.get_cell_xy(Game.field.get_cell(using_figure.previous_move_cell[0], using_figure.previous_move_cell[1]))[1];
			draw_sprite_ext(S_cycle_rule, 0, _draw_x, _draw_y, Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.7);
		}
		
	}
	
	check_ability_targets = function(a, b) {
		if Game.field.get_cell(using_cell.xcord + 1, using_cell.ycord) != undefined and 
		Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord) != undefined {
			if !Game.field.get_cell(using_cell.xcord + 1, using_cell.ycord).is_filled() and 
			!Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord).is_filled() {
				Game.field.get_cell(using_cell.xcord + 2, using_cell.ycord).marked = 1;
			}
		}
		if Game.field.get_cell(using_cell.xcord - 1, using_cell.ycord) != undefined and 
		Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord) != undefined {
			if !Game.field.get_cell(using_cell.xcord - 1, using_cell.ycord).is_filled() and 
			!Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord).is_filled() {
				Game.field.get_cell(using_cell.xcord - 2, using_cell.ycord).marked = 1;
			}
		}	
		if Game.field.get_cell(using_cell.xcord, using_cell.ycord + 1) != undefined and 
		Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2) != undefined {
			if !Game.field.get_cell(using_cell.xcord, using_cell.ycord + 1).is_filled() and 
			!Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2).is_filled() {
				Game.field.get_cell(using_cell.xcord, using_cell.ycord + 2).marked = 1;
			}
		}
		if Game.field.get_cell(using_cell.xcord, using_cell.ycord - 1) != undefined and 
		Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2) != undefined {
			if !Game.field.get_cell(using_cell.xcord, using_cell.ycord - 1).is_filled() and 
			!Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2).is_filled() {
				Game.field.get_cell(using_cell.xcord, using_cell.ycord - 2).marked = 1;
			}
		}
		cl = using_cell.filled_figure.previous_move_cell;
		if using_cell.filled_figure.previous_move_cell != undefined and Game.field.get_cell(cl[0], cl[1]).is_marked {
			draw_previous_move_cell = 1;
			using_cell.filled_figure.previous_move_cell.marked = 0;
		}
	}
	
	
	back = function() {
		if global.cell_click_callback != global.selected_cell {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback = using_cell;
			O_BoardDraw.block_end_button();
		}
		else {
			Game.game_loop_controller.quit_from_action()
		}
	}
	
	export = function() {
		export_data = {
			ex_action : SpearmanAbility,
			ex_type : "act_ability",
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_cell_for_move: [cell_for_move.xcord, cell_for_move.ycord],
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	
	import = function(import_data) {
		//using_figure = import_data.ex_using_figure;
		using_cell = Game.field.get_cell(import_data.ex_using_cell[0], import_data.ex_using_cell[1]);
		cell_for_move = Game.field.get_cell(import_data.ex_cell_for_move[0], import_data.ex_cell_for_move[1]);
		using_figure = using_cell.filled_figure;
	}
}