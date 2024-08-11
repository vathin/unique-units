/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active and position_meeting(mouse_x, mouse_y, self){
	if (global.moving_figure and O_GameLoopController.have_action()) {
		O_GameLoopController.end_move();
		O_GameLoopController.clear_all();
    }
	if (global.able_to_summon and O_GameLoopController.have_action()) {
		O_GameLoopController.end_move();
		O_GameLoopController.clear_all();
	}
}