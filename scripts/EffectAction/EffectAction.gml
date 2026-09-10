/// Legacy GameLoopController adapter for a validated GameRules intent.
function EffectAction(_effect_id, _actor_id, _inputs) : Action() constructor {
	type = "effect";
	effect_id = _effect_id;
	actor_id = _actor_id;
	inputs = deep_copy(_inputs);
	ready = true;
	target_x = undefined;
	target_y = undefined;
	preview_cell = undefined;
	preview_status = undefined;
	retarget_input_id = undefined;
	if effect_id == "summon" && variable_struct_exists(inputs, "target_cell") {
		target_x = inputs.target_cell[0];
		target_y = inputs.target_cell[1];
	}

	execute_logic = function() {
		// The legacy Field is still the authoritative visual source during this
		// migration. Refresh the pure snapshot immediately before validation.
		if Game.game_state_presenter == undefined || !Game.game_state_presenter.is_busy() {
			Game.sync_game_state_from_legacy();
		}
		var _result = Game.game_rules.execute(Game.game_state, actor_id, {effect_id: effect_id, inputs: inputs});
		if !_result.ok {
			show_debug_message("EffectAction rejected: effect=" + string(effect_id)
				+ ", actor=" + string(actor_id) + ", turn=" + string(global.turn_owner)
				+ ", inputs=" + json_stringify(inputs) + ", reason=" + string(_result.error));
		}
		return _result;
	}

	execute_ui = function(_result) {
		Game.game_state_presenter.commit(_result.next_state, _result.animation_batches);
	}

	// Compatibility preview for the old board renderer. Rules remain UI-free.
	draw = function() {
		if effect_id != "summon" || target_x == undefined || target_y == undefined {
			return;
		}
		var _target_cell = Game.field.get_cell(target_x, target_y);
		var _player_key = string(actor_id);
		if _target_cell == undefined || !variable_struct_exists(Game.game_state.data.players, _player_key) {
			return;
		}
		var _deck = Game.game_state.data.players[$ _player_key].deck;
		if !is_array(_deck) || array_length(_deck) <= 0 {
			return;
		}
		var _behaviour = _deck[array_length(_deck) - 1];
		var _enemy_side = Game.local_player != undefined && actor_id != Game.local_player.player_id;
		var _position = Game.field.get_cell_xy(_target_cell);
		draw_sprite_ext(Behaviours.get_sprite(_behaviour), _enemy_side, _position[0], _position[1], Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
	}

	back = function() {
		clear_preview();
		Game.field.clear_all_marks();
		Game.game_loop_controller.action = undefined;
		O_BoardDraw.clear();
		if effect_id == "summon" {
			Game.game_loop_controller.clean_controllers();
			global.cell_click_callback = undefined;
			return;
		}
		Game.game_loop_controller.quit_from_action();
	}

	clear_preview = function() {
		if preview_cell != undefined && preview_status != undefined {
			preview_cell.remove_figure_status(preview_status);
			preview_cell.set_draw_marks(1);
		}
		preview_cell = undefined;
		preview_status = undefined;
	}

	get_preview_status = function(_input_id) {
		if _input_id == "target_cell" {
			if effect_id == "summon" || effect_id == "trader_ability" return FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned);
			if effect_id == "warrior_ability" return FigureStatusList.status(FIGURE_STATUS_LIST.will_be_dropped);
			if effect_id == "move" || effect_id == "archer_move" || effect_id == "warrior_move" || effect_id == "spearman_ability" return FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved);
		}
		if _input_id == "strike_target" && effect_id == "warrior_move" return FigureStatusList.status(FIGURE_STATUS_LIST.will_be_dropped);
		if _input_id == "destination_cell" && effect_id == "shieldbearer_ability" return FigureStatusList.status(FIGURE_STATUS_LIST.will_be_moved);
		return undefined;
	}

	set_preview = function(_input_id, _x, _y) {
		clear_preview();
		var _status = get_preview_status(_input_id);
		var _cell = Game.field.get_cell(_x, _y);
		if _status != undefined && _cell != undefined {
			_cell.add_figure_status(_status);
			_cell.set_draw_marks(0);
			preview_cell = _cell;
			preview_status = _status;
		}
	}

	set_new_input_coordinates = function(_input_id, _x, _y) {
		if _input_id == undefined {
			return false;
		}
		var _partial_inputs = deep_copy(inputs);
		if variable_struct_exists(_partial_inputs, _input_id) {
			variable_struct_remove(_partial_inputs, _input_id);
		}
		var _input_spec = undefined;
		if _input_id == "strike_target" && effect_id == "warrior_move" && variable_struct_exists(_partial_inputs, "target_cell") {
			var _warrior_move_effect = Game.game_rules.get_effect("warrior_move");
			_input_spec = Game.game_input.cell("strike_target", "game.input.warrior_target", _warrior_move_effect.get_strike_cells(Game.game_state, actor_id, _partial_inputs.target_cell));
		}
		else {
			var _specs = Game.game_rules.get_inputs(Game.game_state, actor_id, effect_id, _partial_inputs);
			for (var _index = 0; _index < array_length(_specs); _index++) {
				if _specs[_index].id == _input_id {
					_input_spec = _specs[_index];
					break;
				}
			}
		}
		if _input_spec == undefined || !Game.game_input.has_cell(_input_spec, [_x, _y]) {
			return false;
		}
		inputs[$ _input_id] = [_x, _y];
		if effect_id == "summon" && _input_id == "target_cell" {
			target_x = _x;
			target_y = _y;
		}
		set_preview(_input_id, _x, _y);
		return true;
	}

	set_new_target_coordinates = function(_x, _y) {
		return set_new_input_coordinates("target_cell", _x, _y);
	}

	begin_warrior_strike = function() {
		if effect_id != "warrior_move" || !variable_struct_exists(inputs, "target_cell") {
			return false;
		}
		var _effect = Game.game_rules.get_effect("warrior_move");
		var _cells = _effect.get_strike_cells(Game.game_state, actor_id, inputs.target_cell);
		if array_length(_cells) <= 0 {
			return false;
		}
		Game.field.clear_all_marks();
		for (var _index = 0; _index < array_length(_cells); _index++) {
			var _cell = Game.field.get_cell(_cells[_index][0], _cells[_index][1]);
			if _cell != undefined {
				_cell.marked = true;
			}
		}
		retarget_input_id = "strike_target";
		Game.game_loop_controller.state = STATE_LIST.figure_ability;
		O_BoardDraw.block_end_button();
		global.mark = S_Ability_mark;
		global.cell_action = function(_cell) {
			var _active_action = Game.game_loop_controller.action;
			if _cell != undefined && _cell.marked && _active_action != undefined && _active_action.type == "effect" && _active_action.effect_id == "warrior_move" {
				if _active_action.set_new_input_coordinates("strike_target", _cell.xcord, _cell.ycord) {
					O_BoardDraw.unblock_end_button();
				}
			}
		};
		return true;
	}

	export = function() {
		return {ex_type: "effect", ex_effect_id: effect_id, ex_actor_id: actor_id, ex_inputs: deep_copy(inputs), ex_turn_owner: global.turn_owner};
	}

	import = function(_data) {
		effect_id = _data.ex_effect_id;
		actor_id = _data.ex_actor_id;
		inputs = deep_copy(_data.ex_inputs);
	}
}
