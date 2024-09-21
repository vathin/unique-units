/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

state = new Figure_state();
state.is_active = 1; 
in_move = false;
overturning = false;
owner = global.turn_owner;
previous_ability_cell = undefined;
previous_ability_target = undefined;
previous_move_cell = undefined;
previous_ability_counter = 0;
previous_move_counter = 0;


if owner = "player1" {
	image_index = 0;
}
else {
	image_index = 1;
}
image_speed = 0;
image_xscale = Settings.figure_scale;
image_yscale = Settings.figure_scale;

able_to_move = true;

set_behaviour = function(new_behaviour) {
	behaviour = Behaviours.get(new_behaviour);
	sprite_index = Behaviours.get_sprite(behaviour);
}
update_stats = function() {
	if owner == "player1" {
		image_index = 0;
	}
	else {
		image_index = 1;
	}
}

clear_previous_move_cell = function() {
	previous_move_cell = undefined;
}

clear_previous_ability_cell = function() {
	previous_ability_target = undefined;
	previous_ability_cell = undefined;
}

check_previous_ability_targets = function() {
	if previous_ability_counter == 0 {
		if previous_ability_cell != undefined {
			clear_previous_ability_cell();
		}
	}
	else {previous_ability_counter --}
	if !instance_exists(previous_ability_target) or previous_ability_target.state.is_dropped {
		clear_previous_ability_cell()
	}
}

check_previous_move_cell = function() {
	if previous_move_counter == 0 {
		if previous_move_cell != undefined {
			clear_previous_move_cell();
		}
	}
	else {previous_move_counter--}
}

check_cycle_rule = function() {
	check_previous_ability_targets();
	check_previous_move_cell();
}

click = function() {
	if state.is_active {
		if !global.able_to_summon and !global.moving_figure and !global.using_ability{
			global.selected_cell = global.cell_click_callback;
			instance_create_depth(0, 0, 0, O_FigureActionController);
		}
		else{
			if global.moving_figure	and !global.cell_click_callback.is_filled(){
				if O_GameLoopController.have_action() {
					O_GameLoopController.action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
				}
				else {
					O_MoveInputController.start_move(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
				}
			}
			if global.using_ability {
				if O_GameLoopController.have_action() {
					O_GameLoopController.action.set_target(self, global.cell_click_callback);
				}
				else {
					O_AbilityInputController.start_ability();
					O_GameLoopController.action.set_target(self, global.cell_click_callback);
				}
			}
		}
	}
}

start_move_animation = function(cell, lenght) {
	animation = instance_create_depth(0, 0, 0, O_MoveFigureAnimation);
	animation.start_animation(x, y, cell.x, cell.y, lenght, self);
}

add_previous_ability_cell = function(add_cell, add_target) {
	previous_ability_cell = add_cell;
	previous_ability_target = add_target;
	previous_ability_counter = 2;
}

add_previous_move_cell = function(add_cell) {
	previous_move_cell = add_cell;
	previous_move_counter = 2;
}

revert_counter = function() {
	previous_ability_counter++;
	previous_move_counter++;
}

drop = function() {
	state.is_active = 0;
	state.is_dropped = 1;
	image_xscale = Settings.figure_scale*0.75;
	image_yscale = Settings.figure_scale*0.75;
	place = O_GameField.get_place("drop", owner)
	place.add_figure(self);
	O_Figures_counter.change_field_figures_amount(owner, -1);
}
capture = function(is_on_field) {
	state.is_active = 0;
	state.is_captured = 1;
	image_xscale = Settings.figure_scale*0.75;
	image_yscale = Settings.figure_scale*0.75;
	place = O_GameField.get_place("capture", O_GameLoopController.get_opponent(owner));
	place.add_figure(self);
	if is_on_field {
		O_Figures_counter.change_field_figures_amount(owner, -1);
	}
}

conquest = function() {
	state.is_active = 0;
	state.is_conquesting = 1;
	O_GameField.player2_captured.get_new_figure(O_GameLoopController.get_opponent(owner));
	ov_animation = instance_create_depth(0, 0, 0, O_OverturnFigureAnimation);
	ov_animation.start_animation(1, 1, 1, 1, 30, self);
	O_GameLoopController.check_win_conditions();
}

click_while_conquesting = function() {
	draw_sprite_ext(S_Conquesting, image_index, x, y, image_xscale, image_yscale, 0, c_white, 0.25);
	draw_sprite_ext(sprite_index, image_index, O_SummonButton.standart_x, O_SummonButton.standart_y, 
	Settings.summon_button_figure_scale, Settings.summon_button_figure_scale, 0, c_white, 1);
	draw_sprite_ext(S_watching_overturned_figure, 0, O_SummonButton.standart_x, O_SummonButton.standart_y, 
	0.8, 0.8, 0, c_white, 0.35)
	if instance_exists(O_FigureActionController) {O_FigureActionController.set_buttons_alpha(0);}
}


get_ability = function() {return Behaviours.get_ablility(behaviour)}

export = function() {
	export_data = {
		ex_state: state,
		ex_owner: owner,
		ex_behaviour: behaviour,
		ex_previous_ability_cell: previous_ability_cell,
		ex_previous_ability_target: previous_ability_target,
		ex_previous_move_cell: previous_move_cell,
		ex_previous_ability_counter: previous_ability_counter,
		ex_previous_move_counter: previous_move_counter
	}
	return export_data
}

import = function(import_data) {
	state = import_data.ex_state;
	owner = import_data.ex_owner;
	set_behaviour(import_data.ex_behaviour);
	previous_ability_cell = import_data.ex_previous_ability_cell;
	previous_ability_target = import_data.ex_previous_ability_target;
	previous_move_cell = import_data.ex_previous_move_cell;
	previous_ability_counter = import_data.ex_previous_ability_counter;
	previous_move_counter = import_data.ex_previous_move_counter;
	update_stats();
}