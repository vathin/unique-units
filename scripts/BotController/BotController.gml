function BotController() constructor {
	enabled = true;
	think_frames = 30;
	frames_left = think_frames;
	last_turn_owner = undefined;
	time_budget_us = 16667;
	thinking = undefined;

	reset_thinking = function() {
		thinking = undefined;
	}

	is_bot_turn = function() {
		if !enabled or Game.online_match {
			return false;
		}
		if global.turn_owner == undefined {
			return false;
		}
		if Game.game_loop_controller == undefined {
			return false;
		}
		var _player = Game.game_loop_controller.get_player(global.turn_owner);
		return _player != undefined and _player.player_type == "bot";
	}

	add_to_shortlist = function(_action, _score) {
		var _shortlist_size = 12;
		if array_length(thinking.shortlist) < _shortlist_size {
			array_push(thinking.shortlist, {action: _action, score: _score});
			return;
		}
		var _weakest_index = 0;
		for (var _shortlist_index = 1; _shortlist_index < array_length(thinking.shortlist); _shortlist_index++) {
			if thinking.shortlist[_shortlist_index].score < thinking.shortlist[_weakest_index].score {
				_weakest_index = _shortlist_index;
			}
		}
		if _score > thinking.shortlist[_weakest_index].score {
			thinking.shortlist[_weakest_index] = {action: _action, score: _score};
		}
	}

	begin_thinking = function(_player_id) {
		if _player_id == undefined {
			show_debug_message("BotController: skipped thinking without player id");
			return false;
		}
		if Game.game_state == undefined or Game.game_state.data.active_player_id != _player_id {
			show_debug_message("BotController: waiting for confirmed state, player=" + string(_player_id));
			return false;
		}
		thinking = {
			player: _player_id,
			stage: "generate",
			search: Game.game_loop_controller.create_effect_action_search(_player_id, Game.game_state),
			actions: [],
			quick_index: 0,
			shortlist: [],
			detailed_index: 0,
			best_action: undefined,
			best_score: -1000001
		};
		show_debug_message("BotController: thinking started, player=" + string(_player_id));
		return true;
	}

	commit_best_action = function() {
		if thinking.best_action == undefined {
			show_debug_message("BotController: no legal actions, ending turn");
			Game.game_loop_controller.end_move();
		}
		else {
			var _effect_name = variable_struct_exists(thinking.best_action, "effect_id") ? thinking.best_action.effect_id : "legacy";
			var _effect_inputs = variable_struct_exists(thinking.best_action, "inputs") ? json_stringify(thinking.best_action.inputs) : "{}";
			show_debug_message("BotController: selected action kind=" + string(thinking.best_action.kind)
				+ ", effect=" + string(_effect_name) + ", inputs=" + _effect_inputs + ", score=" + string(thinking.best_score));
			Game.game_loop_controller.perform_action_descriptor(thinking.best_action);
		}
		reset_thinking();
		frames_left = think_frames;
	}

	continue_thinking = function(_deadline_us) {
		while get_timer() < _deadline_us {
			if thinking.stage == "generate" {
				if !Game.game_loop_controller.step_effect_action_search(thinking.search, _deadline_us) {
					return false;
				}
				thinking.actions = thinking.search.actions;
				show_debug_message("BotController: player=" + string(thinking.player) + ", legal_actions=" + string(array_length(thinking.actions)));
				if array_length(thinking.actions) <= 0 {
					commit_best_action();
					return true;
				}
				thinking.stage = "quick";
				continue;
			}

			if thinking.stage == "quick" {
				if thinking.quick_index >= array_length(thinking.actions) {
					thinking.stage = "detailed_setup";
					continue;
				}
				var _quick_action = thinking.actions[thinking.quick_index];
				var _quick_score = Game.game_loop_controller.score_action_descriptor(_quick_action, false);
				add_to_shortlist(_quick_action, _quick_score);
				thinking.quick_index++;
				continue;
			}

			if thinking.stage == "detailed_setup" {
				Game.game_loop_controller.begin_bot_scoring(thinking.player);
				thinking.stage = "detailed";
				continue;
			}

			if thinking.stage == "detailed" {
				if thinking.detailed_index >= array_length(thinking.shortlist) {
					thinking.stage = "commit";
					continue;
				}
				var _candidate = thinking.shortlist[thinking.detailed_index].action;
				var _score = Game.game_loop_controller.score_action_descriptor(_candidate, true);
				if _score > thinking.best_score {
					thinking.best_score = _score;
					thinking.best_action = _candidate;
				}
				thinking.detailed_index++;
				continue;
			}

			if thinking.stage == "commit" {
				commit_best_action();
				return true;
			}
		}
		return false;
	}

	step = function() {
		if !is_bot_turn() {
			frames_left = think_frames;
			last_turn_owner = global.turn_owner;
			reset_thinking();
			return;
		}
		if last_turn_owner != global.turn_owner {
			last_turn_owner = global.turn_owner;
			frames_left = think_frames;
			reset_thinking();
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
		if thinking == undefined && !begin_thinking(global.turn_owner) {
			frames_left = think_frames;
			return;
		}
		continue_thinking(get_timer() + time_budget_us);
	}
}
