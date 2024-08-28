// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function TraderAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	figure_button_x = O_GameField.x + 140;
	figure_button_y = 1060;
	summon_controller = undefined;
	chosen_button = undefined;
	O_SummonButton.go_away();
	sprite_draw = undefined
	global.mark = S_Summon_mark;
	buttons = []
	O_EndTurn.active = 0
	O_GameLoopController.set_can_cancel(0);
	create_buttons = function() {
		load_data = O_App.data.load(global.turn_owner);
		used_array = load_data.player_figures
		for (i = 0; i < 3; i ++) {
			new_button = instance_create_depth(figure_button_x, figure_button_y, 0, O_TraderAbilityButton);
			new_button.set_sprite(array_pop(load_data.player_figures));
			new_button.ability = self;
			buttons[i] = new_button
			figure_button_x += 130;
		}
		O_App.data.save(global.turn_owner, load_data)
	}
	if global.using_ability {create_buttons()}
	
	execute = function() {
		global.cell_click_callback.create_figure(chosen_button.figure_type);
		instance_destroy(chosen_button)
		for (i = 0; i < 3; i++) {
			try {
				new_figure = instance_create_depth(buttons[i].x, buttons[i].y, 1, O_Figure);
				new_figure.set_behaviour(buttons[i].figure_type);
				show_debug_message(buttons[i].figure_type)
				new_figure.drop();
				instance_destroy(buttons[i]);
			}
			catch (exception) {}
			}
		}
	
	check_ability_targets = function(a, b) {
		O_GameField.check_controlled_summon_cells(global.turn_owner);
		load_data = O_App.data.load(global.turn_owner);
		if array_length(load_data.player_figures) < 3 and !global.using_ability{
			O_GameField.clear_all_marks();	
		}
	}
	
	draw = function() {
		if chosen_button != undefined {
			draw_sprite_ext(sprite_draw, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	
	global.cell_action = function(cell) {
		if (cell.marked) {
			if !O_GameLoopController.have_action() {O_AbilityInputController.start_ability()}
			if O_GameLoopController.action.chosen_button != undefined {O_EndTurn.active = 1}
			global.cell_click_callback.set_draw_marks(1)
			global.cell_click_callback = cell;
			cell.set_draw_marks(0)
		}
	}
	
	click_callback = function(button) {
		if chosen_button != undefined {chosen_button.image_alpha = 1}
		global.figure_to_summon = button.figure_type
		sprite_draw = Behaviours.get_sprite(button.figure_type)
		chosen_button = button;
		chosen_button.image_alpha = 0.65;
		if O_GameLoopController.have_action() {O_EndTurn.active = 1}
	}

}