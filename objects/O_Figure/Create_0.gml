/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

state = new Figure_state();
state.is_active = 1; 
in_move = false;
owner = global.turn_owner;

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
friendly = true;

set_behaviour = function(new_behaviour) {
	behaviour = Behaviours.get(new_behaviour);
	sprite_index = Behaviours.get_sprite(behaviour);
}

click = function() {
	if state.is_active {
		if global.cell_click_callback.is_filled() and !global.able_to_summon and !global.moving_figure and !global.using_ability{
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
}

get_ability = function() {return Behaviours.get_ablility(behaviour)}
