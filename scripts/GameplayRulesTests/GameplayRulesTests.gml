function GameplayRulesTests(_suite) constructor {
	suite = _suite;
	rules = new GameRules();

	make_state = function(_deck1 = ["spearman"], _deck2 = ["archer"], _active = 1) {
		return rules.create_match_state("map1", {player_id: 1}, {player_id: 2}, _deck1, _deck2, _active);
	}

	first_cell = function(_spec) {
		if !is_struct(_spec) || !is_array(_spec.allowed_cells) || array_length(_spec.allowed_cells) == 0 {
			return undefined;
		}
		return deep_copy(_spec.allowed_cells[0]);
	}

	test_summon = function() {
		var _state = make_state(["spearman"]);
		var _target = first_cell(rules.get_inputs(_state, 1, "summon")[0]);
		var _result = rules.execute(_state, 1, {effect_id: "summon", inputs: {target_cell: _target}});
		suite.assert_true(_result.ok, "summon accepts a legal target");
		suite.assert_true(_result.ok && _result.next_state.get_figure(_target[0], _target[1]).behaviour == "spearman", "summon places the deck figure");
		suite.assert_true(_result.ok && array_length(_result.next_state.data.players[$ "1"].deck) == 0, "summon consumes one deck figure");

		_state = make_state(["warrior"]);
		_state.set_figure(0, 0, {figure_id: "enemy", behaviour: "archer", owner_id: 2, status: "active"});
		_result = rules.execute(_state, 1, {effect_id: "summon", inputs: {target_cell: [0, 0]}});
		suite.assert_true(!_result.ok, "summon rejects an occupied target");
		suite.assert_equal(_state.get_figure(0, 0).figure_id, "enemy", "rejected summon does not mutate state");

		_state = make_state(["spearman"]);
		var _block_id = 0;
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				_state.set_figure(_x, _y, {figure_id: "block_" + string(_block_id), behaviour: "archer", owner_id: 2, status: "active"});
				_block_id++;
			}
		}
		var _summon_spec = rules.get_inputs(_state, 1, "summon")[0];
		suite.assert_true(array_length(_summon_spec.allowed_cells) == 0, "summon exposes no targets when every cell is unavailable");
		suite.assert_true(!rules.can_summon(_state, 1), "summon is unavailable when it has no legal target cells");
	}

	test_effect_cancelability = function() {
		var _state = make_state(["spearman"], ["archer"]);
		suite.assert_true(rules.is_effect_cancelable(_state, 1, "summon", {}, {}), "summon is cancelable before its card is revealed");
		suite.assert_true(!rules.is_effect_cancelable(_state, 1, "summon", {}, {card_revealed: true}), "summon is committed after its card is revealed");
		suite.assert_true(rules.is_effect_cancelable(_state, 1, "trader_ability", {source_cell: [0, 0]}, {}), "trader is cancelable before its cards are revealed");
		suite.assert_true(!rules.is_effect_cancelable(_state, 1, "trader_ability", {source_cell: [0, 0]}, {card_revealed: true}), "trader is committed after its cards are revealed");
	}

	test_move = function() {
		var _state = make_state([], []);
		_state.set_figure(2, 2, {figure_id: "mover", behaviour: "spearman", owner_id: 1, status: "active"});
		var _clone = _state.clone();
		suite.assert_equal(_clone.get_figure(2, 2).figure_id, "mover", "clone preserves figure id");
		suite.assert_equal(_clone.data.players[$ "1"].player_id, 1, "clone preserves player id");
		var _result = rules.execute(_state, 1, {effect_id: "move", inputs: {from_cell: [2, 2], target_cell: [3, 3]}});
		suite.assert_true(_result.ok, "normal move accepts an adjacent empty cell");
		suite.assert_true(_result.ok && _result.next_state.get_figure(2, 2) == undefined && _result.next_state.get_figure(3, 3).figure_id == "mover", "normal move relocates exactly one figure");
		suite.assert_true(_result.ok && _result.animation_batches[0][0].type == "move", "normal move emits a move animation");
	}

	test_warrior_strike = function() {
		var _state = make_state([], []);
		_state.set_figure(1, 1, {figure_id: "warrior", behaviour: "warrior", owner_id: 1, status: "active"});
		_state.set_figure(3, 3, {figure_id: "target", behaviour: "archer", owner_id: 2, status: "active"});
		var _result = rules.execute(_state, 1, {effect_id: "warrior_move", inputs: {source_cell: [1, 1], target_cell: [2, 2], strike_target: [3, 3]}});
		suite.assert_true(_result.ok, "warrior can move and strike an adjacent enemy");
		suite.assert_true(_result.ok && _result.next_state.get_figure(2, 2) == undefined && _result.next_state.get_figure(3, 3) == undefined, "warrior strike removes both figures from the board");
		suite.assert_true(_result.ok && _result.next_state.data.dropped[$ "1"] == 1 && _result.next_state.data.dropped[$ "2"] == 1, "warrior strike records both dropped figures");
	}

	test_archer = function() {
		var _state = make_state([], []);
		_state.set_figure(2, 2, {figure_id: "archer", behaviour: "archer", owner_id: 1, status: "active"});
		var _inputs = rules.get_inputs(_state, 1, "archer_move", {source_cell: [2, 2]});
		suite.assert_true(array_length(_inputs) == 2 && array_length(_inputs[1].allowed_cells) == 0, "isolated archer has no legal movement");
		_state.set_figure(1, 1, {figure_id: "anchor", behaviour: "spearman", owner_id: 1, status: "active"});
		_inputs = rules.get_inputs(_state, 1, "archer_move", {source_cell: [2, 2]});
		suite.assert_true(array_length(_inputs) == 2 && array_length(_inputs[1].allowed_cells) > 0, "archer gains movement when connected to another figure");

		_state = make_state([], []);
		_state.set_figure(1, 1, {figure_id: "archer", behaviour: "archer", owner_id: 1, status: "active"});
		_state.set_figure(0, 1, {figure_id: "left_anchor", behaviour: "spearman", owner_id: 1, status: "active"});
		_state.set_figure(3, 1, {figure_id: "right_anchor", behaviour: "spearman", owner_id: 1, status: "active"});
		_inputs = rules.get_inputs(_state, 1, "archer_move", {source_cell: [1, 1]});
		suite.assert_true(!GameInput.has_cell(_inputs[1], [2, 1]), "archer cannot detach from one figure to cross a gap to another");

		var _effect = rules.get_effect("archer_move");
		suite.assert_true(!_effect.is_valid_path(_state, [1, 1], [2, 1], [[1, 1], [3, 1], [2, 1]]), "archer rejects a route with a jump over a figure");
	}

	test_surround_capture = function() {
		var _state = make_state([], []);
		var _player_ids = rules.get_player_ids(_state);
		suite.assert_true(_player_ids[0] == 1 && _player_ids[1] == 2, "player sides resolve to both player ids");
		_state.set_figure(2, 2, {figure_id: "surrounded", behaviour: "spearman", owner_id: 1, status: "active"});
		var _id = 0;
		for (var _x = 1; _x <= 3; _x++) {
			for (var _y = 1; _y <= 3; _y++) {
				if _x != 2 || _y != 2 {
					_state.set_figure(_x, _y, {figure_id: "block_" + string(_id), behaviour: "archer", owner_id: 2, status: "active"});
					_id++;
				}
			}
		}
		var _resolved = rules.resolve_turn(_state, 2);
		suite.assert_true(_resolved.next_state.get_figure(2, 2) == undefined, "surrounded figure is captured");
		suite.assert_equal(_resolved.next_state.data.captured[$ "2"], 1, "surround capture is credited to the opponent");
	}

	run = function() {
		suite.run_case("summon", function() { test_summon(); });
		suite.run_case("effect cancelability", function() { test_effect_cancelability(); });
		suite.run_case("move", function() { test_move(); });
		suite.run_case("warrior strike", function() { test_warrior_strike(); });
		suite.run_case("archer", function() { test_archer(); });
		suite.run_case("surround capture", function() { test_surround_capture(); });
	}
}
