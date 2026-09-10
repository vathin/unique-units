function BotController() constructor {
	enabled = true;
	think_frames = 30;
	frames_left = think_frames;
	last_turn_owner = undefined;

	is_bot_turn = function() {
		if !enabled or Game.online_match {
			return false;
		}
		if Game.game_loop_controller == undefined {
			return false;
		}
		var _player = Game.game_loop_controller.get_player(global.turn_owner);
		return _player != undefined and _player.player_type == "bot";
	}

	step = function() {
		if !is_bot_turn() {
			frames_left = think_frames;
			last_turn_owner = global.turn_owner;
			return;
		}
		if last_turn_owner != global.turn_owner {
			last_turn_owner = global.turn_owner;
			frames_left = think_frames;
		}
		if Game.game_loop_controller.get_game_state() != STATE_LIST.wait {
			return;
		}
		if Game.game_loop_controller.have_action() {
			if Game.game_loop_controller.action_is_ready() {
				show_debug_message("BotController: completing prepared action");
				Game.game_loop_controller.end_move();
				frames_left = think_frames;
			}
			return;
		}
		if frames_left > 0 {
			frames_left--;
			return;
		}
		if Game.game_state == undefined || Game.game_state.data.active_player_id != global.turn_owner {
			show_debug_message("BotController: synchronizing state for player=" + string(global.turn_owner));
			Game.sync_game_state_from_legacy();
		}

		var _actions = Game.game_loop_controller.get_legal_action_descriptors(global.turn_owner);
		var _state_player = Game.game_state == undefined ? undefined : Game.game_state.data.players[$ string(global.turn_owner)];
		var _deck_count = -1;
		if _state_player != undefined && is_array(_state_player.deck) {
			_deck_count = array_length(_state_player.deck);
		}
		var _summon_specs = Game.game_state == undefined ? [] : Game.game_rules.get_inputs(Game.game_state, global.turn_owner, "summon", {});
		var _summon_cells = array_length(_summon_specs) <= 0 || !is_array(_summon_specs[0].allowed_cells) ? -1 : array_length(_summon_specs[0].allowed_cells);
		show_debug_message("BotController: player=" + string(global.turn_owner) + ", active=" + string(Game.game_state.data.active_player_id) + ", deck=" + string(_deck_count) + ", summon_cells=" + string(_summon_cells) + ", legal_actions=" + string(array_length(_actions)));
		if array_length(_actions) > 0 {
			var _best_action = undefined;
			var _best_score = -1000000;
			for (var i = 0; i < array_length(_actions); i++) {
				var _score = Game.game_loop_controller.score_action_descriptor(_actions[i]);
				if (_score > _best_score) {
					_best_score = _score;
					_best_action = _actions[i];
				}
			}
			var _effect_name = variable_struct_exists(_best_action, "effect_id") ? _best_action.effect_id : "legacy";
			var _effect_inputs = variable_struct_exists(_best_action, "inputs") ? json_stringify(_best_action.inputs) : "{}";
			show_debug_message("BotController: selected action kind=" + string(_best_action.kind)
				+ ", effect=" + string(_effect_name) + ", inputs=" + _effect_inputs + ", score=" + string(_best_score));
			Game.game_loop_controller.perform_action_descriptor(_best_action);
		}
		else {
			Game.game_loop_controller.end_move();
		}
		frames_left = think_frames;
	}
}
