
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


	able_to_move = true;

	set_behaviour = function(new_behaviour) {
		behaviour = Behaviours.get(new_behaviour);
	}
	
	update_stats = function() {
		if Game.local_player != undefined && owner == Game.local_player.player_id {
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
		place = Game.field.get_place("drop", owner)
		place.add_figure(self, 1);
	}
	
	capture = function(is_on_field) {
		state.is_active = 0;
		state.is_captured = 1;
	}

	conquest = function() {
		state.is_active = 0;
		state.is_conquesting = 1;
		place = Game.field.get_place("capture", owner);
		place.get_new_figure(Game.game_loop_controller.get_opponent(owner));
	}

	click_while_conquesting = function() {
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
