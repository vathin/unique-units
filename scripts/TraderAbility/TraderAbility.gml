// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function TraderAbility(_using_figure=undefined, _using_cell=undefined) : FigureAbilityAction() constructor{
	figure_button_x = room_width/2 - 130;
	figure_button_y = room_height/1.25 - 50;
	figure_button_x_offset = 130;
	using_figure = _using_figure;
	using_cell = _using_cell;
	chosen_button = undefined;
	O_BoardDraw.block_end_button();
	sprite_draw = undefined;
	target_cell = undefined;
	global.mark = S_Summon_mark;
	buttons = [];
	
	change_summon_button = function() {
		//O_SummonButton.back = 0;
		//O_SummonButton.y = O_SummonButton.standart_y + 75;
		//O_SummonButton.change_sprite(O_SummonButton.standart_sprite, 0.2);
		//O_SummonButton.image_index = 2
	}
	
	create_buttons = function() {
		Game.game_loop_controller.set_can_cancel(0);
		load_data = Game.user_data.load(using_figure.owner);
		for (i = 0; i < 3; i ++) {
			//new_button = instance_create_depth(figure_button_x, figure_button_y, 0, O_TraderAbilityButton);
			//new_button.set_sprite(array_pop(load_data.player_figures));
			//new_button.ability = self;
			buttons[i] = array_pop(load_data.player_figures);
			//figure_button_x += 130;
		}
		
		figure_button_x = room_width/2 - figure_button_x_offset
		
		Game.user_data.save(using_figure.owner, load_data);
	}
	
	TEST_draw_buttons = function() {
		if buttons != [] {
			for (i = 0; i < 3; i ++) {
				if chosen_button == i  or target_cell == undefined{draw_set_alpha(0.5)}
				draw_text(figure_button_x + figure_button_x_offset*i-10, figure_button_y-10, 
				(string_char_at(buttons[i], 0) + string_char_at(buttons[i], 2)));
				draw_set_alpha(1);
			}
		}
		if Game.game_loop_controller.state != STATE_LIST.figure_ability 
		{array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, self), 1)}
	}
	
	TEST_buttons_check = function() {
		if mouse_check_button_pressed(mb_left) {
			if target_cell != undefined {
				if mouse_y > figure_button_y - 25 and mouse_y < figure_button_y + 45 {
					if mouse_x > figure_button_x - 40 and mouse_x < figure_button_x + 50 {
						chosen_button = 0;
					} 
					if mouse_x > figure_button_x - 40 + figure_button_x_offset and
					mouse_x < figure_button_x + 50 + figure_button_x_offset {
						chosen_button = 1;
					} 
					if mouse_x > figure_button_x - 40 + 2*figure_button_x_offset and 
					mouse_x < figure_button_x + 50 + 2*figure_button_x_offset{
						chosen_button = 2;
					} 
					if chosen_button != undefined {O_BoardDraw.unblock_end_button()}
				}
			}
		}
		if Game.game_loop_controller.state != STATE_LIST.figure_ability 
		{array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, self), 1)}
	}
	
	if Game.game_loop_controller.state == STATE_LIST.figure_ability {
		create_buttons();
		array_push(Game.do_every_step_list, TEST_draw_buttons);
		array_push(Game.do_every_step_list, TEST_buttons_check);
		Game.game_loop_controller.set_can_cancel(0);
		//change_summon_button();
	}
	
	execute = function() {
		Game.game_loop_controller.figures_counter.change_field_figures_amount(using_figure.owner, 1);
		new_field_figure = new Figure()
		new_field_figure.set_behaviour(array_get(buttons, chosen_button))
		target_cell.fill(new_field_figure)
		array_delete(buttons, chosen_button, 1)
		for (i = 0; i < 2; i++) {
			new_figure = new Figure()
			new_figure.set_behaviour(buttons[0]);
			new_figure.drop();
			array_delete(buttons, 0, 1);
		}
		array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, TEST_draw_buttons), 1);
		array_delete(Game.do_every_step_list, array_get_index(Game.do_every_step_list, TEST_buttons_check), 1);
	}

	check_ability_targets = function(a, b) {
		Game.field.check_controlled_summon_cells(global.turn_owner);
		load_data = Game.user_data.load(global.turn_owner);
		if array_length(load_data.player_figures) < 3 and !global.using_ability{
			Game.field.clear_all_marks();
		}
		if Game.ability_input_controller != undefined{
			Game.ability_input_controller.start_ability();
			Game.field.clear_all_marks();
		}
	}
	
	draw = function() {
		//if chosen_button != undefined and target_cell != undefined{
			//draw_sprite_ext(sprite_draw, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
		//Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		//}
	}
	
	global.cell_action = function(cell) {
		if (cell.marked) {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback = cell;
			cell.set_draw_marks(0)
			if !Game.game_loop_controller.have_action() {
				Game.ability_input_controller.start_ability();
				O_BoardDraw.block_end_button();
			}
			Game.game_loop_controller.action.target_cell = cell;
			//O_BoardDraw.unblock_end_button()
		}
	}
	
	click_callback = function(button) {
		/*if chosen_button != undefined {chosen_button.image_alpha = 1}
		global.figure_to_summon = button.figure_type;
		sprite_draw = Behaviours.get_sprite(button.figure_type);
		chosen_button = button;
		chosen_button.image_alpha = 0.65;
		O_SummonButton.change_sprite(S_Back, 0.2);
		O_SummonButton.image_index = 0;
		//O_SummonButton.back = 1;
		if target_cell == undefined{check_ability_targets(1, 1);}*/
	}
	
	back = function() {
		if chosen_button != undefined or target_cell != undefined{
			//chosen_button.image_alpha = 1;
			chosen_button = undefined;
			sprite_draw = undefined;
			target_cell = undefined;
			global.cell_click_callback.set_draw_marks(1);
			//O_SummonButton.change_sprite(O_SummonButton.standart_sprite, 0.2);
			//O_SummonButton.image_index = 2;
			//O_SummonButton.back = 0;
			O_BoardDraw.block_end_button();
			Game.field.clear_all_marks();
		}
	}
	
	
	export = function() {
		export_data = {
			ex_action: TraderAbility,
			ex_type: "act_ability",
			ex_using_cell: [using_cell.xcord, using_cell.ycord],
			ex_buttons: buttons,
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