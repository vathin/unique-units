// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Timer() constructor{
	seconds = 0
	bank_seconds = 0;
	all_time = undefined;
	current_frame = 0;
	active = 0;
	using_time_bank = false;
	draw_x = (room_width/2)-45
	draw_y = 100;
	player_out_of_time = undefined;

	max_time_bank = 7200;
	player1_time_bank = 3600;
	player2_time_bank = 3600;
	
	timer_function = function() {
		if active {
			if current_frame <= all_time {
				current_frame ++;
				using_time_bank = 0;
			}
			else {
				if get_player_time_bank(global.turn_owner) > 1 {
					use_time_bank(global.turn_owner);
				}
				else {
					if Game.game_loop_controller.can_cancel {O_GameLoopController.cancel_action()}
					//if instance_exists(O_SummonInputController) {O_SummonInputController.time_end()}
					player_out_of_time = global.turn_owner;
					Game.game_loop_controller.end_move();
				}
			}
		}
	}
	
	TEST_draw_timer = function() {
		draw_set_font(F_turn_timer);
		if !using_time_bank {
			seconds = all_time div Settings.FPS - current_frame div Settings.FPS;
			if seconds <= 15 {draw_set_color(c_orange)}
			if seconds == 9 {draw_x += 0.15}
			if seconds < 1 {draw_set_color(c_red)}
		}
		else {
			draw_set_color(c_red);
			bank_seconds = get_player_time_bank(global.turn_owner) div Settings.FPS;
			draw_text_transformed(random_range((draw_x + 47), (draw_x + 53)), random_range((draw_y - 10), (draw_y - 15)), bank_seconds, 1.25, 1.25, 0);
		}
		draw_text_transformed(draw_x, draw_y, seconds, 0.75, 0.75, 0);
		draw_set_color(c_white);
	}

	add_player_time_bank = function(value, player) {
		if player == "player1" and player1_time_bank < max_time_bank{
			player1_time_bank += value
			if player1_time_bank > max_time_bank {player1_time_bank = max_time_bank}
		}
		if player == "player2" and player2_time_bank < max_time_bank{
			player2_time_bank += value
			if player2_time_bank > max_time_bank {player2_time_bank = max_time_bank}
		}
	}

	get_player_time_bank = function(player) {
		if player == "player1" {return player1_time_bank}
		else {return player2_time_bank}
	}
	use_time_bank = function(player) {
		if player == "player1"{
			player1_time_bank--;
		}
		if player == "player2"{
			player2_time_bank--;
		}
		if !using_time_bank {using_time_bank = 1}
	}

	stop_count = function() {
		if !using_time_bank {
			add_player_time_bank((all_time-current_frame), global.turn_owner);
		}
	}
	start_count = function(time) {
		all_time = time;
		current_frame = 0;
		seconds = 0;
		bank_seconds = 0;
		active = 1;
		using_time_bank = 0;
		array_push(Game.do_every_step_list, TEST_draw_timer)
		array_push(Game.do_every_step_list, timer_function)
	}

	reset = function() {
		stop_count();
		start_count(Settings.turn_time);
	}

	export = function() {
		export_data = {
			ex_player1_time_bank: player1_time_bank,
			ex_player2_time_bank: player2_time_bank,
			ex_current_frame: current_frame,
			ex_using_time_bank: using_time_bank,
			ex_seconds: seconds,
			ex_all_time: all_time
		}
		return export_data
	}

	import = function(import_data) {
		player1_time_bank = import_data.ex_player1_time_bank;
		player2_time_bank = import_data.ex_player2_time_bank;
		current_frame = import_data.ex_current_frame;
		using_time_bank = import_data.ex_using_time_bank;
		seconds = import_data.ex_seconds;
		all_time = import_data.ex_all_time;
}
}