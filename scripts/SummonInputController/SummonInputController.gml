// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function SummonInputController() constructor{
	Game.game_loop_controller.state = STATE_LIST.summon
	Game.field.clear_all_marks();
	Game.field.selected_cell = undefined;
	global.selected_cell = undefined;
	Game.game_loop_controller.set_can_cancel(0);
	var _player_key = string(global.turn_owner);
	if Game.game_state == undefined or !variable_struct_exists(Game.game_state.data.players, _player_key) {
		Game.summon_controller = undefined;
		return;
	}
	var _deck = Game.game_state.data.players[$ _player_key].deck;
	if !is_array(_deck) or array_length(_deck) <= 0 {
		Game.summon_controller = undefined;
		return;
	}
	figure_to_summon = _deck[array_length(_deck) - 1];
	global.mark = S_Summon_mark;
	// The UI must render exactly the same cells SummonEffect validates.
	var _summon_specs = Game.game_rules.get_inputs(Game.game_state, global.turn_owner, "summon", {});
	if array_length(_summon_specs) <= 0 || !is_array(_summon_specs[0].allowed_cells) {
		Game.summon_controller = undefined;
		return;
	}
	for (var _cell_index = 0; _cell_index < array_length(_summon_specs[0].allowed_cells); _cell_index++) {
		var _cell_data = _summon_specs[0].allowed_cells[_cell_index];
		var _cell = Game.field.get_cell(_cell_data[0], _cell_data[1]);
		if _cell != undefined {
			_cell.marked = true;
		}
	}
	global.able_to_summon = true;
	global.cell_action = function(cell) {
		if cell != undefined && Game.game_input.has_cell(_summon_specs[0], [cell.xcord, cell.ycord]) {
			global.cell_click_callback = cell;
			Game.field.set_selected_cell(cell)
			Game.game_loop_controller.choose_cell_for_summon();
		}	
	}
	
	Button_set_overlay = function() {
		O_BoardDraw.set_button_overlay(Behaviours.get_sprite(figure_to_summon), 0)
		if Game.game_loop_controller.state != STATE_LIST.summon 
		or (Game.game_loop_controller.have_action() and Game.game_loop_controller.action.target_x != undefined) {
			O_BoardDraw.clear_button_overlay();
			var _overlay_index = array_get_index(Game.do_every_step_list, Button_set_overlay);
			if _overlay_index != -1 {
				array_delete(Game.do_every_step_list, _overlay_index, 1);
			}
			}
	}
	array_push(Game.do_every_step_list, Button_set_overlay)

	time_end = function() {
		//drop_figure = instance_create_depth(O_SummonButton.x, O_SummonButton.y, -1, O_Figure);
		//drop_figure.set_behaviour(figure_to_summon);
		//drop_figure.drop();
		Game.summon_controller = undefined
	}

	start_summon = function(target_x, target_y) {
		var _action = new EffectAction("summon", global.turn_owner, {target_cell: [target_x, target_y]});
		_action.retarget_input_id = "target_cell";
		_action.set_preview("target_cell", target_x, target_y);
		Game.game_loop_controller.set_action(_action);
		O_BoardDraw.unblock_end_button();
		var _overlay_index = array_get_index(Game.do_every_step_list, Button_set_overlay);
		if _overlay_index != -1 {
			array_delete(Game.do_every_step_list, _overlay_index, 1);
		}
		O_BoardDraw.clear_button_overlay()
		Game.summon_controller = undefined
	}
}
