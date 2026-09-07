// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function TraderAbility(_using_figure=undefined, _using_cell=undefined, _skip_ui=false) : FigureAbilityAction() constructor{
	skip_ui = _skip_ui;
	figure_button_x = display_get_gui_width()/2 - 130*(display_get_gui_height()/max(1, room_height));
	figure_button_y = display_get_gui_height()/1.25 + 45*(display_get_gui_height()/max(1, room_height));
	figure_button_x_offset = 82;
	using_figure = _using_figure;
	using_cell = _using_cell;
	chosen_button = undefined;
	if !skip_ui {
		O_BoardDraw.block_end_button();
	}
	sprite_draw = undefined;
	target_cell = undefined;
	if !skip_ui {
		global.mark = S_Summon_mark;
	}
	buttons = [];
	
	
	
	create_buttons = function() {
		Game.game_loop_controller.set_can_cancel(0);
		load_data = Game.user_data.load(using_figure.owner);
		for (i = 0; i < 3; i ++) {
			buttons[i] = array_pop(load_data.player_figures);
		}
		
		var _gui_scale = display_get_gui_height()/max(1, room_height);
		figure_button_x_offset = 82*_gui_scale;
		figure_button_x = display_get_gui_width()/2 - figure_button_x_offset;
		figure_button_y = display_get_gui_height()/1.25 + 45*_gui_scale;
		
		Game.user_data.save(using_figure.owner, load_data);
	}
	
	start = function() {
		create_buttons();
		array_push(Game.do_every_step_list, TEST_buttons_check);
		array_push(Game.do_every_step_list, TEST_draw_buttons);
	}
	
	TEST_draw_buttons = function() {
		var _gui_scale = display_get_gui_height()/max(1, room_height);
		if buttons != [] {
			for (i = 0; i < 3; i ++) {
				var _draw_alpha = 1/(1+(chosen_button == i));
				draw_sprite_ext(Behaviours.get_sprite(buttons[i]), using_figure.image, figure_button_x + figure_button_x_offset*i+5, figure_button_y+5, 
				Settings.figure_scale*1.3*_gui_scale, Settings.figure_scale*1.3*_gui_scale, 0, c_white, _draw_alpha);
			}
		}
		if Game.game_loop_controller.state != STATE_LIST.figure_ability 
		{
			var _index = array_get_index(Game.do_every_step_list, self);
			if _index != -1 {
				array_delete(Game.do_every_step_list, _index, 1);
			}
		}
	}
	
	TEST_buttons_check = function() {
		if mouse_check_button_pressed(mb_left) {
			 {
				var _mouse_x = UI_controller.gui_mouse_x();
				var _mouse_y = UI_controller.gui_mouse_y();
				var _gui_scale = display_get_gui_height()/max(1, room_height);
				if _mouse_y > figure_button_y - 25*_gui_scale and _mouse_y < figure_button_y + 45*_gui_scale {
					if _mouse_x > figure_button_x - 40*_gui_scale and _mouse_x < figure_button_x + 50*_gui_scale {
						chosen_button = 0;
					} 
					if _mouse_x > figure_button_x - 40*_gui_scale + figure_button_x_offset and
					_mouse_x < figure_button_x + 50*_gui_scale + figure_button_x_offset {
						chosen_button = 1;
					} 
					if _mouse_x > figure_button_x - 40*_gui_scale + 2*figure_button_x_offset and 
					_mouse_x < figure_button_x + 50*_gui_scale + 2*figure_button_x_offset{
						chosen_button = 2;
					} 
				}
				if target_cell == undefined and chosen_button != undefined {check_ability_targets()}
			}
		}
		if Game.game_loop_controller.state != STATE_LIST.figure_ability 
		{
			var _index = array_get_index(Game.do_every_step_list, self);
			if _index != -1 {
				array_delete(Game.do_every_step_list, _index, 1);
			}
		}
	}
	
	if !skip_ui and Game.game_loop_controller.state == STATE_LIST.figure_ability {
		start();
		Game.field.clear_all_marks();
	}
	
	execute = function() {
		//Game.game_loop_controller.figures_counter.change_field_figures_amount(using_figure.owner, 1);
		//new_field_figure = new Figure();
		//new_field_figure.set_behaviour(array_get(buttons, chosen_button));
		//target_cell.fill(new_field_figure);
		Game.field.create_figure(array_get(buttons, chosen_button), target_cell.xcord, 
		target_cell.ycord, 1, using_figure.owner)
		//array_delete(buttons, chosen_button, 1);
		for (i = 0; i < 3; i++) {
			if i != chosen_button{
				new_figure = new Figure();
				new_figure.set_behaviour(buttons[0]);
				new_figure.draw_x = figure_button_x + figure_button_x_offset*i;
				new_figure.draw_y = figure_button_y;
				new_figure.drop();
			}
			array_delete(buttons, 0, 1);
		}
		if !skip_ui and Game.game_loop_controller.state == STATE_LIST.figure_ability {
			var _draw_index = array_get_index(Game.do_every_step_list, TEST_draw_buttons);
			if _draw_index != -1 {
				array_delete(Game.do_every_step_list, _draw_index, 1);
			}
			var _check_index = array_get_index(Game.do_every_step_list, TEST_buttons_check);
			if _check_index != -1 {
				array_delete(Game.do_every_step_list, _check_index, 1);
			}
		}
	}

	check_ability_targets = function(a = undefined, b = undefined) {
		Game.field.check_controlled_summon_cells(global.turn_owner);
		load_data = Game.user_data.load(global.turn_owner);
		if array_length(load_data.player_figures) < 3 and !global.using_ability{
			Game.field.clear_all_marks();
		}
		if Game.game_loop_controller.action == undefined 
		and Game.game_loop_controller.state == STATE_LIST.figure_ability
		and chosen_button == undefined{
			Game.field.clear_all_marks();
		}
	}
	
	draw = function() {
		if target_cell != undefined{
			if chosen_button != undefined {
				draw_sprite_ext(Behaviours.get_sprite(buttons[chosen_button]), using_figure.image, Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1], 
				Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.5);
			}
			draw_sprite_ext(S_Back_chosen, 0, Game.field.get_cell_xy(target_cell)[0], Game.field.get_cell_xy(target_cell)[1], 
			Game.field.get_figure_scale(), Game.field.get_figure_scale(), 0, c_white, 0.75);
		}
	}
	
	if !skip_ui {
		global.cell_action = function(cell) {
			if (cell.marked) {
				global.cell_click_callback.set_draw_marks(1);
				global.cell_click_callback.remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned));
				global.cell_click_callback = cell;
				cell.set_draw_marks(0);
				cell.add_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned));
				if !Game.game_loop_controller.have_action() {
					Game.ability_input_controller.start_ability();
				}
				Game.game_loop_controller.action.target_cell = cell;
				O_BoardDraw.unblock_end_button()
			}
		}
	}
	
	back = function() {
		if skip_ui {
			chosen_button = undefined;
			target_cell = undefined;
			return;
		}
		if chosen_button != undefined or target_cell != undefined{
			chosen_button = undefined;
			sprite_draw = undefined;
			if target_cell != undefined {
				target_cell.remove_figure_status(FigureStatusList.status(FIGURE_STATUS_LIST.will_be_summoned));
			}
			target_cell = undefined;
			global.cell_click_callback.set_draw_marks(1);
			O_BoardDraw.block_end_button();
			Game.field.clear_all_marks();
			check_ability_targets()
		}
	}
	
	
	export = function() {
		var ex_buttons_array = []
		for (i = 0; i < 3; i++) {
			ex_buttons_array[i] = buttons[i]
		}
		export_data = {
			ex_action: TraderAbility,
			ex_type: "act_ability",
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_buttons: ex_buttons_array,
			ex_chosen_button: chosen_button,
			ex_target_cell: [target_cell.xcord, target_cell.ycord],
			ex_turn_owner: global.turn_owner,
			ex_using_figure: undefined
		}
		return export_data
	}
	
	import = function(_import_data) {
		buttons = _import_data.ex_buttons;
		using_cell = Game.field.get_cell(_import_data.ex_using_cell[0], _import_data.ex_using_cell[1]);
		using_figure = using_cell.filled_figure;
		chosen_button = _import_data.ex_chosen_button;
		target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
	}
}
