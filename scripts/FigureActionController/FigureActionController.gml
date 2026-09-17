// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureActionController() constructor{
	buttons_visiblity = 1;
	figure_have_ability = 1;
	figure_can_move = 1
	Game.game_loop_controller.state = STATE_LIST.figure_action
	move_and_ability = false;

	get_move_effect_id = function(_behaviour) {
		if _behaviour == "warrior" return "warrior_move";
		if _behaviour == "archer" return "archer_move";
		return "move";
	}

	get_ability_effect_id = function(_behaviour) {
		switch _behaviour {
			case "warrior": return "warrior_ability";
			case "spearman": return "spearman_ability";
			case "shieldbearer": return "shieldbearer_ability";
			case "trader": return "trader_ability";
		}
		return undefined;
	}

	get_next_input_options = function(_effect_id, _inputs) {
		if _effect_id == undefined || Game.game_rules == undefined || Game.game_state == undefined {
			return 0;
		}
		var _specs = Game.game_rules.get_inputs(Game.game_state, global.turn_owner, _effect_id, _inputs);
		for (var _spec_index = 0; _spec_index < array_length(_specs); _spec_index++) {
			var _spec = _specs[_spec_index];
			if variable_struct_exists(_inputs, _spec.id) {
				continue;
			}
			if _spec.type == "cell" && is_array(_spec.allowed_cells) {
				return array_length(_spec.allowed_cells);
			}
			if _spec.type == "choice" && is_array(_spec.options) {
				return array_length(_spec.options);
			}
		}
		return 0;
	}

	// The visual board supplies only the selected coordinates. Ownership, status
	// and available effects are always read from the logical match state.
	get_selected_state_figure = function() {
		if Game.game_state == undefined || global.selected_cell == undefined {
			return undefined;
		}
		var _figure = Game.game_state.get_figure(global.selected_cell.xcord, global.selected_cell.ycord);
		if _figure == undefined || string(_figure.owner_id) != string(global.turn_owner) || _figure.status != "active" {
			return undefined;
		}
		return _figure;
	}
	var _selected_figure = get_selected_state_figure();
	if _selected_figure == undefined {
		figure_can_move = 0;
		figure_have_ability = 0;
	}
	else {
		var _source_inputs = {source_cell: [global.selected_cell.xcord, global.selected_cell.ycord]};
		var _move_effect_id = get_move_effect_id(_selected_figure.behaviour);
		var _move_inputs = _move_effect_id == "move" ? {from_cell: [global.selected_cell.xcord, global.selected_cell.ycord]} : _source_inputs;
		if get_next_input_options(_move_effect_id, _move_inputs) <= 0 {
			figure_can_move = 0;
		}
		var _ability_effect_id = get_ability_effect_id(_selected_figure.behaviour);
		var _ability_targets = _ability_effect_id == undefined ? 0 : get_next_input_options(_ability_effect_id, _source_inputs);
		if _ability_effect_id == undefined || _ability_targets <= 0 {
			figure_have_ability = 0;
		}
	}
	
	destroy_self = function() {
		Game.figure_action_controller = undefined
	}
	
	move_figure = function() {
		var _selected_figure = get_selected_state_figure();
		if figure_can_move && _selected_figure != undefined {
			var _effect_id = get_move_effect_id(_selected_figure.behaviour);
			var _inputs = {source_cell: [global.selected_cell.xcord, global.selected_cell.ycord]};
			if _effect_id == "move" {
				_inputs = {from_cell: [global.selected_cell.xcord, global.selected_cell.ycord]};
			}
			Game.ability_input_controller = new EffectInputController(_effect_id, global.turn_owner, _inputs);
			destroy_self();
		}
	}

	use_ability = function() {
		var _selected_figure = get_selected_state_figure();
		if figure_have_ability && _selected_figure != undefined {
			var _effect_id = get_ability_effect_id(_selected_figure.behaviour);
			if _effect_id != undefined {
				Game.ability_input_controller = new EffectInputController(_effect_id, global.turn_owner, {source_cell: [global.selected_cell.xcord, global.selected_cell.ycord]});
				destroy_self();
			}
		}
	}

	switch_figure = function() {
		Game.game_loop_controller.clean_controllers();
		destroy_self()
	}

	back = function() {
		if !move_and_ability{
			Game.game_loop_controller.clear_all();
		}
	}

	revert_move_and_ability = function() {
		Game.game_loop_controller.state = STATE_LIST.figure_move
		Game.game_loop_controller.action.using_ability = 0;
		Game.field.clear_all_marks();
		global.mark = S_Move_mark;
	}

	if (Game.game_loop_controller.get_game_state() == STATE_LIST.figure_action) {
		global.cell_action = function(cell) {
			if cell == undefined || Game.game_state == undefined {
				return;
			}
			var _figure = Game.game_state.get_figure(cell.xcord, cell.ycord);
			if _figure != undefined && string(_figure.owner_id) == string(global.turn_owner) && _figure.status == "active" {
				global.selected_cell = cell;
				global.cell_click_callback = cell;
				Game.field.clear_all_marks();
				Game.figure_action_controller = new FigureActionController();
			}
		}
	}
}
