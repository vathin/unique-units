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
	
	turn_timer = new Timer()
	turn_timer.start_count(Settings.turn_time)
	
	figures_counter = new FiguresCounter()
	
	
	
	TEST_action_draw = function() {
		if have_action() {
			action.draw()
		}
	}
	array_push(Game.do_every_step_list, TEST_action_draw)
	
	enum STATE_LIST {
		wait,
		summon,
		figure_move,
		figure_action,
		figure_ability,
		animation,
		enemy_turn,
	}
	state = STATE_LIST.wait
	
	get_game_state = function() {
		return state
	}
	
	set_game_state = function(_new_state) {
		state = _new_state
	}
	
	set_can_cancel = function(_value) {
		can_cancel = _value;
	}

	startInput = function() {
		//O_SummonButton.unblock()
		state = STATE_LIST.wait
	}
	
	get_player = function(_player) {
		if _player == "player1" {return Game.Player1}
		else return Game.Player2
	}

	end_move = function() {
		//if global.moving_figure {
		//	global.selected_cell.filled_figure.start_move_animation(global.cell_click_callback, Settings.move_animation_length)
		//}
		execute_action();
		turn_timer.reset();
		global.turn_owner = get_opponent(global.turn_owner);
		clear_all();
		Maps_list.check_if_any_cell_conquested(global.map);
		Game.field.check_every_figure();
		figures_counter.update_turn();
		if check_win_conditions() != undefined {
			show_message(check_win_conditions());
			game_end();
		}
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
			Game.summon_controller.start_summon(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
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
			figures_counter.update_turn();
	}

	quit_from_action = function() {
		clean_controllers()
		Game.field.clear_all_marks(); 
		//O_SummonButton.go_away();
		global.using_ability = 1;
		global.cell_click_callback = global.selected_cell;
		Game.figure_action_controller = new FigureActionController()
		action = undefined;
	}

	execute_action = function() {
		if have_action() {
			Game.game_data.save_action(action.export())
			action.execute();
		}
	}

	clean_controllers = function() {
		Game.ability_input_controller = undefined;
		Game.move_input_controller = undefined;
		Game.figure_action_controller = undefined;
		Game.summon_controller = undefined;
		state = STATE_LIST.wait;
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
		O_BoardDraw.figure_click(cell.filled_figure)
	}

	clear_all = function() {
		clean_controllers();
		O_BoardDraw.block_end_button();
		global.selected_cell = undefined;
		Game.field.clear_all_marks();
		global.cell_click_callback = undefined;
		set_can_cancel(0)
		global.cell_action = default_cell_click_action;
		action = undefined;
		global.able_to_summon = false;
		state = STATE_LIST.wait
	}

	check_win_conditions = function() {
		if player1_captured >= 4 and player2_captured >= 4 {return "draw"}
		else {
			if player1_captured >= 4 {return "player1_win"}
			if player2_captured >= 4 {return "player2_win"}
		}
		if figures_counter.get_player_figures_amount("player1") == 0 and 
		figures_counter.player1_field_figures == 0 {return "player2_win"}
		if figures_counter.get_player_figures_amount("player2") == 0 and 
		figures_counter.player2_field_figures == 0 {return "player1_win"}
		if turn_timer.player_out_of_time != undefined {
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
			ex_figures_counter_struct: figures_counter.export(),
			ex_gamefield: Game.Field.export(),
			ex_player1_figures: Game.data.load("player1"),
			ex_player2_figures: Game.data.load("player2")
		}
		return export_data
	}

	import = function(import_data) {
		clear_all();
		global.turn_owner = import_data.ex_turn_owner;
		player1_captured = import_data.ex_player1_captured;
		player2_captured = import_data.ex_player2_captured;
		turn_timer.import(import_data.ex_timer_struct);
		figures_counter.import(import_data.ex_figures_counter_struct);
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