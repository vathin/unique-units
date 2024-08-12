/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
seconds = 0
all_time = undefined;
current_frame = 0;
active = 0;
start_count = function() {
	self.all_time = Settings.turn_time;
	current_frame = 0;
	seconds = 0;
	active = 1;
}
stop_count = function() {
	active = 0;
}