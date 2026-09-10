/// UI adapter for any cell-based GameEffect. It renders only legal cells from
/// GameRules and never duplicates rule checks.
function EffectInputController(_effect_id, _actor_id, _initial_inputs = {}) constructor {
	effect_id = _effect_id;
	actor_id = _actor_id;
	inputs = deep_copy(_initial_inputs);
	current_spec = undefined;
	choice_view = undefined;

	find_next_spec = function(_specs) {
		for (var _index = 0; _index < array_length(_specs); _index++) {
			var _spec = _specs[_index];
			if !variable_struct_exists(inputs, _spec.id) {
				return _spec;
			}
		}
		return undefined;
	}

	mark_cells = function(_spec) {
		Game.field.clear_all_marks();
		if _spec == undefined || !is_array(_spec.allowed_cells) {
			return;
		}
		for (var _index = 0; _index < array_length(_spec.allowed_cells); _index++) {
			var _cell_data = _spec.allowed_cells[_index];
			var _cell = Game.field.get_cell(_cell_data[0], _cell_data[1]);
			if _cell != undefined {
				_cell.marked = true;
			}
		}
	}

	refresh = function() {
		if choice_view != undefined {
			choice_view.destroy();
			choice_view = undefined;
		}
		var _completed_spec = current_spec;
		var _specs = Game.game_rules.get_inputs(Game.game_state, actor_id, effect_id, inputs);
		current_spec = find_next_spec(_specs);
		if effect_id == "spearman_ability" && current_spec != undefined && current_spec.type == "cell" {
			show_debug_message("Spearman ability input: source=" + json_stringify(inputs.source_cell)
				+ ", targets=" + json_stringify(current_spec.allowed_cells));
		}
		if current_spec == undefined {
			var _action = new EffectAction(effect_id, actor_id, inputs);
			_action.retarget_input_id = _completed_spec == undefined ? undefined : _completed_spec.id;
			if _completed_spec != undefined && _completed_spec.type == "cell" {
				_action.set_preview(_completed_spec.id, inputs[$ _completed_spec.id][0], inputs[$ _completed_spec.id][1]);
			}
			Game.game_loop_controller.set_action(_action);
			if _completed_spec != undefined && _completed_spec.type == "cell" {
				global.cell_action = function(_cell) {
					var _active_action = Game.game_loop_controller.action;
					if _cell != undefined && _cell.marked && _active_action != undefined && _active_action.type == "effect" {
						_active_action.set_new_input_coordinates(_active_action.retarget_input_id, _cell.xcord, _cell.ycord);
					}
				};
			}
			Game.ability_input_controller = undefined;
			O_BoardDraw.unblock_end_button();
			return;
		}
		if current_spec.type == "choice" {
			choice_view = Game.effect_choice_view_factory(current_spec, function(_value) {
				inputs[$ current_spec.id] = _value;
				refresh();
			});
			return;
		}
		mark_cells(current_spec);
		global.cell_action = function(_cell) {
			if _cell != undefined && _cell.marked {
				inputs[$ current_spec.id] = [_cell.xcord, _cell.ycord];
				global.cell_click_callback = _cell;
				refresh();
			}
		};
	}

	back = function() {
		if choice_view != undefined {
			choice_view.destroy();
		}
		Game.field.clear_all_marks();
		global.cell_click_callback = global.selected_cell;
		Game.ability_input_controller = undefined;
		Game.figure_action_controller = new FigureActionController();
	}

	Game.game_loop_controller.state = (_effect_id == "move" || _effect_id == "archer_move" || _effect_id == "warrior_move") ? STATE_LIST.figure_move : STATE_LIST.figure_ability;
	global.mark = S_Ability_mark;
	O_BoardDraw.block_end_button();
	refresh();
}
