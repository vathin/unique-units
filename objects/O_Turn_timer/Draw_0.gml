/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

draw_set_font(F_turn_timer);
seconds = all_time div Settings.FPS - current_frame div Settings.FPS;
if seconds < 10{draw_text(825, 190, (seconds))}
else {draw_text(815, 190, (seconds))}