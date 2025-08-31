// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameLoopController() constructor{
	player1_captured = 0;
	player2_captured = 0;
	action = undefined;
	turn_end = false;
	can_cancel = false;
	displaying_card = false;
	change_turn_owner = 1;
	export_data = [];
	action_export_data = [];
	ready_to_send = 1;
	player1_cards = [];
	player2_cards = [];
	cards_x = room_width/2 - 150;
	cards_y = room_height/1.25 - 60;
	cards_offset = 10
	
	turn_timer = new Timer();
	turn_timer.start_count(Settings.turn_time);
	
	figures_counter = new FiguresCounter();
	
	
	TEST_action_draw = function() {
		if have_action() {
			action.draw();
		}
	}
	
	TEST_draw_cards = function() {
		for (i = 0; i < array_length(player1_cards); i++) {
			player1_cards[i].draw();
		}
		for (i = 0; i < array_length(player2_cards); i++) {
			player2_cards[i].draw();
		}
	}
	
	TEST_check_cards = function() {
		for (i = 0; i < array_length(player1_cards); i++) {
			if keyboard_check_released(vk_alt) and abs(mouse_x - (cards_x + cards_offset*i)) < 40
			and abs(mouse_y - (cards_y)) < 60{
				var _display = instance_create_depth(room_width/2, room_height/2, -5, O_Card_display);
				_display.set_sprite(player1_cards[i].sprite)
			}
		}
	}
	
	
	enum STATE_LIST {
		wait,
		summon,
		figure_move,
		figure_action,
		figure_ability,
		animation,
		enemy_turn,
	}
	state = STATE_LIST.wait;
	if Game.online_match {
		if global.turn_owner == O_LoginController.enemy {
			state = STATE_LIST.enemy_turn;
		}
	}
	
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
		if _player == Game.Player1.player_id {return Game.Player1}
		else return Game.Player2
	}
	
	get_cards_array = function(_player) {
		if _player == Game.Player1.player_id {
			return player1_cards
		}
		else {
			return player2_cards
		}
	}
	
	create_cards = function(_player) {
		var _start_x = cards_x;
		var _start_y = cards_y;
		cards_offset = 300/(array_length(get_player(_player).deck)-1)
		for (i = 0; i <array_length(get_player(_player).deck); i++) {
			new_card = new FigureCard();
			new_card.set_figure(get_player(_player).deck[i]);
			new_card.set_cord(_start_x + i*cards_offset, _start_y);
			array_push(get_cards_array(_player), new_card);
		}
	}
	
	create_cards(Game.Player1.player_id);
	//create_cards(Game.Player2.player_id);

	end_move = function() {
		//if global.moving_figure {
		//	global.selected_cell.filled_figure.start_move_animation(global.cell_click_callback, Settings.move_animation_length)
		//}
		if ready_to_send and Game.online_match{
			if O_LoginController._id == global.turn_owner{
				action_export_data = [action.export()]
				export_data = [export(), action_export_data]
			}
			else {
				export_data = undefined;
			}
		}
		execute_action();
		turn_timer.reset();
		
		global.turn_owner = get_opponent(global.turn_owner);
		clear_all();
		Game.field.check_if_any_cell_conquested();
		Game.field.check_every_figure();
		figures_counter.update_turn();
		if Game.online_match {
			if global.turn_owner == O_LoginController._id {
				state = STATE_LIST.wait;
			}
			else {
				state = STATE_LIST.enemy_turn;
			}
		}
		if export_data != undefined {
			if ready_to_send {
				Game.send_turn(export_data[0], export_data[1])
			}
		}
		if check_win_conditions() != undefined {
			if Game.online_match {
				if Game.role == "host" {
					Server.send(new ServerMessage(ServerMessageType.GameplayFinish, {winner: check_win_conditions()}))
				}
			}
			else {
				show_message(check_win_conditions());
				room_goto(R_Main_menu);
			}
		}
		if state == STATE_LIST.enemy_turn {
			Game.field.clear_all_marks();
		}
		ready_to_send = 1;
		UI_controller.clear_ingame_layer(1)
	}

	set_action = function(new_action) {
		action = new_action;
	}

	have_action = function() {
		return action != undefined
	}

	get_opponent = function(player) {
		if player = Game.Player1.player_id {
			return Game.Player2.player_id
		}
		else {
			return Game.Player1.player_id
		}
	}

	choose_cell_for_summon = function() {
		global.cell_click_callback.filled_figure_status.set_status("will_be_summoned", 1)
		if global.selected_cell == undefined {
			global.cell_click_callback.marked = 0;
			
			global.selected_cell = global.cell_click_callback;
			Game.summon_controller.start_summon(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		}
		else {
			global.selected_cell.filled_figure_status.set_status("will_be_summoned", 0)
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
	
	mark_active_figures = function() {
		cells = Game.field.get_filled_cells(global.turn_owner)
		for (i = 0; i < array_length(cells); i++) {
			if cells[i].filled_figure.state.is_active {cells[i].marked = 1}
		}
		global.mark = S_Controlled_mark;
	}

	quit_from_action = function() {
		clean_controllers();
		O_BoardDraw.clear();
		Game.field.clear_all_marks(); 
		//O_SummonButton.go_away();
		global.using_ability = 1;
		global.cell_click_callback = global.selected_cell;
		Game.figure_action_controller = new FigureActionController()
		action = undefined;
	}

	execute_action = function() {
		if have_action() {
			//Game.game_data.save_action(action.export())
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
		O_BoardDraw.clear();
		global.selected_cell = undefined;
		Game.field.clear_all_marks();
		global.cell_click_callback = undefined;
		set_can_cancel(0);
		global.cell_action = default_cell_click_action;
		action = undefined;
		global.able_to_summon = false;
		state = STATE_LIST.wait;
		mark_active_figures();
	}

	check_win_conditions = function() {
		if player1_captured >= 4 and player2_captured >= 4 {return ""}
		else {
			if player1_captured >= 4 {return Game.Player1.player_id}
			if player2_captured >= 4 {return Game.Player2.player_id}
		}
		if figures_counter.get_summon_figures_amount(Game.Player1.player_id) == 0 and 
		figures_counter.get_field_figures(Game.Player1.player_id) == 0 {return Game.Player2.player_id}
		if figures_counter.get_summon_figures_amount(Game.Player2.player_id) == 0 and 
		figures_counter.get_field_figures(Game.Player2.player_id) == 0 {return Game.Player1.player_id}
		if turn_timer.player_out_of_time != undefined {
			if global.turn_owner == Game.Player1.player_id {return Game.Player1.player_id}
			else {return Game.Player2.player_id}
		}
		out_of_figures = 0
		if figures_counter.get_summon_figures_amount(Game.Player1.player_id) == 0 and 
		Game.field.get_active_player_field_figures(Game.Player1.player_id) == 0 {out_of_figures++}
		if figures_counter.get_summon_figures_amount(Game.Player2.player_id) == 0 and 
		Game.field.get_active_player_field_figures(Game.Player2.player_id) == 0 {out_of_figures++}
		if out_of_figures == 2 {
			if player1_captured > player2_captured {return Game.Player1.player_id}
			if player2_captured > player1_captured {return Game.Player2.player_id}
			if player1_captured == player2_captured {return ""}
		}
	
		return undefined
	}

	add_captured_figure = function(player) {
		if player = Game.Player1.player_id {
			player1_captured ++;
		}
		else if player == Game.Player2.player_id{
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
			ex_gamefield: Game.field.export(),
			ex_player1_figures: Game.user_data.load(Game.Player1.player_id),
			ex_player2_figures: Game.user_data.load(Game.Player2.player_id),
			ex_state: state
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
		Game.field.import(import_data.ex_gamefield);
		Game.user_data.save(Game.Player1.player_id, import_data.ex_player1_figures);
		Game.user_data.save(Game.Player2.player_id, import_data.ex_player2_figures);

		//state = import_data.ex_state;
	}

	import_action = function(import_struct) {
		clear_all();
		//global.turn_owner = import_struct.ex_turn_owner;
		switch import_struct.ex_type{
		case "act_ability":
			action = new import_struct.ex_action();
			action.import(import_struct);
			break;
		case "move_ability":
			action = new import_struct.ex_action(import_struct.ex_from_x, import_struct.ex_from_y, 
			import_struct.ex_to_x, import_struct.ex_to_y, undefined);
			action.import(import_struct);
			break;
		case "summon": 
			action = new import_struct.ex_action(import_struct.ex_target_x, import_struct.ex_target_y, undefined);
			action.import(import_struct);
			break;
		case "get_field_figure":
			action = new import_struct.ex_action();
			action.import(import_struct);
			break;
		}
		ready_to_send = 0;
		end_move();
	}

	global.cell_action = default_cell_click_action;
	array_push(Game.do_every_step_list, TEST_draw_cards);
	array_push(Game.do_every_step_list, TEST_check_cards);
}