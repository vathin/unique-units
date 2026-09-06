resize_frame += 1;

if (resize_frame == resize_ready_frame) {
	sync_gui_size(true);
}
else {
	sync_gui_size();
}

if (!saved_login_fields_loaded && resize_frame >= resize_ready_frame) {
	load_saved_login_fields();
}

if (room != R_Main_menu) {
	local_game_text_applied = false;
}
else if (!local_game_text_applied && resize_frame > 0) {
	set_text_on_child_panel("MenuHome", "FastSearch", "Text", "ОДИНОЧНАЯ ИГРА");
	local_game_text_applied = true;
}
