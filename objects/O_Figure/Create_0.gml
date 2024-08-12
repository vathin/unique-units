/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
enum figure_state_list{
	active,
	dropped,
	closed,
	overturned,
	capture,
	surrounded
}

state = figure_state_list.active
in_move = false;
owner = global.turn_owner;
behaviour = Behaviours.get(global.figure_to_summon);

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
sprite_index = Behaviours.get_sprite(global.figure_to_summon);
sprite = Behaviours.get_sprite(global.figure_to_summon);

set_behaviour = function(new_behaviour) {
	behaviour = Behaviours.get(new_behaviour);
}

click = function() {
	if global.cell_click_callback.is_filled() and !global.able_to_summon and !global.moving_figure{
		global.moving_figure = true;
		global.selected_cell = global.cell_click_callback;
		O_GameField.check_clear_move_cells(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		instance_create_depth(0, 0, 0, O_MoveInputController);
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
	}
}

start_move_animation = function(cell, lenght) {
	animation = instance_create_depth(0, 0, 0, O_MoveFigureAnimation);
	animation.start_animation(x, y, cell.x, cell.y, lenght, self);
}