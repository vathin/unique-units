function TraderEffect() : GameEffect("trader_ability") constructor {
	get_sources = function(_state, _actor_id) {
		var _cells = [];
		for (var _x = 0; _x < _state.data.width; _x++) for (var _y = 0; _y < _state.data.height; _y++) {
			var _figure = _state.get_figure(_x, _y);
			if _figure != undefined && _figure.owner_id == _actor_id && _figure.behaviour == "trader" && _figure.status == "active" array_push(_cells, [_x, _y]);
		}
		return _cells;
	}
	get_options = function(_state, _actor_id) {
		var _options = [];
		var _player = _state.data.players[$ string(_actor_id)];
		if _player == undefined || array_length(_player.deck) < 3 return _options;
		for (var _index = 0; _index < 3; _index++) array_push(_options, {id: _index, behaviour: _player.deck[array_length(_player.deck) - 1 - _index]});
		return _options;
	}
	get_inputs = function(_state, _actor_id, _partial = {}) {
		var _source = Game.game_input.cell("source_cell", "game.input.trader_source", get_sources(_state, _actor_id));
		if !variable_struct_exists(_partial, "source_cell") || !Game.game_input.has_cell(_source, _partial.source_cell) return [_source];
		var _choice = Game.game_input.choice("figure_choice", "game.input.trader_choice", get_options(_state, _actor_id));
		if !variable_struct_exists(_partial, "figure_choice") return [_source, _choice];
		var _summon = new SummonEffect();
		return [_source, _choice, Game.game_input.cell("target_cell", "game.input.trader_target", _summon.get_summon_cells(_state, _actor_id))];
	}
	validate_inputs = function(_state, _actor_id, _inputs) {
		if _state.data.active_player_id != _actor_id || !is_struct(_inputs) return {ok: false, error: "Actor cannot use trader ability now"};
		var _specs = get_inputs(_state, _actor_id, _inputs);
		if array_length(_specs) != 3 || !is_real(_inputs.figure_choice) || _inputs.figure_choice < 0 || _inputs.figure_choice > 2 || !Game.game_input.has_cell(_specs[2], _inputs.target_cell) return {ok: false, error: "Invalid trader input"};
		return {ok: true, error: ""};
	}
	execute = function(_state, _actor_id, _inputs) {
		var _check = validate_inputs(_state, _actor_id, _inputs);
		if !_check.ok return {ok: false, error: _check.error, next_state: _state, animation_batches: [], events: []};
		var _next = _state.clone();
		var _player = _next.data.players[$ string(_actor_id)];
		var _offered = [array_pop(_player.deck), array_pop(_player.deck), array_pop(_player.deck)];
		var _behaviour = _offered[_inputs.figure_choice];
		for (var _index = 0; _index < 3; _index++) if _index != _inputs.figure_choice _next.data.dropped[$ string(_actor_id)]++;
		var _figure = {id: string(_next.data.next_figure_id), behaviour: _behaviour, owner_id: _actor_id, status: "active"};
		_next.data.next_figure_id++;
		_next.set_figure(_inputs.target_cell[0], _inputs.target_cell[1], _figure);
		return {ok: true, error: "", next_state: _next, animation_batches: [[{type: "summon", figure_id: _figure.id, at: deep_copy(_inputs.target_cell), duration_frames: 20}]], events: [{type: "trader_summon", figure_id: _figure.id, discarded: _offered}]};
	}
}
