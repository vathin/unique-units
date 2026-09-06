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
