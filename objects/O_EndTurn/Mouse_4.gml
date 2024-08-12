/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active and position_meeting(mouse_x, mouse_y, self){
	if (O_GameLoopController.have_action()) {
		O_GameLoopController.end_move();
    }
}