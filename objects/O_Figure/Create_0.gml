/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_move = false;
owner = "player1";


image_speed = 0;
image_xscale = Settings.figure_scale;
image_yscale = Settings.figure_scale;

able_to_move = true;
friendly = true;
var behaviour;
sprite_index = Behaviours.get_sprite(global.figure_to_summon);
sprite = Behaviours.get_sprite(global.figure_to_summon);

set_behaviour = function(new_behaviour) {
	behaviour = Behaviours.get(new_behaviour);
}

click = function() {
	if global.cell_click_callback.is_filled() and !global.able_to_summon {
		global.moving_figure = true;
		global.selected_cell = global.cell_click_callback;
		O_GameField.check_clear_move_cells(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
		instance_create_depth(0, 0, 0, O_MoveInputController);
	}
	else{
		if global.moving_figure	{
			if O_GameLoopController.have_action(){
				O_GameLoopController.action.set_new_target_coordinates(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
			}
			else {
				O_MoveInputController.start_move(global.cell_click_callback.xcord, global.cell_click_callback.ycord);
			}
		}
	}
}