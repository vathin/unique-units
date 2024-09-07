/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if current_frame <= all_time and active{
	current_frame ++;
}
else {
	if O_GameLoopController.can_cancel {O_GameLoopController.cancel_action()}
	if instance_exists(O_SummonInputController) {O_SummonInputController.time_end()}
	O_GameLoopController.end_move();
}