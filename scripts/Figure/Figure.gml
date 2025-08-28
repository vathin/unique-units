
// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Figure() constructor{	
	state = new Figure_state();
	state.is_active = 1; 
	figure_id = "";
	image = 0;
	in_move = false;
	overturning = false;
	owner = global.turn_owner;
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
		//if owner == Game.Player1.player_id {
		if owner == O_LoginController._id {
			image = 0;
		}
		else {
			image = 1;
		}
	}
	update_stats();

	
	add_animation = function(_new_animation) {
		array_push(animation_queue, _new_animation)
	}
	
	have_animation = function() {
		return (array_length(animation_queue) > 0)
	}

	get_current_animation_controller = function() {
		return animation_queue[0];
	}
	
	get_last_animation_controller = function() {
		return animation_queue[array_length(animation_queue)-1]
	}
	
	animate = function() {
		animation = get_current_animation_controller();
		draw_x = animation.figure_x;
		draw_y = animation.figure_y;
		draw_alpha = animation.figure_alpha;
		draw_xscale = animation.figure_xscale;
		draw_yscale = animation.figure_yscale;
		animation.update_animation();
		if array_length(animation_queue) > 1 {
			animation_queue[1].x_from = draw_x;
			animation_queue[1].y_from = draw_y;
			animation_queue[1].figure_x = draw_x;
			animation_queue[1].figure_y = draw_y;
		}
		if animation.animation_frame >= animation.animation_length {
			array_delete(animation_queue, 0, 1);
			
		}
	}



	drop = function() {
		state.is_active = 0;
		state.is_dropped = 1;
		//image_xscale = Settings.figure_scale*0.75;
		//image_yscale = Settings.figure_scale*0.75;
		place = Game.field.get_place("drop", owner)
		place.add_figure(self, 1);
		//Game.game_loop_controller.figures_counter.change_field_figures_amount(owner, -1);
	}
	capture = function(is_on_field) {
		state.is_active = 0;
		state.is_captured = 1;
		//image_xscale = Settings.figure_scale*0.75;
		//image_yscale = Settings.figure_scale*0.75;
		//place = Game.field.get_place("capture", Game.game_loop_controller.get_opponent(owner));
		//place.add_figure(self);
		if is_on_field {
			//Game.game_loop_controller.figures_counter.change_field_figures_amount(owner, -1);
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
			ex_figure_id: figure_id,
			ex_behaviour: behaviour,
			ex_draw_x: draw_x,
			ex_draw_y: draw_y,
			ex_draw_scale: draw_xscale
		}
		return export_data
	}

	import = function(import_data) {
		state.import(import_data.ex_state);
		figure_id = import_data.ex_figure_id;
		owner = import_data.ex_owner;
		set_behaviour(import_data.ex_behaviour);
		draw_x = import_data.ex_draw_x;
		draw_y = import_data.ex_draw_y;
		draw_xscale = import_data.ex_draw_scale;
		draw_yscale = import_data.ex_draw_scale;
		update_stats();
	}
}