// Р РµСЃСѓСЂСЃС‹ СЃРєСЂРёРїС‚РѕРІ Р±С‹Р»Рё РёР·РјРµРЅРµРЅС‹ РґР»СЏ РІРµСЂСЃРёРё 2.3.0, РїРѕРґСЂРѕР±РЅРѕСЃС‚Рё СЃРј. РїРѕ Р°РґСЂРµСЃСѓ
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function GameLoopController() constructor{
	player1_captured = 0;
	player2_captured = 0;
	action = undefined;
	turn_end = false;
	can_cancel = false;
	displaying_card = false;
	change_turn_owner = 1;
	turn_transition_pending = false;
	turn_transition_post_processed = false;
	bot_scoring_baseline = undefined;
	pending_authoritative_state = undefined;
	pending_network_animation_batches = [];
	ready_to_send = 1;
	player1_cards = [];
	player2_cards = [];
	cards_x = room_width/2 - 150;
	cards_1y = room_height/1.25 - 70;
	cards_2y = room_height*0.2 + 8;
	cards_offset = 10

	turn_timer = new Timer();
	turn_timer.start_count(Settings.turn_time);

	figures_counter = new FiguresCounter();

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
		if global.turn_owner == O_Server.enemy {
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

	is_turn_transition_active = function() {
		return turn_transition_pending or state == STATE_LIST.animation;
	}

	is_local_turn = function() {
		if !Game.online_match {
			return true;
		}
		return global.turn_owner == O_Server._id;
	}

	is_human_turn = function() {
		if !is_local_turn() {
			return false;
		}
		var _player = get_player(global.turn_owner);
		return _player != undefined and _player.player_type == "local";
	}

	startInput = function() {
		if is_local_turn() {
			state = STATE_LIST.wait;
		}
		else {
			state = STATE_LIST.enemy_turn;
		}
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

	get_next_summon_behaviour = function(_player) {
		if Game.game_state == undefined || !variable_struct_exists(Game.game_state.data, "players") {
			return undefined;
		}
		var _player_key = string(_player);
		if !variable_struct_exists(Game.game_state.data.players, _player_key) {
			return undefined;
		}
		var _deck = Game.game_state.data.players[$ _player_key].deck;
		if !is_array(_deck) || array_length(_deck) <= 0 {
			return undefined;
		}
		return _deck[array_length(_deck) - 1];
	}

	get_summon_target_cells = function(_player) {
		if Game.game_state == undefined || Game.game_rules == undefined {
			return [];
		}
		var _specs = Game.game_rules.get_inputs(Game.game_state, _player, "summon", {});
		return array_length(_specs) > 0 && is_array(_specs[0].allowed_cells) ? deep_copy(_specs[0].allowed_cells) : [];
	}

	/// Builds executable intents from the same input specs the human UI renders.
	/// The queue is bounded because every input is a finite cell/choice set.
	get_effect_action_descriptors = function(_player, _state = Game.game_state) {
		var _actions = [];
		if _state == undefined || Game.game_rules == undefined {
			return _actions;
		}
		var _effect_ids = ["summon", "move", "archer_move", "warrior_move", "warrior_ability", "spearman_ability", "shieldbearer_ability", "trader_ability"];
		for (var _effect_index = 0; _effect_index < array_length(_effect_ids); _effect_index++) {
			var _effect_id = _effect_ids[_effect_index];
			var _pending_inputs = [{}];
			var _iterations = 0;
			while array_length(_pending_inputs) > 0 && _iterations < 4096 {
				_iterations++;
				var _inputs = _pending_inputs[0];
				array_delete(_pending_inputs, 0, 1);
				var _specs = Game.game_rules.get_inputs(_state, _player, _effect_id, _inputs);
				var _next_spec = undefined;
				for (var _spec_index = 0; _spec_index < array_length(_specs); _spec_index++) {
					if !variable_struct_exists(_inputs, _specs[_spec_index].id) {
						_next_spec = _specs[_spec_index];
						break;
					}
				}
				if _next_spec == undefined {
					var _check = Game.game_rules.execute(_state, _player, {effect_id: _effect_id, inputs: _inputs});
					if _check.ok {
						array_push(_actions, {kind: "effect", effect_id: _effect_id, player: _player, inputs: deep_copy(_inputs)});
						if _effect_id == "warrior_move" && variable_struct_exists(_inputs, "target_cell") {
							var _warrior_move_effect = Game.game_rules.get_effect("warrior_move");
							var _strike_cells = _warrior_move_effect.get_strike_cells(_state, _player, _inputs.target_cell);
							for (var _strike_index = 0; _strike_index < array_length(_strike_cells); _strike_index++) {
								var _strike_inputs = deep_copy(_inputs);
								_strike_inputs.strike_target = deep_copy(_strike_cells[_strike_index]);
								array_push(_actions, {kind: "effect", effect_id: _effect_id, player: _player, inputs: _strike_inputs});
							}
						}
					}
				}
				else if _next_spec.type == "cell" && is_array(_next_spec.allowed_cells) {
					for (var _cell_index = 0; _cell_index < array_length(_next_spec.allowed_cells); _cell_index++) {
						var _next_inputs = deep_copy(_inputs);
						_next_inputs[$ _next_spec.id] = deep_copy(_next_spec.allowed_cells[_cell_index]);
						array_push(_pending_inputs, _next_inputs);
					}
				}
				else if _next_spec.type == "choice" && is_array(_next_spec.options) {
					for (var _choice_index = 0; _choice_index < array_length(_next_spec.options); _choice_index++) {
						var _choice_inputs = deep_copy(_inputs);
						_choice_inputs[$ _next_spec.id] = _next_spec.options[_choice_index].id;
						array_push(_pending_inputs, _choice_inputs);
					}
				}
			}
		}
		return _actions;
	}

	/// Resumable variant used by the bot so expanding input combinations does not
	/// monopolize one game step. Pass the returned state to
	/// step_effect_action_search(search, deadline_us) until it returns true.
	create_effect_action_search = function(_player, _state = Game.game_state) {
		var _search = {
			player: _player,
			state: _state,
			effect_ids: ["summon", "move", "archer_move", "warrior_move", "warrior_ability", "spearman_ability", "shieldbearer_ability", "trader_ability"],
			effect_index: 0,
			effect_iterations: 0,
			pending_inputs: [{}],
			actions: [],
			finished: false
		};
		if (_state == undefined || Game.game_rules == undefined) {
			_search.finished = true;
			return _search;
		}
		step_effect_action_search = function(_search, _deadline_us) {
			while (!_search.finished) {
				if (get_timer() >= _deadline_us) {
					return false;
				}
				if (array_length(_search.pending_inputs) <= 0 || _search.effect_iterations >= 4096) {
					_search.effect_index++;
					_search.effect_iterations = 0;
					if (_search.effect_index >= array_length(_search.effect_ids)) {
						_search.finished = true;
						break;
					}
					_search.pending_inputs = [{}];
					continue;
				}
				_search.effect_iterations++;
				var _effect_id = _search.effect_ids[_search.effect_index];
				var _inputs = _search.pending_inputs[0];
				array_delete(_search.pending_inputs, 0, 1);
				var _specs = Game.game_rules.get_inputs(_search.state, _search.player, _effect_id, _inputs);
				var _next_spec = undefined;
				for (var _spec_index = 0; _spec_index < array_length(_specs); _spec_index++) {
					if !variable_struct_exists(_inputs, _specs[_spec_index].id) {
						_next_spec = _specs[_spec_index];
						break;
					}
				}
				if (_next_spec == undefined) {
					var _check = Game.game_rules.execute(_search.state, _search.player, {effect_id: _effect_id, inputs: _inputs});
					if _check.ok {
						array_push(_search.actions, {kind: "effect", effect_id: _effect_id, player: _search.player, inputs: deep_copy(_inputs)});
						if _effect_id == "warrior_move" && variable_struct_exists(_inputs, "target_cell") {
							var _warrior_move_effect = Game.game_rules.get_effect("warrior_move");
							var _strike_cells = _warrior_move_effect.get_strike_cells(_search.state, _search.player, _inputs.target_cell);
							for (var _strike_index = 0; _strike_index < array_length(_strike_cells); _strike_index++) {
								var _strike_inputs = deep_copy(_inputs);
								_strike_inputs.strike_target = deep_copy(_strike_cells[_strike_index]);
								array_push(_search.actions, {kind: "effect", effect_id: _effect_id, player: _search.player, inputs: _strike_inputs});
							}
						}
					}
				}
				else if _next_spec.type == "cell" && is_array(_next_spec.allowed_cells) {
					for (var _cell_index = 0; _cell_index < array_length(_next_spec.allowed_cells); _cell_index++) {
						var _next_inputs = deep_copy(_inputs);
						_next_inputs[$ _next_spec.id] = deep_copy(_next_spec.allowed_cells[_cell_index]);
						array_push(_search.pending_inputs, _next_inputs);
					}
				}
				else if _next_spec.type == "choice" && is_array(_next_spec.options) {
					for (var _choice_index = 0; _choice_index < array_length(_next_spec.options); _choice_index++) {
						var _choice_inputs = deep_copy(_inputs);
						_choice_inputs[$ _next_spec.id] = _next_spec.options[_choice_index].id;
						array_push(_search.pending_inputs, _choice_inputs);
					}
				}
			}
			return true;
		}
		return _search;
	}

	get_legal_action_descriptors = function(_player, _state = Game.game_state) {
		return get_effect_action_descriptors(_player, _state);
	}

	get_random_action_descriptor = function(_player) {
		var _actions = get_legal_action_descriptors(_player);
		if array_length(_actions) <= 0 {
			return undefined;
		}
		return _actions[irandom(array_length(_actions) - 1)];
	}

	perform_random_action = function(_player) {
		var _descriptor = get_random_action_descriptor(_player);
		if _descriptor == undefined {
			return false;
		}
		return perform_action_descriptor(_descriptor);
	}

	create_action_from_descriptor = function(_descriptor, _simulation = false) {
		if !is_struct(_descriptor) || !variable_struct_exists(_descriptor, "kind") || _descriptor.kind != "effect" {
			show_debug_message("GameplayIntent rejected: legacy action descriptors are no longer executable");
			return undefined;
		}
		if variable_struct_exists(_descriptor, "effect_id") && variable_struct_exists(_descriptor, "player") && variable_struct_exists(_descriptor, "inputs") {
			return new EffectAction(_descriptor.effect_id, _descriptor.player, _descriptor.inputs);
		}
		show_debug_message("GameplayIntent rejected: incomplete effect descriptor");
		return undefined;
	}

	get_bot_figure_value = function(_behaviour) {
		switch string(_behaviour) {
			case "warrior": return 5;
			case "archer": return 4;
			case "shieldbearer": return 4;
			case "spearman": return 3;
			case "trader": return 3;
		}
		return 2;
	}

	get_bot_state_metrics = function(_state, _player) {
		var _opponent = get_opponent(_player);
		var _own_figures = 0;
		var _enemy_figures = 0;
		var _own_progress = 0;
		var _enemy_progress = 0;
		var _own_zone_figures = 0;
		var _enemy_zone_figures = 0;
		var _targets = Maps_list.get_cells_for_conquest();
		var _own_target_index = _player == Game.Player1.player_id ? 1 : 0;
		var _enemy_target_index = 1 - _own_target_index;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if _figure != undefined && _figure.status == "active" {
					var _is_own = _figure.owner_id == _player;
					var _progress = _y;
					if (_is_own && _player == Game.Player1.player_id) || (!_is_own && _opponent == Game.Player1.player_id) {
						_progress = _state.data.height - 1 - _y;
					}
					if _is_own {
						_own_figures++;
						_own_progress += _progress;
					}
					else {
						_enemy_figures++;
						_enemy_progress += _progress;
					}
					for (var _own_zone_index = 0; _own_zone_index < array_length(_targets[_own_target_index]); _own_zone_index++) {
						if _is_own && _x == _targets[_own_target_index][_own_zone_index][0] && _y == _targets[_own_target_index][_own_zone_index][1] {
							_own_zone_figures++;
						}
					}
					for (var _enemy_zone_index = 0; _enemy_zone_index < array_length(_targets[_enemy_target_index]); _enemy_zone_index++) {
						if !_is_own && _x == _targets[_enemy_target_index][_enemy_zone_index][0] && _y == _targets[_enemy_target_index][_enemy_zone_index][1] {
							_enemy_zone_figures++;
						}
					}
				}
			}
		}
		var _player_key = string(_player);
		var _opponent_key = string(_opponent);
		var _own_captured = variable_struct_exists(_state.data.captured, _player_key) ? _state.data.captured[$ _player_key] : 0;
		var _enemy_captured = variable_struct_exists(_state.data.captured, _opponent_key) ? _state.data.captured[$ _opponent_key] : 0;
		var _own_dropped = variable_struct_exists(_state.data.dropped, _player_key) ? _state.data.dropped[$ _player_key] : 0;
		var _enemy_dropped = variable_struct_exists(_state.data.dropped, _opponent_key) ? _state.data.dropped[$ _opponent_key] : 0;
		return {
			own_figures: _own_figures,
			enemy_figures: _enemy_figures,
			own_progress: _own_progress,
			enemy_progress: _enemy_progress,
			own_zone_figures: _own_zone_figures,
			enemy_zone_figures: _enemy_zone_figures,
			own_captured: _own_captured,
			enemy_captured: _enemy_captured,
			own_dropped: _own_dropped,
			enemy_dropped: _enemy_dropped
		};
	}

	get_state_active_figure_count = function(_state, _player) {
		var _count = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if (_figure != undefined && _figure.owner_id == _player && _figure.status == "active") {
					_count++;
				}
			}
		}
		return _count;
	}

	resolve_logic_turn = function(_state, _next_player) {
		return Game.game_rules.resolve_turn(_state, _next_player).next_state;
	}

	get_state_winner = function(_state) {
		var _player1 = Game.Player1.player_id;
		var _player2 = Game.Player2.player_id;
		var _player1_captured = _state.data.captured[$ string(_player1)];
		var _player2_captured = _state.data.captured[$ string(_player2)];
		if (_player1_captured >= 4 && _player2_captured >= 4) {
			return "";
		}
		if (_player1_captured >= 4) {
			return _player1;
		}
		if (_player2_captured >= 4) {
			return _player2;
		}
		var _player1_deck = _state.data.players[$ string(_player1)].deck;
		var _player2_deck = _state.data.players[$ string(_player2)].deck;
		var _player1_figures = get_state_active_figure_count(_state, _player1);
		var _player2_figures = get_state_active_figure_count(_state, _player2);
		if (array_length(_player1_deck) <= 0 && _player1_figures <= 0) {
			return _player2;
		}
		if (array_length(_player2_deck) <= 0 && _player2_figures <= 0) {
			return _player1;
		}
		if (array_length(_player1_deck) <= 0 && array_length(_player2_deck) <= 0 && _player1_figures <= 0 && _player2_figures <= 0) {
			if (_player1_captured > _player2_captured) {
				return _player1;
			}
			if (_player2_captured > _player1_captured) {
				return _player2;
			}
			return "";
		}
		return undefined;
	}

	get_player_goal_cells = function(_player) {
		var _goal_index = _player == Game.Player1.player_id ? 1 : 0;
		return Maps_list.get_cells_for_conquest()[_goal_index];
	}

	cell_is_in_list = function(_cell, _cells) {
		if !is_array(_cell) || array_length(_cell) != 2 {
			return false;
		}
		for (var _cell_index = 0; _cell_index < array_length(_cells); _cell_index++) {
			if (_cell[0] == _cells[_cell_index][0] && _cell[1] == _cells[_cell_index][1]) {
				return true;
			}
		}
		return false;
	}

	can_player_reach_goal = function(_state, _player) {
		var _goal_cells = get_player_goal_cells(_player);
		var _movement_effects = ["summon", "move", "archer_move", "warrior_move", "spearman_ability", "shieldbearer_ability", "trader_ability"];
		for (var _effect_index = 0; _effect_index < array_length(_movement_effects); _effect_index++) {
			var _pending_inputs = [{}];
			var _iterations = 0;
			while (array_length(_pending_inputs) > 0 && _iterations < 256) {
				_iterations++;
				var _inputs = _pending_inputs[0];
				array_delete(_pending_inputs, 0, 1);
				var _specs = Game.game_rules.get_inputs(_state, _player, _movement_effects[_effect_index], _inputs);
				var _next_spec = undefined;
				for (var _spec_index = 0; _spec_index < array_length(_specs); _spec_index++) {
					if !variable_struct_exists(_inputs, _specs[_spec_index].id) {
						_next_spec = _specs[_spec_index];
						break;
					}
				}
				if (_next_spec == undefined) {
					continue;
				}
				if (_next_spec.type == "cell" && is_array(_next_spec.allowed_cells)) {
					for (var _allowed_index = 0; _allowed_index < array_length(_next_spec.allowed_cells); _allowed_index++) {
						var _allowed_cell = _next_spec.allowed_cells[_allowed_index];
						var _moves_to_goal = _next_spec.id == "destination_cell"
							|| (_next_spec.id == "target_cell" && _movement_effects[_effect_index] != "shieldbearer_ability");
						if (_moves_to_goal && cell_is_in_list(_allowed_cell, _goal_cells)) {
							return true;
						}
						var _next_inputs = deep_copy(_inputs);
						_next_inputs[$ _next_spec.id] = deep_copy(_allowed_cell);
						array_push(_pending_inputs, _next_inputs);
					}
				}
				else if (_next_spec.type == "choice" && is_array(_next_spec.options)) {
					for (var _option_index = 0; _option_index < array_length(_next_spec.options); _option_index++) {
						var _next_inputs = deep_copy(_inputs);
						_next_inputs[$ _next_spec.id] = _next_spec.options[_option_index].id;
						array_push(_pending_inputs, _next_inputs);
					}
				}
			}
		}
		return false;
	}

	get_state_enemy_capture_threat = function(_state, _defender_player) {
		var _attacker = get_opponent(_defender_player);
		var _goal_cells = get_player_goal_cells(_attacker);
		var _threat = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if (_figure == undefined || _figure.owner_id != _attacker || _figure.status != "active") {
					continue;
				}
				var _closest_distance = 999;
				for (var _goal_index = 0; _goal_index < array_length(_goal_cells); _goal_index++) {
					var _goal = _goal_cells[_goal_index];
					var _distance = abs(_x - _goal[0]) + abs(_y - _goal[1]);
					if (_distance < _closest_distance) {
						_closest_distance = _distance;
					}
				}
				if (_closest_distance <= 2) {
					var _proximity = 3 - _closest_distance;
					_threat += _proximity * _proximity;
				}
			}
		}
		return _threat;
	}

	get_state_capture_point_defense = function(_state, _defender_player) {
		var _attacker = get_opponent(_defender_player);
		var _goal_cells = get_player_goal_cells(_attacker);
		var _defense = 0;
		for (var _goal_index = 0; _goal_index < array_length(_goal_cells); _goal_index++) {
			var _goal = _goal_cells[_goal_index];
			var _defender_figure = _state.get_figure(_goal[0], _goal[1]);
			if (_defender_figure == undefined || _defender_figure.owner_id != _defender_player) {
				continue;
			}
			_defense++;
			var _closest_attacker_distance = 999;
			for (var _x = 0; _x < _state.data.width; _x++) {
				for (var _y = 0; _y < _state.data.height; _y++) {
					var _figure = _state.get_figure(_x, _y);
					if (_figure == undefined || _figure.owner_id != _attacker || _figure.status != "active") {
						continue;
					}
					var _distance = abs(_x - _goal[0]) + abs(_y - _goal[1]);
					if (_distance < _closest_attacker_distance) {
						_closest_attacker_distance = _distance;
					}
				}
			}
			if (_closest_attacker_distance <= 2) {
				var _proximity = 3 - _closest_attacker_distance;
				_defense += _proximity * _proximity;
			}
		}
		return _defense;
	}

	get_state_surrounding_pressure = function(_state, _player) {
		var _empty_neighbors = 0;
		var _blocked_figures = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if (_figure == undefined || _figure.owner_id != _player || _figure.status != "active") {
					continue;
				}
				var _figure_empty_neighbors = 0;
				for (var _dx = -1; _dx <= 1; _dx++) {
					for (var _dy = -1; _dy <= 1; _dy++) {
						if (_dx == 0 && _dy == 0) {
							continue;
						}
						var _neighbor = _state.get_cell(_x + _dx, _y + _dy);
						if (_neighbor != undefined && _neighbor.figure == undefined) {
							_figure_empty_neighbors++;
						}
					}
				}
				_empty_neighbors += _figure_empty_neighbors;
				if (_figure_empty_neighbors == 0) {
					_blocked_figures++;
				}
			}
		}
		return {empty_neighbors: _empty_neighbors, blocked_figures: _blocked_figures};
	}

	get_state_surrounded_figure_count = function(_state, _player) {
		var _count = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _figure = _state.get_figure(_x, _y);
				if (_figure == undefined || _figure.owner_id != _player || _figure.status != "active") {
					continue;
				}
				var _has_empty_neighbor = false;
				for (var _dx = -1; _dx <= 1; _dx++) {
					for (var _dy = -1; _dy <= 1; _dy++) {
						if (_dx == 0 && _dy == 0) {
							continue;
						}
						var _neighbor = _state.get_cell(_x + _dx, _y + _dy);
						if (_neighbor != undefined && _neighbor.figure == undefined) {
							_has_empty_neighbor = true;
							break;
						}
					}
					if (_has_empty_neighbor) {
						break;
					}
				}
				if (!_has_empty_neighbor) {
					_count++;
				}
			}
		}
		return _count;
	}

	begin_bot_scoring = function(_bot_player) {
		var _opponent = get_opponent(_bot_player);
		bot_scoring_baseline = {
			bot_player: _bot_player,
			bot_goal: can_player_reach_goal(Game.game_state, _bot_player),
			opponent_goal: can_player_reach_goal(Game.game_state, _opponent),
			bot_pressure: get_state_surrounding_pressure(Game.game_state, _bot_player),
			opponent_pressure: get_state_surrounding_pressure(Game.game_state, _opponent)
		};
	}

	get_bot_immediate_outcome = function(_descriptor, _result) {
		var _bot_player = _descriptor.player;
		var _opponent = get_opponent(_bot_player);
		var _surrounded_figures = get_state_surrounded_figure_count(_result.next_state, _bot_player);
		var _after_bot_turn = resolve_logic_turn(_result.next_state, _opponent);
		var _immediate_winner = get_state_winner(_after_bot_turn);
		if (_immediate_winner == _opponent) {
			return {loss: true, win: false, own_surrounded: _surrounded_figures, state: _after_bot_turn};
		}
		if (_immediate_winner == _bot_player) {
			return {loss: false, win: true, own_surrounded: _surrounded_figures, state: _after_bot_turn};
		}
		return {loss: false, win: false, own_surrounded: _surrounded_figures, state: _after_bot_turn};
	}

	get_bot_positional_risk = function(_descriptor, _after_bot_turn) {
		var _bot_player = _descriptor.player;
		var _opponent = get_opponent(_bot_player);
		if (bot_scoring_baseline == undefined || bot_scoring_baseline.bot_player != _bot_player) {
			begin_bot_scoring(_bot_player);
		}
		var _before_bot_goal = bot_scoring_baseline.bot_goal;
		var _before_opponent_goal = bot_scoring_baseline.opponent_goal;
		var _after_bot_goal = can_player_reach_goal(_after_bot_turn, _bot_player);
		var _after_opponent_goal = can_player_reach_goal(_after_bot_turn, _opponent);
		var _before_bot_pressure = bot_scoring_baseline.bot_pressure;
		var _before_opponent_pressure = bot_scoring_baseline.opponent_pressure;
		var _after_bot_pressure = get_state_surrounding_pressure(_after_bot_turn, _bot_player);
		var _after_opponent_pressure = get_state_surrounding_pressure(_after_bot_turn, _opponent);
		var _score = 0;
		if (!_before_bot_goal && _after_bot_goal) {
			_score += 350;
		}
		if (!_before_opponent_goal && _after_opponent_goal) {
			_score -= 550;
		}
		_score += (_after_bot_pressure.empty_neighbors - _before_bot_pressure.empty_neighbors) * 18;
		_score -= (_after_opponent_pressure.empty_neighbors - _before_opponent_pressure.empty_neighbors) * 18;
		_score -= (_after_bot_pressure.blocked_figures - _before_bot_pressure.blocked_figures) * 250;
		_score += (_after_opponent_pressure.blocked_figures - _before_opponent_pressure.blocked_figures) * 250;
		return {loss: false, score: _score, bot_goal: _after_bot_goal, opponent_goal: _after_opponent_goal};
	}

	score_effect_action_descriptor = function(_descriptor, _include_position = true) {
		var _result = Game.game_rules.execute(Game.game_state, _descriptor.player, {effect_id: _descriptor.effect_id, inputs: _descriptor.inputs});
		if !_result.ok {
			return -100000;
		}
		var _before = get_bot_state_metrics(Game.game_state, _descriptor.player);
		var _after = get_bot_state_metrics(_result.next_state, _descriptor.player);
		var _before_capture_threat = get_state_enemy_capture_threat(Game.game_state, _descriptor.player);
		var _after_capture_threat = get_state_enemy_capture_threat(_result.next_state, _descriptor.player);
		var _before_capture_defense = get_state_capture_point_defense(Game.game_state, _descriptor.player);
		var _after_capture_defense = get_state_capture_point_defense(_result.next_state, _descriptor.player);
		var _score = 0;
		_score += (_before.enemy_figures - _after.enemy_figures) * 120;
		_score -= (_before.own_figures - _after.own_figures) * 150;
		_score += (_after.own_captured - _before.own_captured) * 140;
		_score -= (_after.enemy_captured - _before.enemy_captured) * 160;
		_score += (_after.enemy_dropped - _before.enemy_dropped) * 120;
		_score -= (_after.own_dropped - _before.own_dropped) * 150;
		_score += (_after.own_progress - _before.own_progress) * 8;
		_score -= (_after.enemy_progress - _before.enemy_progress) * 8;
		_score += (_after.own_zone_figures - _before.own_zone_figures) * 100;
		_score -= (_after.enemy_zone_figures - _before.enemy_zone_figures) * 100;
		_score += (_before_capture_threat - _after_capture_threat) * 70;
		_score += (_after_capture_defense - _before_capture_defense) * 55;
		var _target = variable_struct_exists(_descriptor.inputs, "destination_cell") ? _descriptor.inputs.destination_cell : (variable_struct_exists(_descriptor.inputs, "target_cell") ? _descriptor.inputs.target_cell : undefined);
		if is_array(_target) && array_length(_target) == 2 {
			var _goal_index = _descriptor.player == Game.Player1.player_id ? 1 : 0;
			var _goal_cells = Maps_list.get_cells_for_conquest()[_goal_index];
			for (var _goal_index_in_array = 0; _goal_index_in_array < array_length(_goal_cells); _goal_index_in_array++) {
				if _target[0] == _goal_cells[_goal_index_in_array][0] && _target[1] == _goal_cells[_goal_index_in_array][1] {
					_score += 450;
					break;
				}
			}
		}
		if _descriptor.effect_id == "summon" {
			var _player = Game.game_state.data.players[$ string(_descriptor.player)];
			if is_array(_player.deck) && array_length(_player.deck) > 0 {
				_score += get_bot_figure_value(_player.deck[array_length(_player.deck) - 1]) * 8;
			}
		}
		else if _descriptor.effect_id == "trader_ability" {
			var _event = _result.events[0];
			if _event != undefined && variable_struct_exists(_event, "figure_id") {
				var _figure = _result.next_state.get_figure(_target[0], _target[1]);
				if _figure != undefined {
					_score += get_bot_figure_value(_figure.behaviour) * 15;
				}
			}
		}
		var _immediate_outcome = get_bot_immediate_outcome(_descriptor, _result);
		if (_immediate_outcome.loss) {
			show_debug_message("Bot safety: rejecting effect=" + _descriptor.effect_id + ", immediate loss after move");
			return -1000000;
		}
		if (_immediate_outcome.own_surrounded > 0) {
			return -900000;
		}
		if (_immediate_outcome.win) {
			return _score + 1000000;
		}
		if (_include_position) {
			var _positional_risk = get_bot_positional_risk(_descriptor, _immediate_outcome.state);
			_score += _positional_risk.score;
		}
		return _score;
	}

	export_logic_state = function() {
		return Game.game_state == undefined ? undefined : Game.game_state.clone();
	}

	import_logic_state = function(_state) {
		if _state != undefined && is_struct(_state) && variable_struct_exists(_state, "clone") {
			Game.game_state = _state.clone();
		}
	}

	simulate_action_descriptor = function(_descriptor) {
		if (_descriptor == undefined || !is_struct(_descriptor) || _descriptor.kind != "effect"
		|| Game.game_state == undefined || Game.game_rules == undefined) {
			return undefined;
		}
		var _state = Game.game_state.clone();
		var _result = Game.game_rules.execute(_state, _descriptor.player,
			{effect_id: _descriptor.effect_id, inputs: _descriptor.inputs});
		if !_result.ok {
			return undefined;
		}
		var _next_player = Game.game_rules.get_opponent_id(_result.next_state, _descriptor.player);
		var _turn_result = Game.game_rules.resolve_turn(_result.next_state, _next_player);
		return get_bot_state_metrics(_turn_result.next_state, _descriptor.player);
	}

	score_action_descriptor = function(_descriptor, _include_position = true) {
		if _descriptor.kind == "effect" {
			return score_effect_action_descriptor(_descriptor, _include_position);
		}
		return -100000;
	}

	perform_action_descriptor = function(_descriptor) {
		var _action = create_action_from_descriptor(_descriptor);
		if _action == undefined {
			return false;
		}
		set_action(_action);
		end_move();
		return true;
	}

	end_move = function() {
		if is_turn_transition_active() {
			return;
		}
		pending_authoritative_state = undefined;
		if have_action() and !action_is_ready() {
			show_debug_message("GameLoopController.end_move: skipped unfinished action");
			action = undefined;
		}
		if ready_to_send and Game.online_match and Game.role == "guest" and have_action() {
			if action.type != "effect" {
				show_debug_message("GameplayIntent rejected: only EffectAction is supported by the authoritative protocol");
				O_BoardDraw.unblock_end_button();
				return;
			}
			Game.send_gameplay_intent(action.effect_id, action.inputs);
			action = undefined;
			clear_all();
			turn_timer.stop_count();
			turn_timer.active = 0;
			set_can_cancel(0);
			O_BoardDraw.block_end_button();
			return;
		}
		var _had_action = have_action();
		var _action_result = execute_action();
		if _had_action && (_action_result == undefined || !_action_result.ok) {
			pending_authoritative_state = undefined;
			show_debug_message("GameLoopController.end_move: action was rejected; turn remains with player=" + string(global.turn_owner));
			O_BoardDraw.unblock_end_button();
			return;
		}
		pending_network_animation_batches = _action_result != undefined
			&& variable_struct_exists(_action_result, "animation_batches") ? deep_copy(_action_result.animation_batches) : [];
		if Game.online_match && Game.role == "host" && _action_result != undefined && _action_result.ok {
			pending_authoritative_state = _action_result.next_state == undefined ? undefined : _action_result.next_state.serialize();
		}
		turn_timer.stop_count();
		turn_timer.active = 0;

		clear_all();
		turn_transition_post_processed = false;
		turn_transition_pending = true;
		state = STATE_LIST.animation;
		set_can_cancel(0);
		O_BoardDraw.block_end_button();
		UI_controller.clear_ingame_layer(1)
	}

	// The presenter installs the confirmed state only after every batch finishes.
	complete_turn_state_transition = function() {
		if Game.game_state == undefined {
			return;
		}
		var _next_turn_owner = Game.game_state.data.active_player_id;
		if (_next_turn_owner == undefined
		|| !variable_struct_exists(Game.game_state.data.players, string(_next_turn_owner))) {
			_next_turn_owner = get_opponent(global.turn_owner);
			Game.game_state.data.active_player_id = _next_turn_owner;
			show_debug_message("GameLoopController: restored missing next turn owner=" + string(_next_turn_owner));
		}
		global.turn_owner = _next_turn_owner;
		player1_captured = Game.game_state.data.captured[$ string(Game.Player1.player_id)];
		player2_captured = Game.game_state.data.captured[$ string(Game.Player2.player_id)];
		Game.Player1.able_to_summon = Game.game_state.data.players[$ string(Game.Player1.player_id)].able_to_summon;
		Game.Player2.able_to_summon = Game.game_state.data.players[$ string(Game.Player2.player_id)].able_to_summon;
		figures_counter.player1_field_figures = Game.game_rules.get_active_figure_count(Game.game_state, Game.Player1.player_id);
		figures_counter.player2_field_figures = Game.game_rules.get_active_figure_count(Game.game_state, Game.Player2.player_id);
		figures_counter.sync_from_game_state(Game.game_state);
		figures_counter.update_ui_counter();
	}

	finish_turn_transition = function() {
		if !turn_transition_pending {
			return;
		}
		if !turn_transition_post_processed {
			if Game.field.has_active_animations()
			or (Game.game_state_presenter != undefined and Game.game_state_presenter.is_busy()) {
				return;
			}
			complete_turn_state_transition();
			turn_transition_post_processed = true;
		}
		if Game.field.has_active_animations()
		or (Game.game_state_presenter != undefined and Game.game_state_presenter.is_busy()) {
			return;
		}
		turn_transition_pending = false;
		turn_timer.start_count(Settings.turn_time);
		clear_all();
		if Game.online_match and Game.role == "host" and pending_authoritative_state != undefined and ready_to_send {
			Game.send_authoritative_state(pending_authoritative_state, pending_network_animation_batches);
		}
		pending_authoritative_state = undefined;
		pending_network_animation_batches = [];
		if check_win_conditions() != undefined {
			if Game.online_match {
				if Game.role == "host" {
					Server.send(new ServerMessage(ServerMessageType.GameplayFinish, {winner: check_win_conditions()}));
				}
			}
		else {
				show_debug_message("Match finished: winner=" + get_player_display_name(check_win_conditions()));
				room_goto(R_Main_menu);
			}
		}
		ready_to_send = 1;
	}

	get_player_display_name = function(_player_id) {
		if (_player_id == "" || _player_id == undefined) {
			return "draw";
		}
		if (Game.online_match) {
			if (_player_id == O_Server._id && O_Server._nickname != undefined && string(O_Server._nickname) != "") {
				return string(O_Server._nickname);
			}
			if (_player_id == Game.opponent && O_Server.opponent_nickname != undefined && string(O_Server.opponent_nickname) != "") {
				return string(O_Server.opponent_nickname);
			}
		}
		var _player = get_player(_player_id);
		if (_player != undefined && _player.player_type == "bot") {
			return "Bot";
		}
		if (_player_id == Game.Player1.player_id && O_Server._nickname != undefined && string(O_Server._nickname) != "") {
			return string(O_Server._nickname);
		}
		return "Player " + string(_player_id);
	}

	step = function() {
		finish_turn_transition();
	}

	set_action = function(new_action) {
		action = new_action;
	}

	have_action = function() {
		return action != undefined
	}

	action_is_ready = function() {
		return action != undefined && (!variable_struct_exists(action, "ready") || action.ready);
	}

	get_opponent = function(player) {
		if Game.game_state != undefined && Game.game_rules != undefined {
			return Game.game_rules.get_opponent_id(Game.game_state, player);
		}
		if player = Game.Player1.player_id {
			return Game.Player2.player_id
		}
		else {
			return Game.Player1.player_id
		}
	}

	choose_cell_for_summon = function() {
		if have_action() {
			if action.type == "effect" && action.effect_id == "summon" {
				if Game.input_session.clicked_cell == undefined
				or !action.set_new_target_coordinates(Game.input_session.clicked_cell.xcord, Game.input_session.clicked_cell.ycord) {
					return;
				}
				if Game.input_session.selected_cell != undefined {
					Game.input_session.selected_cell.filled_figure_status.set_status("will_be_summoned", 0);
					Game.input_session.selected_cell.marked = 1;
				}
				Game.input_session.selected_cell = Game.input_session.clicked_cell;
				Game.input_session.clicked_cell.marked = 0;
				Game.input_session.clicked_cell.filled_figure_status.set_status("will_be_summoned", 1);
			}
			return;
		}
		if Game.summon_controller == undefined {
			return;
		}
		Game.input_session.clicked_cell.filled_figure_status.set_status("will_be_summoned", 1)
		if Game.input_session.selected_cell == undefined {
			Game.input_session.clicked_cell.marked = 0;

			Game.input_session.selected_cell = Game.input_session.clicked_cell;
			Game.summon_controller.start_summon(Game.input_session.clicked_cell.xcord, Game.input_session.clicked_cell.ycord);
		}
		else {
			Game.input_session.selected_cell.filled_figure_status.set_status("will_be_summoned", 0)
			Game.input_session.selected_cell.marked = 1;
			Game.input_session.selected_cell = Game.input_session.clicked_cell;
			Game.input_session.clicked_cell.marked = 0;
			action.set_new_target_coordinates(Game.input_session.clicked_cell.xcord, Game.input_session.clicked_cell.ycord);
		}
	}
	cancel_action = function() {
		if !is_local_turn() {
			state = STATE_LIST.enemy_turn;
			set_can_cancel(0);
			return;
		}
		clear_all();
		figures_counter.update_turn();
	}

	mark_active_figures = function() {
		if !is_human_turn() {
			return;
		}
		if Game.game_state == undefined {
			return;
		}
		for (var _x = 0; _x < Game.game_state.data.width; _x++) {
			for (var _y = 0; _y < Game.game_state.data.height; _y++) {
				var _figure = Game.game_state.get_figure(_x, _y);
				if _figure != undefined && string(_figure.owner_id) == string(global.turn_owner) && _figure.status == "active" {
					var _cell = Game.field.get_cell(_x, _y);
					if _cell != undefined {
						_cell.marked = true;
					}
				}
			}
		}
		Game.input_session.mark_sprite = S_Controlled_mark;
	}

	quit_from_action = function() {
		clean_controllers();
		O_BoardDraw.clear();
		Game.field.clear_all_marks();
		global.using_ability = 1;
		Game.input_session.clicked_cell = Game.input_session.selected_cell;
		Game.figure_action_controller = new FigureActionController()
		action = undefined;
	}

	execute_action = function() {
		if have_action() {
			//Game.game_data.save_action(action.export())
			return action.execute();
		}
		if (Game.game_state == undefined || Game.game_rules == undefined) {
			return {ok: true, animation_batches: []};
		}
		var _next_player = Game.game_rules.get_opponent_id(Game.game_state, global.turn_owner);
		var _turn_result = Game.game_rules.resolve_turn(Game.game_state, _next_player);
		if Game.game_state_presenter != undefined {
			Game.game_state_presenter.commit(_turn_result.next_state, _turn_result.animation_batches);
		}
		return {ok: true, next_state: _turn_result.next_state, animation_batches: _turn_result.animation_batches, events: _turn_result.events};
	}

	clean_controllers = function() {
		Game.ability_input_controller = undefined;
		Game.move_input_controller = undefined;
		Game.figure_action_controller = undefined;
		Game.summon_controller = undefined;
		if is_local_turn() {
			state = STATE_LIST.wait;
		}
		else {
			state = STATE_LIST.enemy_turn;
		}
	}

	default_cell_click_action = function(cell) {
		if (cell_is_playable(cell)) {
			select_movable_figure(cell);
		}
	}
	cell_is_playable = function(cell) {
		if is_turn_transition_active() || state != STATE_LIST.wait || !is_human_turn() || cell == undefined || Game.game_state == undefined {
			return false;
		}
		var _state_figure = Game.game_state.get_figure(cell.xcord, cell.ycord);
		return _state_figure != undefined
			&& string(_state_figure.owner_id) == string(global.turn_owner)
			&& _state_figure.status == "active";
	}
	select_movable_figure = function(cell) {
		Game.input_session.select(cell);
		set_can_cancel(1);
		O_BoardDraw.figure_click();
	}

	clear_all = function() {
		clean_controllers();
		O_BoardDraw.clear();
		Game.input_session.selected_cell = undefined;
		Game.field.clear_all_marks();
		Game.field.clear_every_status();
		Game.input_session.clicked_cell = undefined;
		set_can_cancel(0);
		Game.input_session.set_handler(default_cell_click_action);
		action = undefined;
		global.able_to_summon = false;
		if is_local_turn() {
			state = STATE_LIST.wait;
		}
		else {
			state = STATE_LIST.enemy_turn;
		}
		mark_active_figures();
	}

	check_win_conditions = function() {
		if Game.game_state != undefined {
			var _state_winner = get_state_winner(Game.game_state);
			if _state_winner != undefined {
				return _state_winner;
			}
		}
		if turn_timer.player_out_of_time != undefined {
			return get_opponent(global.turn_owner);
		}
		return undefined;
	}

	add_captured_figure = function(player) {
		if player = Game.Player1.player_id {
			player1_captured ++;
		}
		else if player == Game.Player2.player_id{
			player2_captured ++;
		}
	}

	Game.input_session.set_handler(default_cell_click_action);
}
