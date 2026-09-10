/// Transitional presenter: renders a confirmed GameState through the existing Field.
/// Rules never call this class; only EffectAction and network commits do.
function GameStatePresenter() constructor {
	pending_batches = [];
	pending_state = undefined;
	pending_visual_updates = [];

	find_existing_figures = function() {
		var _figures = {};
		for (var _x = 0; _x < Game.field.field_width; _x++) {
			for (var _y = 0; _y < Game.field.field_height; _y++) {
				var _figure = Game.field.get_cell(_x, _y).filled_figure;
				if _figure != undefined {
					_figures[$ string(_figure.figure_id)] = _figure;
				}
			}
		}
		return _figures;
	}

	make_figure = function(_state_figure) {
		var _figure = new Figure();
		_figure.set_behaviour(_state_figure.behaviour);
		_figure.figure_id = _state_figure.id;
		_figure.owner = _state_figure.owner_id;
		_figure.update_stats();
		_figure.state.is_active = _state_figure.status == "active";
		_figure.state.is_dropped = _state_figure.status == "dropped";
		_figure.state.is_conquesting = _state_figure.status == "conquesting";
		_figure.state.is_captured = _state_figure.status == "captured";
		return _figure;
	}

	apply_state = function(_state) {
		var _existing = find_existing_figures();
		for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
			for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
				Game.field.get_cell(_clear_x, _clear_y).clear();
			}
		}
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _state_figure = _state.get_figure(_x, _y);
				if _state_figure == undefined {
					continue;
				}
				var _id = string(_state_figure.id);
				var _can_reuse = variable_struct_exists(_existing, _id)
					&& _existing[$ _id].owner == _state_figure.owner_id
					&& _existing[$ _id].behaviour == _state_figure.behaviour;
				var _figure = _can_reuse ? _existing[$ _id] : make_figure(_state_figure);
				_figure.state.is_active = _state_figure.status == "active";
				_figure.state.is_dropped = _state_figure.status == "dropped";
				_figure.state.is_conquesting = _state_figure.status == "conquesting";
				_figure.state.is_captured = _state_figure.status == "captured";
				Game.field.get_cell(_x, _y).fill(_figure, _can_reuse);
			}
		}
		Game.field.movement_array = deep_copy(_state.data.movement_history);
		if Game.game_loop_controller != undefined && Game.game_loop_controller.figures_counter != undefined {
			Game.game_loop_controller.figures_counter.figures_id_counter = _state.data.next_figure_id;
		}
		Game.game_state = _state;
		var _player_keys = variable_struct_get_names(_state.data.players);
		for (var _player_index = 0; _player_index < array_length(_player_keys); _player_index++) {
			var _player = _state.data.players[$ _player_keys[_player_index]];
			var _deck_data = Game.user_data.load(_player.id);
			if is_struct(_deck_data) {
				_deck_data.player_figures = deep_copy(_player.deck);
				Game.user_data.save(_player.id, _deck_data);
			}
		}
	}

	play_batch = function(_batch) {
		for (var _index = 0; _index < array_length(_batch); _index++) {
			var _event = _batch[_index];
			if _event.type == "move" {
				var _figure = Game.field.find_figure_from_id(_event.figure_id);
				if _figure != undefined {
					var _from = Game.field.get_cell_xy(Game.field.get_cell(_event.from[0], _event.from[1]));
					var _to = Game.field.get_cell_xy(Game.field.get_cell(_event.to[0], _event.to[1]));
					var _animation = new MoveAnimationController();
					_animation.start_animation(_from[0], _from[1], _to[0], _to[1], _event.duration_frames);
					_figure.add_animation(_animation);
					array_push(pending_visual_updates, {type: "move", figure_id: _event.figure_id, to: deep_copy(_event.to)});
				}
			}
			else if _event.type == "summon" {
				var _summoned_figure = Game.field.find_figure_from_id(_event.figure_id);
				var _summon_cell = Game.field.get_cell(_event.at[0], _event.at[1]);
				if _summoned_figure == undefined && pending_state != undefined {
					var _state_figure = pending_state.get_figure(_event.at[0], _event.at[1]);
					if _state_figure != undefined && string(_state_figure.id) == string(_event.figure_id) && _summon_cell != undefined {
						_summoned_figure = make_figure(_state_figure);
						_summon_cell.fill(_summoned_figure, false);
					}
				}
				if _summoned_figure != undefined && _summon_cell != undefined {
					var _summon_position = Game.field.get_cell_xy(_summon_cell);
					var _summon_animation = new OverturnAnimationController();
					_summon_animation.start_animation(_summon_position[0], _summon_position[1], _summon_position[0], _summon_position[1], _event.duration_frames);
					_summoned_figure.add_animation(_summon_animation);
				}
			}
			else if _event.type == "hit" {
				var _hit_cell = Game.field.get_cell(_event.at[0], _event.at[1]);
				if _hit_cell != undefined && _hit_cell.is_filled() {
					var _hit_position = Game.field.get_cell_xy(_hit_cell);
					var _hit_animation = new HitAnimationController();
					_hit_animation.start_animation(_hit_position[0], _hit_position[1], _hit_position[0], _hit_position[1], _event.duration_frames);
					_hit_cell.filled_figure.add_animation(_hit_animation);
				}
			}
			else if _event.type == "drop" {
				var _dropped_figure = Game.field.find_figure_from_id(_event.figure_id);
				if _dropped_figure != undefined {
					for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
						for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
							var _field_cell = Game.field.get_cell(_clear_x, _clear_y);
							if _field_cell.is_filled() && string(_field_cell.filled_figure.figure_id) == string(_event.figure_id) {
								_field_cell.clear();
							}
						}
					}
					_dropped_figure.drop();
				}
			}
		}
	}

	// Animation controllers only affect draw coordinates.  Between batches the
	// Field must reflect a completed visual move, while pending_state stays intact.
	apply_visual_updates = function() {
		for (var _update_index = 0; _update_index < array_length(pending_visual_updates); _update_index++) {
			var _update = pending_visual_updates[_update_index];
			if _update.type != "move" {
				continue;
			}
			var _figure = Game.field.find_figure_from_id(_update.figure_id);
			var _target_cell = Game.field.get_cell(_update.to[0], _update.to[1]);
			if _figure == undefined || _target_cell == undefined {
				continue;
			}
			for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
				for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
					var _field_cell = Game.field.get_cell(_clear_x, _clear_y);
					if _field_cell.is_filled() && string(_field_cell.filled_figure.figure_id) == string(_update.figure_id) {
						_field_cell.clear();
					}
				}
			}
			_target_cell.fill(_figure, true);
		}
		pending_visual_updates = [];
	}

	commit = function(_state, _animation_batches) {
		// A received result belongs to this animation transaction even if another
		// caller later reuses or mutates its source state.
		pending_state = _state.clone();
		pending_batches = deep_copy(_animation_batches);
		pending_visual_updates = [];
		advance();
	}

	advance = function() {
		if Game.field.has_active_animations() {
			return;
		}
		apply_visual_updates();
		if array_length(pending_batches) <= 0 {
			if pending_state != undefined {
				apply_state(pending_state);
				pending_state = undefined;
			}
			return;
		}
		var _next_batch = pending_batches[0];
		array_delete(pending_batches, 0, 1);
		play_batch(_next_batch);
	}

	is_busy = function() {
		return pending_state != undefined || array_length(pending_batches) > 0
			|| array_length(pending_visual_updates) > 0 || Game.field.has_active_animations();
	}

	step = function() {
		advance();
	}
}
