resize_frame += 1;

if (resize_frame == resize_ready_frame) {
	sync_gui_size(true);
}
else {
	sync_gui_size();
}

if (keyboard_check_pressed(vk_escape) && (room == R_Test || room == R_Game)) {
	if (variable_global_exists("game") && global.game != undefined && global.game.in_match) {
		global.game.end_game();
	}
	room_goto(R_Main_menu);
}

if (!saved_login_fields_loaded && resize_frame >= resize_ready_frame) {
	load_saved_login_fields();
}
