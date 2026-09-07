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

		var _actions = Game.game_loop_controller.get_legal_action_descriptors(global.turn_owner);
		show_debug_message("BotController: player=" + string(global.turn_owner) + ", legal_actions=" + string(array_length(_actions)));
		if array_length(_actions) > 0 {
			var _action = _actions[irandom(array_length(_actions) - 1)];
			show_debug_message("BotController: selected action kind=" + string(_action.kind));
			Game.game_loop_controller.perform_action_descriptor(_action);
		}
		else {
			Game.game_loop_controller.end_move();
		}
		frames_left = think_frames;
	}
}
