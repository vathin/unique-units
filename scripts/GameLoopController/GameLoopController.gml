// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameLoopController() constructor{
	global.turn_owner = "player1";
	player1_captured = 0;
	player2_captured = 0;
	action = undefined;
	turn_end = false;
	can_cancel = false;
	displaying_card = false;
	global.input = true;
	turn_timer = new Timer()

	turn_timer.start_count(Settings.turn_time)

	set_can_cancel = function(value) {
		can_cancel = value;
	}

	startInput = function() {
		O_SummonButton.unblock()
	}

	end_move = function() {
		alarm[0] = 5;
		global.input = 0;
		//if global.moving_figure {
		//	global.selected_cell.filled_figure.start_move_animation(global.cell_click_callback, Settings.move_animation_length)
		//}
		execute_action();
		turn_timer.reset();
		global.turn_owner = get_opponent(global.turn_owner);
		clear_all();
		Maps_list.check_if_any_cell_conquested(global.map);
		Game.Field.check_every_figure();
		O_Figures_counter.update_turn();
		//if check_win_conditions() != undefined {Game.match_controller.alarm[0] = 60}
	}

	set_action = function(new_action) {
		action = new_action;
	}

	have_action = function() {
		return action != undefined
	}

	get_opponent = function(player) {
		if player = "player1" {
			return "player2"
		}
		else {
			return "player1"
		}
	}

	choose_cell_for_summon = function() {
		if global.selected_cell == undefined {
			global.cell_click_callback.marked = 0;
			global.selected_cell = global.cell_click_callback;
			O_SummonInputController.start_summon(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		}
		else {
			global.selected_cell.marked = 1;
			global.selected_cell = global.cell_click_callback;
			global.cell_click_callback.marked = 0;
			action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		}
	}
	cancel_action = function() {
			clear_all();
			O_Figures_counter.update_turn();
	}

	quit_from_action = function() {
		if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
		if instance_exists(O_MoveInputController) {instance_destroy(O_MoveInputController)}
		Game.Field.clear_all_marks(); 
		O_SummonButton.go_away();
		global.moving_figure = 0;
		global.using_ability = 1;
		global.cell_click_callback = global.selected_cell;
		instance_create_depth(0, 0, 0, O_FigureActionController);
		action = undefined;
	}

	execute_action = function() {
		if have_action() {
			Game.game_data.save_action(action.export())
			action.execute();
		}
	}

	clean_controllers = function() {
		if instance_exists(O_AbilityInputController) {instance_destroy(O_AbilityInputController)}
		if instance_exists(O_MoveInputController) {instance_destroy(O_MoveInputController)}
		global.moving_figure = 0;
		global.using_ability = 0;
	}

	default_cell_click_action = function(cell) {
		if (cell_is_playable(cell)) {
			select_movable_figure(cell);
		}
	}
	cell_is_playable = function(cell) {
		return (cell.is_filled() and 
				cell.filled_figure.owner == global.turn_owner and 
				cell.filled_figure.state.is_active);
	}
	select_movable_figure = function(cell) {
		global.cell_click_callback = cell;
		global.selected_cell = cell;
		set_can_cancel(1);
		cell.filled_figure.click();
	}

	clear_all = function() {
		if instance_exists(O_SummonInputController) {instance_destroy(O_SummonInputController)}
		clean_controllers();
		if instance_exists(O_FigureActionController) {
			O_FigureActionController.clear_buttons();
			instance_destroy(O_FigureActionController);
		}
		O_EndTurn.active = 1;
		global.selected_cell = undefined;
		O_SummonButton.go_to_standart_mode();
		Game.Field.clear_all_marks();
		global.cell_click_callback = undefined;
		set_can_cancel(0)
		O_SummonButton.unblock()
		global.cell_action = default_cell_click_action;
		action = undefined;
		global.able_to_summon = false;
		global.moving_figure = false;
		global.using_ability = false;
	}

	check_win_conditions = function() {
		if player1_captured >= 4 and player2_captured >= 4 {return "draw"}
		else {
			if player1_captured >= 4 {return "player1_win"}
			if player2_captured >= 4 {return "player2_win"}
		}
		if O_Figures_counter.get_player_figures_amount("player1") == 0 and 
		O_Figures_counter.player1_field_figures == 0 {return "player2_win"}
		if O_Figures_counter.get_player_figures_amount("player2") == 0 and 
		O_Figures_counter.player2_field_figures == 0 {return "player1_win"}
		if O_Turn_timer.player_out_of_time != undefined {
			if global.turn_owner == "player1" {return "player1_win"}
			else {return "player2_win"}
		}
	
		return undefined
	}

	add_captured_figure = function(player) {
		if player = "player1" {
			player1_captured ++;
		}
		else {
			player2_captured ++;
		}
	}

	export = function() {
		export_data = {
			ex_turn_owner: global.turn_owner,
			ex_player1_captured: player1_captured,
			ex_player2_captured: player2_captured,
			ex_timer_struct: turn_timer.export(),
			ex_figures_counter_struct: O_Figures_counter.export(),
			ex_gamefield: Game.Field.export(),
			ex_player1_figures: Game.data.load("player1"),
			ex_player2_figures: Game.data.load("player2")
		}
		return export_data
	}

	import = function(import_data) {
		clear_all();
		while (instance_number(O_Figure) > 0) {
			instance_destroy(instance_find(O_Figure, 0))
			}
		global.turn_owner = import_data.ex_turn_owner;
		player1_captured = import_data.ex_player1_captured;
		player2_captured = import_data.ex_player2_captured;
		turn_timer.import(import_data.ex_timer_struct);
		O_Figures_counter.import(import_data.ex_figures_counter_struct);
		Game.Field.import(import_data.ex_gamefield);
		Game.data.save("player1", import_data.ex_player1_figures);
		Game.data.save("player2", import_data.ex_player2_figures);
	}

	import_action = function(import_struct) {
		clear_all();
		global.turn_owner = import_struct.ex_turn_owner;
		if import_struct.ex_type == "act_ability" {
			action = new import_struct.ex_action(import_struct.ex_using_figure, import_struct.ex_using_cell);
			action.import(import_struct);
		}
		else if import_struct.ex_type == "move_ability" {
			action = new import_struct.ex_action(import_struct.ex_from_x, import_struct.ex_from_y, 
			import_struct.ex_to_x, import_struct.ex_to_y, undefined);
			action.import();
		}
		else if import_struct.ex_type == "summon" {
			action = new import_struct.ex_action(import_struct.ex_target_x, import_struct.ex_target_y, undefined);
			action.import();
		}
		end_move();
	}

	global.cell_action = default_cell_click_action;
}