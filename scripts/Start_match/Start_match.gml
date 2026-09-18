function Start_match(_mode = "local_vs_local"){
	if instance_exists(O_DeckManager) && !O_DeckManager.is_selected_deck_valid() {
		var _validation = O_DeckManager.get_selected_deck_validation();
		show_debug_message("Start_match rejected: selected deck is invalid: " + json_stringify(_validation.errors));
		return false;
	}
	global.cell_click_callback = undefined;
	global.selected_cell = undefined;
	global.able_to_summon = false;
	global.moving_figure = false;
	global.using_ability = false;
	global.figure_to_summon = undefined;
	global.turn_owner = 1;
	global.map = "map1";
	global.local_match_deck = undefined;
	global.local_match_mode = _mode;

	if instance_exists(O_DeckManager) {
		var _selected_deck = O_DeckManager.get_selected_deck();
		if _selected_deck != undefined {
			var _selected_figures = O_DeckManager.get_selected_deck_array();
			if array_length(_selected_figures) > 0 {
				global.local_match_deck = {
					player_cards: O_DeckManager.get_selected_deck_names_list(),
					player_figures: _selected_figures,
					player_deck_size: array_length(_selected_figures)
				};
			}
		}
	}

	if (!variable_global_exists("game") || global.game == undefined) {
		global.game = new GameClass();
	}
	else {
		global.game.end_game();
	}

	global.game.online_match = false;
	global.game.server_id = "";
	global.game.opponent = "";
	global.game.role = "host";
	global.game.set_local_match_mode(_mode);

	room_goto(R_Test);
	return true;
}
