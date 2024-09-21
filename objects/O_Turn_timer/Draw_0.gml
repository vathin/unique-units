/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

draw_set_font(F_turn_timer);
if !using_time_bank {
	seconds = all_time div Settings.FPS - current_frame div Settings.FPS;
	if seconds <= 15 {draw_set_color(c_orange)}
	if seconds = 9 {draw_x += 0.15}
	if seconds < 1 {draw_set_color(c_red)}
}
else {
	draw_set_color(c_red);
	bank_seconds = get_player_time_bank(global.turn_owner) div Settings.FPS;
	draw_text_transformed(random_range((draw_x + 47), (draw_x + 53)), random_range((draw_y - 10), (draw_y - 15)), bank_seconds, 1.25, 1.25, 0);
}
draw_text(draw_x, draw_y, seconds);
draw_set_color(c_white);