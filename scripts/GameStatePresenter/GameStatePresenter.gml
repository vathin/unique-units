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
		_figure.figure_id = string(_state_figure.figure_id);
		_figure.owner = _state_figure.owner_id;
		_figure.update_stats();
		_figure.state.is_active = _state_figure.status == "active";
		_figure.state.is_dropped = _state_figure.status == "dropped";
		_figure.state.is_conquesting = _state_figure.status == "conquesting";
		_figure.state.is_captured = _state_figure.status == "captured";
		return _figure;
	}

	sync_figure_place = function(_place, _figures) {
		_place.figures = [];
		if !is_array(_figures) {
			_place.sort(false);
			return;
		}
		for (var _index = 0; _index < array_length(_figures); _index++) {
			array_push(_place.figures, make_figure(_figures[_index]));
		}
		_place.sort(false);
	}

	apply_state = function(_state) {
		var _existing = find_existing_figures();
		for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
			for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
				var _field_cell = Game.field.get_cell(_clear_x, _clear_y);
				_field_cell.clear();
				var _state_cell = _state.get_cell(_clear_x, _clear_y);
				_field_cell.can_be_conquested = _state_cell != undefined && _state_cell.can_be_conquested;
			}
		}
		for (var _x = 0; _x < _state.data.width; _x++) {
			for (var _y = 0; _y < _state.data.height; _y++) {
				var _state_figure = _state.get_figure(_x, _y);
				if _state_figure == undefined {
					continue;
				}
				var _id = string(_state_figure.figure_id);
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
		var _player1_key = string(Game.Player1.player_id);
		var _player2_key = string(Game.Player2.player_id);
		sync_figure_place(Game.field.player1_captured,
			variable_struct_exists(_state.data.captured_figures, _player1_key) ? _state.data.captured_figures[$ _player1_key] : []);
		sync_figure_place(Game.field.player2_captured,
			variable_struct_exists(_state.data.captured_figures, _player2_key) ? _state.data.captured_figures[$ _player2_key] : []);
		sync_figure_place(Game.field.player1_dropped,
			variable_struct_exists(_state.data.dropped_figures, _player1_key) ? _state.data.dropped_figures[$ _player1_key] : []);
		sync_figure_place(Game.field.player2_dropped,
			variable_struct_exists(_state.data.dropped_figures, _player2_key) ? _state.data.dropped_figures[$ _player2_key] : []);
		if Game.game_loop_controller != undefined && Game.game_loop_controller.figures_counter != undefined {
			Game.game_loop_controller.figures_counter.figures_id_counter = _state.data.next_figure_id;
		}
		Game.game_state = _state;
		if Game.game_loop_controller != undefined {
			Game.game_loop_controller.player1_captured = _state.data.captured[$ _player1_key];
			Game.game_loop_controller.player2_captured = _state.data.captured[$ _player2_key];
		}
	}

	play_batch = function(_batch) {
		show_debug_message("Presenter batch: events=" + string(array_length(_batch)));
		for (var _index = 0; _index < array_length(_batch); _index++) {
			var _event = _batch[_index];
			show_debug_message("Presenter event: type=" + string(_event.type)
				+ ", figure_id=" + string(variable_struct_exists(_event, "figure_id") ? _event.figure_id : "none"));
			if _event.type == "move" {
				// The source cell is the visual authority at this point.  Using it
				// avoids platform-specific number/string representation of figure IDs.
				var _source_cell = Game.field.get_cell(_event.from[0], _event.from[1]);
				var _figure = _source_cell != undefined && _source_cell.is_filled()
					? _source_cell.filled_figure : Game.field.find_figure_from_id(_event.figure_id);
				if _figure == undefined {
					show_debug_message("Presenter move skipped: figure not found");
				}
				if _figure != undefined {
					var _from = Game.field.get_cell_xy(Game.field.get_cell(_event.from[0], _event.from[1]));
					var _to = Game.field.get_cell_xy(Game.field.get_cell(_event.to[0], _event.to[1]));
					var _animation = new MoveAnimationController();
					_animation.start_animation(_from[0], _from[1], _to[0], _to[1], _event.duration_frames);
					_figure.add_animation(_animation);
					// This is presentation-only state. Keep the exact Figure reference until
					// this batch ends: looking it up by id can select several legacy figures
					// with the same value and clear unrelated cells on HTML5.
					array_push(pending_visual_updates, {
						type: "move",
						figure: _figure,
						from: deep_copy(_event.from),
						to: deep_copy(_event.to)
					});
				}
			}
			else if _event.type == "summon" {
				var _summoned_figure = Game.field.find_figure_from_id(_event.figure_id);
				var _summon_cell = Game.field.get_cell(_event.at[0], _event.at[1]);
				if _summoned_figure == undefined && pending_state != undefined {
					var _state_figure = pending_state.get_figure(_event.at[0], _event.at[1]);
					// The event location belongs to the confirmed result.  HTML5 may
					// stringify numeric IDs differently (for example 3 vs 3.0), so
					// do not reject the new figure solely on that presentation detail.
					if _state_figure != undefined && _summon_cell != undefined {
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
				else {
					show_debug_message("Presenter summon skipped: figure=" + string(_summoned_figure != undefined)
						+ ", cell=" + string(_summon_cell != undefined));
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
			else if _event.type == "conquest" {
				var _conquest_cell = Game.field.get_cell(_event.at[0], _event.at[1]);
				if _conquest_cell != undefined && _conquest_cell.is_filled() {
					// pending_state is applied only after all visual batches. Mark the live
					// figure now, otherwise Field never draws the second half of overturn.
					_conquest_cell.filled_figure.state.is_active = false;
					_conquest_cell.filled_figure.state.is_conquesting = true;
					var _conquest_position = Game.field.get_cell_xy(_conquest_cell);
					var _conquest_animation = new OverturnAnimationController();
					_conquest_animation.start_animation(_conquest_position[0], _conquest_position[1], _conquest_position[0], _conquest_position[1], _event.duration_frames);
					_conquest_cell.filled_figure.add_animation(_conquest_animation);
				}
			}
			else if _event.type == "capture" {
				var _capture_cell = Game.field.get_cell(_event.at[0], _event.at[1]);
				if _capture_cell != undefined && _capture_cell.is_filled() {
					var _capture_position = Game.field.get_cell_xy(_capture_cell);
					var _capture_animation = new HitAnimationController();
					_capture_animation.start_animation(_capture_position[0], _capture_position[1], _capture_position[0], _capture_position[1], _event.duration_frames);
					_capture_cell.filled_figure.add_animation(_capture_animation);
				}
			}
			else if _event.type == "drop" {
				var _drop_cell = variable_struct_exists(_event, "at") ? Game.field.get_cell(_event.at[0], _event.at[1]) : undefined;
				var _dropped_figure = _drop_cell != undefined && _drop_cell.is_filled()
					? _drop_cell.filled_figure : Game.field.find_figure_from_id(_event.figure_id);
				if _dropped_figure != undefined {
					if _drop_cell != undefined && _drop_cell.is_filled()
						&& _drop_cell.filled_figure == _dropped_figure {
						_drop_cell.clear();
					}
					else {
						for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
							for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
								var _field_cell = Game.field.get_cell(_clear_x, _clear_y);
								if _field_cell.is_filled() && _field_cell.filled_figure == _dropped_figure {
									_field_cell.clear();
									break;
								}
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
			var _figure = _update.figure;
			var _target_cell = Game.field.get_cell(_update.to[0], _update.to[1]);
			if _figure == undefined || _target_cell == undefined {
				continue;
			}
			var _source_cell = Game.field.get_cell(_update.from[0], _update.from[1]);
			if _source_cell != undefined && _source_cell.is_filled()
				&& _source_cell.filled_figure == _figure {
				_source_cell.clear();
			}
			else {
				// A batch may contain concurrent effects. In that case find this exact
				// visual object rather than matching an id which need not be unique in
				// old saves or imported matches.
				for (var _clear_x = 0; _clear_x < Game.field.field_width; _clear_x++) {
					for (var _clear_y = 0; _clear_y < Game.field.field_height; _clear_y++) {
						var _field_cell = Game.field.get_cell(_clear_x, _clear_y);
						if _field_cell.is_filled() && _field_cell.filled_figure == _figure {
							_field_cell.clear();
							break;
						}
					}
				}
			}
			_target_cell.fill(_figure, true);
		}
		pending_visual_updates = [];
	}

	commit = function(_state, _animation_batches) {
		if _state == undefined || !is_struct(_state) || !variable_struct_exists(_state, "clone") {
			show_debug_message("Presenter commit skipped: invalid game state");
			return false;
		}
		// A received result belongs to this animation transaction even if another
		// caller later reuses or mutates its source state.
		pending_state = _state.clone();
		pending_batches = is_array(_animation_batches) ? deep_copy(_animation_batches) : [];
		pending_visual_updates = [];
		show_debug_message("Presenter commit: batches=" + string(array_length(pending_batches)));
		advance();
		return true;
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
