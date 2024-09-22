/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
seconds = 0
bank_seconds = 0;
all_time = undefined;
current_frame = 0;
active = 0;
using_time_bank = false;
draw_x = 815;
draw_y = 190;
player_out_of_time = undefined;

max_time_bank = 7200;
player1_time_bank = 3600;
player2_time_bank = 3600;

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
start_count = function() {
	self.all_time = Settings.turn_time;
	draw_x = 815;
	current_frame = 0;
	seconds = 0;
	bank_seconds = 0;
	active = 1;
	using_time_bank = 0;
}

reset = function() {
	stop_count();
	start_count();
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