// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Figure() constructor{	
	state = new Figure_state();
	state.is_active = 1; 
	image = 0;
	in_move = false;
	overturning = false;
	owner = global.turn_owner;
	previous_ability_cell = undefined;
	previous_ability_target = undefined;
	previous_move_cell = undefined;
	previous_ability_counter = 0;
	previous_move_counter = 0;
	behaviour = undefined;
	draw_x = 0;
	draw_y = 0;
	draw_alpha = 1;
	draw_xscale = Settings.figure_scale;
	draw_yscale = Settings.figure_scale;
	animation_queue = [];


	/*
	image_speed = 0;
	image_xscale = Settings.figure_scale;
	image_yscale = Settings.figure_scale;*/

	able_to_move = true;

	set_behaviour = function(new_behaviour) {
		behaviour = Behaviours.get(new_behaviour);
		//sprite_index = Behaviours.get_sprite(behaviour);
	}
	update_stats = function() {
		if owner == Game.Player1.player_id {
			image = 0;
		}
		else {
			image = 1;
		}
	}
	update_stats();
	
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
		else {previous_ability_counter--}
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


	start_move_animation = function(cell, lenght) {
		//animation = instance_create_depth(0, 0, 0, O_MoveFigureAnimation);
		//animation.start_animation(x, y, cell.x, cell.y, lenght, self);
	}

	add_previous_ability_cell = function(add_cell, add_target) {
		previous_ability_cell = add_cell;
		previous_ability_target = add_target;
		previous_ability_counter = 2;
	}

	add_previous_move_cell = function(add_cell) {
		previous_move_cell = Game.field.get_cell(add_cell[0], add_cell[1]);
		previous_move_counter = 2;
	}
	
	add_animation = function(_new_animation) {
		array_push(animation_queue, _new_animation)
	}
	
	have_animation = function() {
		return (array_length(animation_queue) > 0)
	}

	get_current_animation_controller = function() {
		return animation_queue[0];
	}
	
	animate = function() {
		animation = get_current_animation_controller();
		draw_x = animation.figure_x;
		draw_y = animation.figure_y;
		draw_alpha = animation.figure_alpha;
		draw_xscale = animation.figure_xscale;
		draw_yscale = animation.figure_yscale;
		animation.update_animation();
		if animation.animation_frame >= animation.animation_length {
			array_delete(animation_queue, 0, 1);
		}
	}

	revert_counter = function() {
		previous_ability_counter++;
		previous_move_counter++;
	}

	drop = function() {
		state.is_active = 0;
		state.is_dropped = 1;
		//image_xscale = Settings.figure_scale*0.75;
		//image_yscale = Settings.figure_scale*0.75;
		place = Game.field.get_place("drop", owner)
		place.add_figure(self, 1);
		Game.game_loop_controller.figures_counter.change_field_figures_amount(owner, -1);
	}
	capture = function(is_on_field) {
		state.is_active = 0;
		state.is_captured = 1;
		//image_xscale = Settings.figure_scale*0.75;
		//image_yscale = Settings.figure_scale*0.75;
		//place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(owner));
		//place.add_figure(self);
		if is_on_field {
			Game.game_loop_controller.figures_counter.change_field_figures_amount(owner, -1);
		}
	}

	conquest = function() {
		state.is_active = 0;
		state.is_conquesting = 1;
		place = Game.field.get_place("capture", owner);
		place.get_new_figure(Game.game_loop_controller.get_opponent(owner));
		//place.get_new_figure(Game.game_loop_controller.get_opponent(owner));
		//ov_animation = instance_create_depth(0, 0, 0, O_OverturnFigureAnimation);
		//ov_animation.start_animation(1, 1, 1, 1, 30, self);
		//Game.game_loop_controller.check_win_conditions();
	}

	click_while_conquesting = function() {
		//draw_sprite_ext(S_Conquesting, image_index, x, y, image_xscale, image_yscale, 0, c_white, 0.25);
		//draw_sprite_ext(sprite_index, image_index, O_SummonButton.standart_x, O_SummonButton.standart_y, 
		//Settings.summon_button_figure_scale, Settings.summon_button_figure_scale, 0, c_white, 1);
		//draw_sprite_ext(S_watching_overturned_figure, 0, O_SummonButton.standart_x, O_SummonButton.standart_y, 
		//0.8, 0.8, 0, c_white, 0.35)
		if Game.figure_action_controller != undefined {Game.figure_action_controller.set_buttons_alpha(0);}
	}


	get_ability = function() {return Behaviours.get_ablility(behaviour)}

	export = function() {
		export_data = {
			ex_state: state.export(),
			ex_owner: owner,
			ex_behaviour: behaviour,
			ex_previous_ability_cell: previous_ability_cell,
			ex_previous_ability_target: previous_ability_target,
			ex_previous_move_cell: previous_move_cell,
			ex_previous_ability_counter: previous_ability_counter,
			ex_previous_move_counter: previous_move_counter,
			ex_draw_x: draw_x,
			ex_draw_y: draw_y,
		}
		return export_data
	}

	import = function(import_data) {
		state.import(import_data.ex_state);
		owner = import_data.ex_owner;
		set_behaviour(import_data.ex_behaviour);
		previous_ability_cell = import_data.ex_previous_ability_cell;
		previous_ability_target = import_data.ex_previous_ability_target;
		previous_move_cell = import_data.ex_previous_move_cell;
		previous_ability_counter = import_data.ex_previous_ability_counter;
		previous_move_counter = import_data.ex_previous_move_counter;
		draw_x = import_data.ex_draw_x;
		draw_y = import_data.ex_draw_y;
		update_stats();
	}
}