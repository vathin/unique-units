// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FiguresCounter() constructor {
	player1_field_figures = 0;
	player2_field_figures = 0;
	current_player_figures = 20;
	figures_to_capture = []
	
	
	add_figure_to_capture = function(new_figure, owning_cell) {
		array_push(figures_to_capture, [new_figure, owning_cell])
	}

	get_field_figures = function(player) {
		if player = "player1" {return player1_field_figures}
		else {return player2_field_figures}
	}
	
	get_player_figures_amount = function(player) {
		return array_length(Game.data.load(player).player_figures);
	}

	change_field_figures_amount = function(player, amount) {
		if player = "player1" {player1_field_figures += amount}
		else {player2_field_figures += amount}
	}

	update_captured_figures_array = function() {
		if array_length(figures_to_capture) > 0 {
			while array_length(figures_to_capture) > 0 {
				capture_figure = array_pop(figures_to_capture);
				Game.game_loop_controller.add_captured_figure(Game.game_loop_controller.get_opponent
				(capture_figure[0].owner));
				capture_figure[1].clear();
				capture_figure[0].capture();
				place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				place.add_figure(capture_figure[0])
			}
		}
	}

	update_turn = function() {
		current_player_figures = array_length(Game.data.load(global.turn_owner).player_figures);
		if current_player_figures <= 0 or (get_field_figures(global.turn_owner) >= Settings.max_field_figures){
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 0
		}
		else {
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 1
		}
		update_captured_figures_array();
	}

	get_summon_figures_amount = function(player) {
		if player = "player1" {
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
		}
			return export_data;
	}

	import = function(import_data) {
		player1_field_figures = import_data.ex_player1_field_figures;
		player2_field_figures = import_data.ex_player2_field_figures;
		update_turn();
	}
}