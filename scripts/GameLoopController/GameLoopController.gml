// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
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
	export_data = undefined;
	action_export_data = [];
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
		var _load_data = Game.user_data.load(_player);
		if !is_struct(_load_data) or !variable_struct_exists(_load_data, "player_figures") {
			return undefined;
		}
		var _figures = _load_data.player_figures;
		if !is_array(_figures) or array_length(_figures) <= 0 {
			return undefined;
		}
		return _figures[array_length(_figures) - 1];
	}

	get_summon_target_cells = function(_player) {
		return Game.field.get_controlled_summon_cells(_player);
	}

	get_move_target_cells = function(_from_cell) {
		return get_move_target_cells_data(_from_cell).cells;
	}

	get_move_target_cells_data = function(_from_cell) {
		if _from_cell == undefined or !_from_cell.is_filled() {
			return {cells: [], blocked_previous_cell: undefined};
		}
		var _figure = _from_cell.filled_figure;
		var _move_ability = Behaviours.get_move_ability(_figure.behaviour);
		var _cells = [];
		if _move_ability == ArcherMoveAbility {
			var _previous_marks = Game.field.export_marks();
			var _ability = new ArcherMoveAbility(_from_cell.xcord, _from_cell.ycord, undefined, undefined, 0, true);
			_ability.check_all_cells();
			_cells = Game.field.get_marked_cells();
			Game.field.import_marks(_previous_marks);
		}
		else {
			_cells = Game.field.get_clear_move_cells(_from_cell.xcord, _from_cell.ycord);
		}
		var _previous_cell = Game.field.check_movement_array(_figure.figure_id);
		var _previous_index = array_get_index(_cells, _previous_cell);
		var _blocked_previous_cell = undefined;
		if _previous_index != -1 {
			_blocked_previous_cell = _previous_cell;
			array_delete(_cells, _previous_index, 1);
		}
		return {cells: _cells, blocked_previous_cell: _blocked_previous_cell};
	}

	get_adjacent_filled_cells = function(_xcord, _ycord, _excluded_cell = undefined, _enemy_of = undefined) {
		var _cells = [];
		for (var i = -1; i <= 1; i++) {
			for (var m = -1; m <= 1; m++) {
				var _cell = Game.field.get_cell(_xcord + i, _ycord + m);
				if _cell != undefined and _cell != _excluded_cell and _cell.is_filled() and !_cell.filled_figure.state.is_conquesting
				and (_enemy_of == undefined or _cell.filled_figure.owner != _enemy_of) {
					array_push(_cells, _cell);
				}
			}
		}
		return _cells;
	}

	get_adjacent_ability_target_cells = function(_from_cell, _enemy_only = false) {
		var _enemy_of = undefined;
		if _enemy_only {
			_enemy_of = _from_cell.filled_figure.owner;
		}
		return get_adjacent_filled_cells(_from_cell.xcord, _from_cell.ycord, _from_cell, _enemy_of);
	}

	get_spearman_ability_target_cells = function(_from_cell) {
		var _cells = [];
		var _dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
		for (var i = 0; i < array_length(_dirs); i++) {
			var _middle = Game.field.get_cell(_from_cell.xcord + _dirs[i][0], _from_cell.ycord + _dirs[i][1]);
			var _target = Game.field.get_cell(_from_cell.xcord + _dirs[i][0] * 2, _from_cell.ycord + _dirs[i][1] * 2);
			if _middle != undefined and _target != undefined and !_middle.is_filled() and !_target.is_filled() {
				array_push(_cells, _target);
			}
		}
		var _previous_cell = Game.field.check_movement_array(_from_cell.filled_figure.figure_id);
		var _previous_index = array_get_index(_cells, _previous_cell);
		if _previous_index != -1 {
			array_delete(_cells, _previous_index, 1);
		}
		return _cells;
	}

	get_trader_ability_choices = function(_player) {
		var _choices = [];
		var _load_data = Game.user_data.load(_player);
		if !is_struct(_load_data) or !variable_struct_exists(_load_data, "player_figures") or !is_array(_load_data.player_figures) {
			return _choices;
		}
		var _figures = _load_data.player_figures;
		if array_length(_figures) < 3 {
			return _choices;
		}
		for (var i = 0; i < 3; i++) {
			array_push(_choices, _figures[array_length(_figures) - 1 - i]);
		}
		return _choices;
	}

	get_ability_target_cells = function(_from_cell) {
		if _from_cell == undefined or !_from_cell.is_filled() {
			return [];
		}
		var _ability = Behaviours.get_ablility(_from_cell.filled_figure.behaviour);
		if _ability == undefined {
			return [];
		}
		if _ability == WarriorAbility {
			return get_adjacent_ability_target_cells(_from_cell, true);
		}
		if _ability == SpearmanAbility {
			return get_spearman_ability_target_cells(_from_cell);
		}
		if _ability == ShieldbearerAbility {
			return get_adjacent_ability_target_cells(_from_cell);
		}
		if _ability == TraderAbility {
			if array_length(get_trader_ability_choices(_from_cell.filled_figure.owner)) < 3 {
				return [];
			}
			return get_summon_target_cells(_from_cell.filled_figure.owner);
		}
		var _previous_marks = Game.field.export_marks();
		var _test_ability = new _ability(_from_cell.filled_figure, _from_cell, true);
		_test_ability.check_ability_targets(1, 1);
		var _cells = Game.field.get_marked_cells();
		Game.field.import_marks(_previous_marks);
		return _cells;
	}

	get_summon_action_descriptors = function(_player) {
		var _actions = [];
		if Game.game_state == undefined || Game.game_rules == undefined {
			return _actions;
		}
		var _player_key = string(_player);
		if !variable_struct_exists(Game.game_state.data.players, _player_key) {
			return _actions;
		}
		var _state_player = Game.game_state.data.players[$ _player_key];
		if !_state_player.able_to_summon || !is_array(_state_player.deck) || array_length(_state_player.deck) <= 0 {
			return _actions;
		}
		var _specs = Game.game_rules.get_inputs(Game.game_state, _player, "summon", {});
		if array_length(_specs) <= 0 || !is_array(_specs[0].allowed_cells) {
			return _actions;
		}
		var _behaviour = _state_player.deck[array_length(_state_player.deck) - 1];
		var _cells = _specs[0].allowed_cells;
		for (var i = 0; i < array_length(_cells); i++) {
			array_push(_actions, {
				kind: "summon",
				player: _player,
				behaviour: _behaviour,
				target_x: _cells[i][0],
				target_y: _cells[i][1]
			});
		}
		return _actions;
	}

	get_move_action_descriptors = function(_player) {
		var _actions = [];
		var _from_cells = Game.field.get_filled_cells(_player);
		for (var i = 0; i < array_length(_from_cells); i++) {
			var _from_cell = _from_cells[i];
			if !_from_cell.filled_figure.state.is_active {
				continue;
			}
			var _move_ability = Behaviours.get_move_ability(_from_cell.filled_figure.behaviour);
			var _target_cells = get_move_target_cells(_from_cell);
			for (var m = 0; m < array_length(_target_cells); m++) {
				array_push(_actions, {
					kind: "move",
					player: _player,
					action_constructor: _move_ability,
					from_x: _from_cell.xcord,
					from_y: _from_cell.ycord,
					target_x: _target_cells[m].xcord,
					target_y: _target_cells[m].ycord
				});
				if _move_ability == WarriorMoveAndAbility {
					var _ability_targets = get_adjacent_filled_cells(_target_cells[m].xcord, _target_cells[m].ycord, _from_cell, _from_cell.filled_figure.owner);
					for (var a = 0; a < array_length(_ability_targets); a++) {
						array_push(_actions, {
							kind: "move_ability_warrior",
							player: _player,
							from_x: _from_cell.xcord,
							from_y: _from_cell.ycord,
							target_x: _target_cells[m].xcord,
							target_y: _target_cells[m].ycord,
							ability_target_x: _ability_targets[a].xcord,
							ability_target_y: _ability_targets[a].ycord
						});
					}
				}
			}
		}
		return _actions;
	}

	get_ability_action_descriptors = function(_player) {
		var _actions = [];
		var _from_cells = Game.field.get_filled_cells(_player);
		for (var i = 0; i < array_length(_from_cells); i++) {
			var _from_cell = _from_cells[i];
			if !_from_cell.filled_figure.state.is_active {
				continue;
			}
			var _ability = Behaviours.get_ablility(_from_cell.filled_figure.behaviour);
			if _ability == undefined {
				continue;
			}
			if _ability == TraderAbility {
				var _choices = get_trader_ability_choices(_player);
				var _target_cells = get_ability_target_cells(_from_cell);
				for (var c = 0; c < array_length(_choices); c++) {
					for (var t = 0; t < array_length(_target_cells); t++) {
						array_push(_actions, {
							kind: "ability_trader",
							player: _player,
							from_x: _from_cell.xcord,
							from_y: _from_cell.ycord,
							chosen_button: c,
							behaviour: _choices[c],
							target_x: _target_cells[t].xcord,
							target_y: _target_cells[t].ycord
						});
					}
				}
				continue;
			}
			if _ability == ShieldbearerAbility {
				var _target_cells = get_ability_target_cells(_from_cell);
				var _fill_cells = Game.field.get_clear_move_cells(_from_cell.xcord, _from_cell.ycord);
				for (var t = 0; t < array_length(_target_cells); t++) {
					for (var f = 0; f < array_length(_fill_cells); f++) {
						array_push(_actions, {
							kind: "ability_shieldbearer",
							player: _player,
							from_x: _from_cell.xcord,
							from_y: _from_cell.ycord,
							target_x: _target_cells[t].xcord,
							target_y: _target_cells[t].ycord,
							fill_x: _fill_cells[f].xcord,
							fill_y: _fill_cells[f].ycord
						});
					}
				}
				continue;
			}
			var _target_cells = get_ability_target_cells(_from_cell);
			for (var m = 0; m < array_length(_target_cells); m++) {
				array_push(_actions, {
					kind: "ability",
					player: _player,
					action_constructor: _ability,
					from_x: _from_cell.xcord,
					from_y: _from_cell.ycord,
					target_x: _target_cells[m].xcord,
					target_y: _target_cells[m].ycord
				});
			}
		}
		return _actions;
	}

	/// Builds executable intents from the same input specs the human UI renders.
	/// The queue is bounded because every input is a finite cell/choice set.
	get_effect_action_descriptors = function(_player) {
		var _actions = [];
		if Game.game_state == undefined || Game.game_rules == undefined {
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
				var _specs = Game.game_rules.get_inputs(Game.game_state, _player, _effect_id, _inputs);
				var _next_spec = undefined;
				for (var _spec_index = 0; _spec_index < array_length(_specs); _spec_index++) {
					if !variable_struct_exists(_inputs, _specs[_spec_index].id) {
						_next_spec = _specs[_spec_index];
						break;
					}
				}
				if _next_spec == undefined {
					var _check = Game.game_rules.execute(Game.game_state, _player, {effect_id: _effect_id, inputs: _inputs});
					if _check.ok {
						array_push(_actions, {kind: "effect", effect_id: _effect_id, player: _player, inputs: deep_copy(_inputs)});
						if _effect_id == "warrior_move" && variable_struct_exists(_inputs, "target_cell") {
							var _warrior_move_effect = Game.game_rules.get_effect("warrior_move");
							var _strike_cells = _warrior_move_effect.get_strike_cells(Game.game_state, _player, _inputs.target_cell);
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

	get_legal_action_descriptors = function(_player) {
		return get_effect_action_descriptors(_player);
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
		var _skip_ui = _simulation or !is_human_turn();
		if _descriptor.kind == "effect" {
			return new EffectAction(_descriptor.effect_id, _descriptor.player, _descriptor.inputs);
		}
		if _descriptor.kind == "summon" {
			var _behaviour = _descriptor.behaviour;
			if !_simulation {
				var _load_data = Game.user_data.load(_descriptor.player);
				if is_struct(_load_data) and variable_struct_exists(_load_data, "player_figures") and is_array(_load_data.player_figures) and array_length(_load_data.player_figures) > 0 {
					_behaviour = array_pop(_load_data.player_figures);
					Game.user_data.save(_descriptor.player, _load_data);
				}
			}
			return new SummonAction(_descriptor.target_x, _descriptor.target_y, Behaviours.get_sprite(_behaviour), _behaviour, _skip_ui);
		}
		if _descriptor.kind == "move" {
			var _action_constructor = _descriptor.action_constructor;
			if _action_constructor == WarriorMoveAndAbility {
				return new WarriorMoveAndAbility(_descriptor.from_x, _descriptor.from_y, _descriptor.target_x, _descriptor.target_y, undefined, _skip_ui);
			}
			return new _action_constructor(_descriptor.from_x, _descriptor.from_y, _descriptor.target_x, _descriptor.target_y, undefined, _skip_ui);
		}
		if _descriptor.kind == "move_ability_warrior" {
			var _from_cell = Game.field.get_cell(_descriptor.from_x, _descriptor.from_y);
			var _target_cell = Game.field.get_cell(_descriptor.ability_target_x, _descriptor.ability_target_y);
			if _from_cell == undefined or !_from_cell.is_filled() or _target_cell == undefined or !_target_cell.is_filled()
			or _target_cell.filled_figure.owner == _from_cell.filled_figure.owner {
				return undefined;
			}
			var _action = new WarriorMoveAndAbility(_descriptor.from_x, _descriptor.from_y, _descriptor.target_x, _descriptor.target_y, undefined, _skip_ui);
			_action.using_ability = true;
			_action.target_cell = _target_cell;
			return _action;
		}
		if _descriptor.kind == "ability" {
			var _from_cell = Game.field.get_cell(_descriptor.from_x, _descriptor.from_y);
			var _target_cell = Game.field.get_cell(_descriptor.target_x, _descriptor.target_y);
			var _action_constructor = _descriptor.action_constructor;
			var _action = new _action_constructor(_from_cell.filled_figure, _from_cell, _skip_ui);
			_action.set_target(_target_cell.filled_figure, _target_cell);
			return _action;
		}
		if _descriptor.kind == "ability_shieldbearer" {
			var _from_cell = Game.field.get_cell(_descriptor.from_x, _descriptor.from_y);
			var _target_cell = Game.field.get_cell(_descriptor.target_x, _descriptor.target_y);
			var _fill_cell = Game.field.get_cell(_descriptor.fill_x, _descriptor.fill_y);
			var _action = new ShieldbearerAbility(_from_cell.filled_figure, _from_cell, _skip_ui);
			_action.target_cell = _target_cell;
			_action.target_figure = _target_cell.filled_figure;
			_action.fill_cell = _fill_cell;
			_action.selected = true;
			return _action;
		}
		if _descriptor.kind == "ability_trader" {
			var _from_cell = Game.field.get_cell(_descriptor.from_x, _descriptor.from_y);
			var _target_cell = Game.field.get_cell(_descriptor.target_x, _descriptor.target_y);
			var _action = new TraderAbility(_from_cell.filled_figure, _from_cell, _skip_ui);
			_action.buttons = [];
			var _load_data = Game.user_data.load(_descriptor.player);
			if is_struct(_load_data) and variable_struct_exists(_load_data, "player_figures") and is_array(_load_data.player_figures) {
				if array_length(_load_data.player_figures) < 3 {
					return undefined;
				}
				if _simulation {
					_action.buttons = get_trader_ability_choices(_descriptor.player);
				}
				else {
					for (var i = 0; i < 3; i++) {
						_action.buttons[i] = array_pop(_load_data.player_figures);
					}
					Game.user_data.save(_descriptor.player, _load_data);
				}
			}
			_action.chosen_button = _descriptor.chosen_button;
			_action.target_cell = _target_cell;
			return _action;
		}
		return undefined;
	}

	get_bot_metrics = function(_player) {
		var _opponent = get_opponent(_player);
		var _own_figures = 0;
		var _enemy_figures = 0;
		var _own_progress = 0;
		var _enemy_progress = 0;
		var _own_zone_figures = 0;
		var _enemy_zone_figures = 0;
		var _targets = Maps_list.get_cells_for_conquest();
		var _own_target_index = 0;
		if (_player == Game.Player1.player_id) {
			_own_target_index = 1;
		}
		var _enemy_target_index = 1 - _own_target_index;
		for (var _grid_y = 0; _grid_y < Game.field.field_height; _grid_y++) {
			for (var _grid_x = 0; _grid_x < Game.field.field_width; _grid_x++) {
				var _cell = Game.field.get_cell(_grid_x, _grid_y);
				if !_cell.is_filled() or !_cell.filled_figure.state.is_active {
					continue;
				}
				var _is_own = _cell.filled_figure.owner == _player;
				var _progress = _grid_y;
				if (_is_own && _player == Game.Player1.player_id) or (!_is_own && _opponent == Game.Player1.player_id) {
					_progress = Game.field.field_height - 1 - _grid_y;
				}
				if _is_own {
					_own_figures++;
					_own_progress += _progress;
				}
				else {
					_enemy_figures++;
					_enemy_progress += _progress;
				}
				for (var i = 0; i < array_length(_targets[_own_target_index]); i++) {
					if (_grid_x == _targets[_own_target_index][i][0] && _grid_y == _targets[_own_target_index][i][1] && _is_own) {
						_own_zone_figures++;
					}
				}
				for (var i = 0; i < array_length(_targets[_enemy_target_index]); i++) {
					if (_grid_x == _targets[_enemy_target_index][i][0] && _grid_y == _targets[_enemy_target_index][i][1] && !_is_own) {
						_enemy_zone_figures++;
					}
				}
			}
		}
		var _own_captured = player1_captured;
		var _enemy_captured = player2_captured;
		if (_player == Game.Player2.player_id) {
			_own_captured = player2_captured;
			_enemy_captured = player1_captured;
		}
		return {
			own_figures: _own_figures,
			enemy_figures: _enemy_figures,
			own_progress: _own_progress,
			enemy_progress: _enemy_progress,
			own_zone_figures: _own_zone_figures,
			enemy_zone_figures: _enemy_zone_figures,
			own_captured: _own_captured,
			enemy_captured: _enemy_captured
		};
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

	score_effect_action_descriptor = function(_descriptor) {
		var _result = Game.game_rules.execute(Game.game_state, _descriptor.player, {effect_id: _descriptor.effect_id, inputs: _descriptor.inputs});
		if !_result.ok {
			return -100000;
		}
		var _before = get_bot_state_metrics(Game.game_state, _descriptor.player);
		var _after = get_bot_state_metrics(_result.next_state, _descriptor.player);
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
		return _score;
	}

	export_logic_state = function() {
		return {
			field: Game.field.export(),
			movement_array: json_parse(json_stringify(Game.field.movement_array)),
			player1_captured: player1_captured,
			player2_captured: player2_captured,
			figures_counter: figures_counter.export(),
			player1_able_to_summon: Game.Player1.able_to_summon,
			player2_able_to_summon: Game.Player2.able_to_summon
		};
	}

	import_logic_state = function(_state) {
		Game.field.import(_state.field);
		Game.field.movement_array = _state.movement_array;
		player1_captured = _state.player1_captured;
		player2_captured = _state.player2_captured;
		figures_counter.player1_field_figures = _state.figures_counter.ex_player1_field_figures;
		figures_counter.player2_field_figures = _state.figures_counter.ex_player2_field_figures;
		figures_counter.figures_id_counter = _state.figures_counter.ex_figures_id_counter;
		figures_counter.figures_to_capture = [];
		Game.Player1.able_to_summon = _state.player1_able_to_summon;
		Game.Player2.able_to_summon = _state.player2_able_to_summon;
	}

	simulate_action_descriptor = function(_descriptor) {
		var _state = export_logic_state();
		var _was_simulating = Game.is_simulating;
		Game.is_simulating = true;
		var _action = create_action_from_descriptor(_descriptor, true);
		var _metrics = undefined;
		if (_action != undefined) {
			_action.execute();
			Game.field.check_conquested_cells();
			Game.field.check_every_figure();
			figures_counter.update_captured_figures_array();
			Game.field.check_dropped_figures();
			_metrics = get_bot_metrics(_descriptor.player);
		}
		Game.is_simulating = _was_simulating;
		import_logic_state(_state);
		return _metrics;
	}

	score_action_descriptor = function(_descriptor) {
		if _descriptor.kind == "effect" {
			return score_effect_action_descriptor(_descriptor);
		}
		var _before = get_bot_metrics(_descriptor.player);
		var _after = simulate_action_descriptor(_descriptor);
		if (_after == undefined) {
			return -100000;
		}
		var _score = 0;
		_score += (_before.enemy_figures - _after.enemy_figures) * 120;
		_score -= (_before.own_figures - _after.own_figures) * 150;
		_score += (_after.own_captured - _before.own_captured) * 140;
		_score -= (_after.enemy_captured - _before.enemy_captured) * 160;
		_score += (_after.own_progress - _before.own_progress) * 8;
		_score -= (_after.enemy_progress - _before.enemy_progress) * 8;
		_score += (_after.own_zone_figures - _before.own_zone_figures) * 100;
		_score -= (_after.enemy_zone_figures - _before.enemy_zone_figures) * 100;
		if (_descriptor.kind == "summon") {
			_score += get_bot_figure_value(_descriptor.behaviour) * 8;
		}
		else if (_descriptor.kind == "ability_trader") {
			_score += get_bot_figure_value(_descriptor.behaviour) * 15;
		}
		if variable_struct_exists(_descriptor, "target_x") && variable_struct_exists(_descriptor, "target_y") {
			var _goal_index = _descriptor.player == Game.Player1.player_id ? 1 : 0;
			var _goal_cells = Maps_list.get_cells_for_conquest()[_goal_index];
			for (var _goal_index_in_array = 0; _goal_index_in_array < array_length(_goal_cells); _goal_index_in_array++) {
				if _descriptor.target_x == _goal_cells[_goal_index_in_array][0] && _descriptor.target_y == _goal_cells[_goal_index_in_array][1] {
					_score += 450;
					break;
				}
			}
		}
		if (variable_struct_exists(_descriptor, "from_y") && variable_struct_exists(_descriptor, "target_y")) {
			var _direction = 1;
			if (_descriptor.player == Game.Player1.player_id) {
				_direction = -1;
			}
			var _advance = (_descriptor.target_y - _descriptor.from_y) * _direction;
			_score += _advance * 10;
			if (_advance <= 0 && _before.enemy_figures == _after.enemy_figures) {
				_score -= 25;
			}
		}
		return _score;
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
		export_data = undefined;
		if have_action() and !action_is_ready() {
			show_debug_message("GameLoopController.end_move: skipped unfinished action");
			action = undefined;
		}
		if ready_to_send and Game.online_match and have_action(){
			if O_Server._id == global.turn_owner{
				action_export_data = [action.export()]
				export_data = [export(), action_export_data]
			}
			else {
				export_data = undefined;
			}
		}
		var _had_action = have_action();
		var _action_result = execute_action();
		if _had_action && (_action_result == undefined || !_action_result.ok) {
			export_data = undefined;
			show_debug_message("GameLoopController.end_move: action was rejected; turn remains with player=" + string(global.turn_owner));
			O_BoardDraw.unblock_end_button();
			return;
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

	// The presenter keeps the old Field alive while its batches animate.  Only
	// after it has installed the resulting state may the turn transition inspect it.
	complete_turn_state_transition = function() {
		global.turn_owner = get_opponent(global.turn_owner);
		Game.field.check_conquested_cells();
		Game.field.check_every_figure();
		Game.field.check_dropped_figures();
		figures_counter.update_turn();
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
		Game.sync_game_state_from_legacy();
		turn_transition_pending = false;
		turn_timer.start_count(Settings.turn_time);
		clear_all();
		if Game.online_match and export_data != undefined and ready_to_send {
			Game.send_turn(export_data[0], export_data[1]);
		}
		export_data = undefined;
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
		if action == undefined {
			return false;
		}
		if variable_struct_exists(action, "type") and action.type == "summon" {
			return action.target_x != undefined and action.target_y != undefined and Game.field.get_cell(action.target_x, action.target_y) != undefined;
		}
		if variable_struct_exists(action, "to_x") and variable_struct_exists(action, "to_y") {
			return action.to_x != undefined and action.to_y != undefined and Game.field.get_cell(action.to_x, action.to_y) != undefined;
		}
		if variable_struct_exists(action, "target") {
			return action.target != undefined;
		}
		if variable_struct_exists(action, "target_cell") {
			if !variable_struct_exists(action, "using_ability") or action.using_ability {
				if action.target_cell == undefined {
					return false;
				}
			}
		}
		if variable_struct_exists(action, "cell_for_move") and action.cell_for_move == undefined {
			return false;
		}
		if variable_struct_exists(action, "fill_cell") and action.fill_cell == undefined {
			return false;
		}
		return true;
	}

	get_opponent = function(player) {
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
				global.selected_cell.filled_figure_status.set_status("will_be_summoned", 0);
				global.selected_cell.marked = 1;
				global.selected_cell = global.cell_click_callback;
				global.cell_click_callback.marked = 0;
				global.cell_click_callback.filled_figure_status.set_status("will_be_summoned", 1);
				action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
			}
			return;
		}
		if Game.summon_controller == undefined {
			return;
		}
		global.cell_click_callback.filled_figure_status.set_status("will_be_summoned", 1)
		if global.selected_cell == undefined {
			global.cell_click_callback.marked = 0;

			global.selected_cell = global.cell_click_callback;
			Game.summon_controller.start_summon(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		}
		else {
			global.selected_cell.filled_figure_status.set_status("will_be_summoned", 0)
			global.selected_cell.marked = 1;
			global.selected_cell = global.cell_click_callback;
			global.cell_click_callback.marked = 0;
			action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
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
		cells = Game.field.get_filled_cells(global.turn_owner)
		for (i = 0; i < array_length(cells); i++) {
			if cells[i].filled_figure.state.is_active {cells[i].marked = 1}
		}
		global.mark = S_Controlled_mark;
	}

	quit_from_action = function() {
		clean_controllers();
		O_BoardDraw.clear();
		Game.field.clear_all_marks();
		global.using_ability = 1;
		global.cell_click_callback = global.selected_cell;
		Game.figure_action_controller = new FigureActionController()
		action = undefined;
	}

	execute_action = function() {
		if have_action() {
			//Game.game_data.save_action(action.export())
			return action.execute();
		}
		return {ok: true, animation_batches: []};
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
		return (!is_turn_transition_active() and state == STATE_LIST.wait and is_human_turn() and cell.is_filled() and
				cell.filled_figure.owner == global.turn_owner and
				cell.filled_figure.state.is_active);
	}
	select_movable_figure = function(cell) {
		global.cell_click_callback = cell;
		global.selected_cell = cell;
		set_can_cancel(1);
		O_BoardDraw.figure_click(cell.filled_figure)
	}

	clear_all = function() {
		clean_controllers();
		O_BoardDraw.clear();
		global.selected_cell = undefined;
		Game.field.clear_all_marks();
		Game.field.clear_every_status();
		global.cell_click_callback = undefined;
		set_can_cancel(0);
		global.cell_action = default_cell_click_action;
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
		if player1_captured >= 4 and player2_captured >= 4 {return ""}
		else {
			if player1_captured >= 4 {return Game.Player1.player_id}
			if player2_captured >= 4 {return Game.Player2.player_id}
		}
		if figures_counter.get_summon_figures_amount(Game.Player1.player_id) == 0 and
		figures_counter.get_field_figures(Game.Player1.player_id) == 0 {return Game.Player2.player_id}
		if figures_counter.get_summon_figures_amount(Game.Player2.player_id) == 0 and
		figures_counter.get_field_figures(Game.Player2.player_id) == 0 {return Game.Player1.player_id}
		if turn_timer.player_out_of_time != undefined {
			if global.turn_owner == Game.Player1.player_id {return Game.Player1.player_id}
			else {return Game.Player2.player_id}
		}
		out_of_figures = 0
		if figures_counter.get_summon_figures_amount(Game.Player1.player_id) == 0 and
		Game.field.get_active_player_field_figures(Game.Player1.player_id) == 0 {out_of_figures++}
		if figures_counter.get_summon_figures_amount(Game.Player2.player_id) == 0 and
		Game.field.get_active_player_field_figures(Game.Player2.player_id) == 0 {out_of_figures++}
		if out_of_figures == 2 {
			if player1_captured > player2_captured {return Game.Player1.player_id}
			if player2_captured > player1_captured {return Game.Player2.player_id}
			if player1_captured == player2_captured {return ""}
		}

		return undefined
	}

	add_captured_figure = function(player) {
		if player = Game.Player1.player_id {
			player1_captured ++;
		}
		else if player == Game.Player2.player_id{
			player2_captured ++;
		}
	}

	export = function(_additional_data = undefined) {
		export_data = {
			ex_turn_owner: global.turn_owner,
			ex_player1_captured: player1_captured,
			ex_player2_captured: player2_captured,
			ex_timer_struct: turn_timer.export(),
			ex_figures_counter_struct: figures_counter.export(),
			ex_gamefield: Game.field.export(),
			ex_player1_figures: Game.user_data.load(Game.Player1.player_id),
			ex_player2_figures: Game.user_data.load(Game.Player2.player_id),
			ex_state: state,
			additional_data: _additional_data,
			import_field: true
		}
		return export_data
	}

	import = function(import_data) {
		clear_all();
		global.turn_owner = import_data.ex_turn_owner;
		player1_captured = import_data.ex_player1_captured;
		player2_captured = import_data.ex_player2_captured;
		turn_timer.import(import_data.ex_timer_struct);
		figures_counter.import(import_data.ex_figures_counter_struct);
		Game.field.import(import_data.ex_gamefield);
		Game.user_data.save(Game.Player1.player_id, import_data.ex_player1_figures);
		Game.user_data.save(Game.Player2.player_id, import_data.ex_player2_figures);

	}

	import_action = function(import_struct) {
		clear_all();
		//global.turn_owner = import_struct.ex_turn_owner;
		switch import_struct.ex_type{
		case "act_ability":
			action = new import_struct.ex_action(undefined, undefined, true);
			action.import(import_struct);
			break;
		case "move_ability":
			action = new import_struct.ex_action(import_struct.ex_from_x, import_struct.ex_from_y,
			import_struct.ex_to_x, import_struct.ex_to_y, undefined, true);
			action.import(import_struct);
			break;
		case "summon":
			action = new import_struct.ex_action(import_struct.ex_target_x, import_struct.ex_target_y, undefined, undefined, true);
			action.import(import_struct);
			break;
		case "get_field_figure":
			action = new import_struct.ex_action(true);
			action.import(import_struct);
			break;
		case "effect":
			action = new EffectAction(import_struct.ex_effect_id, import_struct.ex_actor_id, import_struct.ex_inputs);
			action.import(import_struct);
			break;
		}
		ready_to_send = 0;
		end_move();
	}

	global.cell_action = default_cell_click_action;
}
