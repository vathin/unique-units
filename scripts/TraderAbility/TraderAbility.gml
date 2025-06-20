// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function TraderAbility(using_figure, using_cell) : FigureAbilityAction() constructor{
	figure_button_x = room_width/2 -130;
	figure_button_y = 1045;
	self.using_figure = using_figure;
	chosen_button = undefined;
	O_BoardDraw.block_end_button();
	sprite_draw = undefined;
	target_cell = undefined;
	global.mark = S_Summon_mark;
	buttons = []
	
	change_summon_button = function() {
		//O_SummonButton.back = 0;
		//O_SummonButton.y = O_SummonButton.standart_y + 75;
		//O_SummonButton.change_sprite(O_SummonButton.standart_sprite, 0.2);
		//O_SummonButton.image_index = 2
	}
	
	create_buttons = function() {
		Game.game_loop_controller.set_can_cancel(0);
		load_data = Game.data.load(using_figure.owner);
		used_array = load_data.player_figures;
		for (i = 0; i < 3; i ++) {
			new_button = instance_create_depth(figure_button_x, figure_button_y, 0, O_TraderAbilityButton);
			new_button.set_sprite(array_pop(load_data.player_figures));
			new_button.ability = self;
			buttons[i] = new_button
			figure_button_x += 130;
		}
		
		Game.data.save(using_figure.owner, load_data);
	}
	if global.using_ability {
		create_buttons();
		change_summon_button();
	}
	
	execute = function() {
		Game.game_loop_controller.figures_counter.change_field_figures_amount(using_figure.owner, +1);
		new_field_figure = new Figure()
		new_field_figure.set_behaviour(chosen_button.figure_type)
		target_cell.fill(new_field_figure)
		array_delete(buttons, array_get_index(buttons, chosen_button), 1)
		for (i = 0; i < 2; i++) {
			if instance_exists(buttons[i]) {
				new_figure = new Figure()
				new_figure.set_behaviour(buttons[i].figure_type);
				new_figure.drop();
				array_delete(buttons, i, 1);
			}
		}
	}

	check_ability_targets = function(a, b) {
		Game.field.check_controlled_summon_cells(global.turn_owner);
		load_data = Game.data.load(global.turn_owner);
		if array_length(load_data.player_figures) < 3 and !global.using_ability{
			Game.field.clear_all_marks();
		}
		if Game.ability_input_controller != undefined{
			Game.ability_input_controller.start_ability();
			Game.field.clear_all_marks();
		}
	}
	
	draw = function() {
		if chosen_button != undefined and target_cell != undefined{
			draw_sprite_ext(sprite_draw, 0, global.cell_click_callback.x, global.cell_click_callback.y, 
		Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	
	global.cell_action = function(cell) {
		if (cell.marked) {
			global.cell_click_callback.set_draw_marks(1);
			global.cell_click_callback = cell;
			if Game.game_loop_controller.action.chosen_button != undefined {
				cell.set_draw_marks(0)
				}
			cell.set_draw_marks(0)
			Game.game_loop_controller.action.target_cell = cell;
			O_BoardDraw.unblock_end_button()
		}
	}
	
	click_callback = function(button) {
		/*if chosen_button != undefined {chosen_button.image_alpha = 1}
		//global.figure_to_summon = button.figure_type;
		sprite_draw = Behaviours.get_sprite(button.figure_type);
		chosen_button = button;
		chosen_button.image_alpha = 0.65;
		O_SummonButton.change_sprite(S_Back, 0.2);
		O_SummonButton.image_index = 0;
		O_SummonButton.back = 1;*/
		if target_cell == undefined{check_ability_targets(1, 1);}
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
			ex_using_figure: using_figure,
			ex_using_cell: undefined,
			ex_buttons: buttons,
			ex_target_cell: [target_cell.xcord, target_cell.ycord],
			ex_turn_owner: global.turn_owner
		}
		return export_data
	}
	import = function(_import_data) {
		buttons = _import_data.ex_buttons;
		target_cell = Game.field.get_cell(_import_data.ex_target_cell[0], _import_data.ex_target_cell[1]);
	}
}