// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FiguresCounter() constructor {
	player1_field_figures = 0;
	player2_field_figures = 0;
	current_player_figures = 20;
	figures_id_counter = 0;
	figures_to_capture = [];
	display_player_max_figures = 20;
	display_opponent_max_figures = 20;
	display_player_figures = 20;
	display_opponent_figures = 20;
	
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

	change_field_figures_amount = function(player, amount) {							//кто прочитал тот дурак
		if player == Game.Player1.player_id {player1_field_figures += amount}	
		else {player2_field_figures += amount}									
	}

	get_figure_id = function() {
		figures_id_counter ++;
		return string(figures_id_counter-1);
	}

	update_captured_figures_array = function() {
		if array_length(figures_to_capture) > 0 {
			while array_length(figures_to_capture) > 0 {
				capture_figure = array_pop(figures_to_capture);
				Game.game_loop_controller.add_captured_figure(Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				capture_figure[0].capture(1);
				capture_figure[1].clear();
				place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(capture_figure[0].owner));
				place.add_figure(capture_figure[0], 1);
			}
		}
	}

	update_turn = function() {
		player1_field_figures = array_length(Game.field.get_player_field_figures(Game.Player1.player_id));
		player2_field_figures = array_length(Game.field.get_player_field_figures(Game.Player2.player_id));
		current_player_figures = array_length(Game.user_data.load(global.turn_owner).player_figures);
		update_display_figures();
		if current_player_figures <= 0 or (get_field_figures(global.turn_owner) >= Settings.max_field_figures){
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 0
		}
		else {
			Game.game_loop_controller.get_player(global.turn_owner).able_to_summon = 1
		}
		update_captured_figures_array();
		update_ui_counter();
	}
	
	update_display_figures = function() {
		display_player_figures = array_length(Game.user_data.load(O_Server._id).player_figures);
		display_opponent_figures = array_length(Game.user_data.load(Game.opponent).player_figures);
		display_player_max_figures = Game.user_data.load(O_Server._id).player_deck_size;
		display_opponent_max_figures = Game.user_data.load(Game.opponent).player_deck_size;
	}

	update_ui_counter = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "PlayerFiguresText", get_field_figures(O_Server._id));
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "OpponentFiguresText", get_field_figures(Game.opponent));
	}
	
	display_available_figures = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "AvailableFiguresCount", string(display_player_figures) + 
		"/" + string(display_player_max_figures));
	}
	
	clear_available_figures_text = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "AvailableFiguresCount", "");
	}
	
	display_opponent_available_figures = function() {
		UI_controller.set_text_on_ui_layer(UI_controller.InGame_layer, "EnemyDeckCount", string(display_opponent_figures) + 
		"/" + string(display_opponent_max_figures));
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