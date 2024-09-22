/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active {
	if current_frame <= all_time {
		current_frame ++;
		using_time_bank = 0;
	}
	else {
		if get_player_time_bank(global.turn_owner) > 1 {
			use_time_bank(global.turn_owner);
		}
		else {
			if O_GameLoopController.can_cancel {O_GameLoopController.cancel_action()}
			//if instance_exists(O_SummonInputController) {O_SummonInputController.time_end()}
			player_out_of_time = global.turn_owner;
			O_GameLoopController.end_move();
	}
	}
}