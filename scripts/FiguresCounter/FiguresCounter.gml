// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FiguresCounter() constructor {
	player1_field_figures = 0;
	player2_field_figures = 0;
	current_player_figures = 20;
	figures_id_counter = 0
	figures_to_capture = []
	
	
	add_figure_to_capture = function(new_figure, owning_cell) {
		array_push(figures_to_capture, [new_figure, owning_cell])
	}

	get_field_figures = function(player) {
		if player == Game.Player1.player_id {return player1_field_figures}
		else {return player2_field_figures}
	}
	
	get_player_figures_amount = function(player) {
		return array_length(Game.user_data.load(player).player_figures);
	}

	change_field_figures_amount = function(player, amount) {					//оно уже тут не надо, само считается
		if player == Game.Player1.player_id {player1_field_figures += amount}	
		else {player2_field_figures += amount}									
	}
	
	get_figure_id = function() {
		figures_id_counter ++;
		return string(figures_id_counter-1)
	}

	update_captured_figures_array = function() {
		if array_length(figures_to_capture) > 0 {
			while array_length(figures_to_capture) > 0 {
				capture_figure = array_pop(figures_to_capture);
				Game.game_loop_controller.add_captured_figure(Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				capture_figure[0].capture(1);
				capture_figure[1].clear();
				place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				place.add_figure(capture_figure[0], 1)
			}
		}
	}

	update_turn = function() {
		player1_field_figures = array_length(Game.field.get_player_field_figures(Game.Player1.player_id));
		player2_field_figures = array_length(Game.field.get_player_field_figures(Game.Player2.player_id));
		current_player_figures = array_length(Game.user_data.load(global.turn_owner).player_figures);
		if current_player_figures <= 0 or (get_field_figures(global.turn_owner) >= Settings.max_field_figures){
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 0
		}
		else {
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 1
		}
		update_captured_figures_array();
	}

	get_summon_figures_amount = function(player) {
		if player == Game.Player1.player_id {
			if get_player_figures_amount(player) < Settings.max_field_figures - player1_field_figures {return get_player_figures_amount(player)}
			else {return Settings.max_field_figures - player1_field_figures}}
		else {
			if get_player_figures_amount(player) < Settings.max_field_figures - player2_field_figures {return get_player_figures_amount(player)}
			else {return Settings.max_field_figures - player2_field_figures}}
	}

	get_current_player_figures = function() {
		return current_player_figures;
	}

	export = function() {
		export_data = {
			ex_player1_field_figures: player1_field_figures,
			ex_player2_field_figures: player2_field_figures,
			ex_figures_id_counter: figures_id_counter
		}
			return export_data;
	}

	import = function(import_data) {
		player1_field_figures = import_data.ex_player1_field_figures;
		player2_field_figures = import_data.ex_player2_field_figures;
		figures_id_counter = import_data.ex_figures_id_counter;
		update_turn();
	}
}