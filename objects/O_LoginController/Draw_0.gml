/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active 
{
	draw_sprite(S_Login_window, 0, login_window_x, login_window_y )
	draw_set_font(F_test)
	draw_text_transformed(login_x - 156, login_y -40, "Логин:", 0.75, 0.75, 0)
	draw_text_transformed(email_x - 156, email_y -40, "Эл. почта:", 0.75, 0.75, 0)
	draw_text_transformed(password_x - 156, password_y -40, "Пароль:", 0.75, 0.75, 0)
	//draw_text_transformed(login_window_x - 255, login_window_y + 130, reason, 0.8, 0.8, 0)
}

if logged_in {
	if room == R_Main_menu {
		draw_set_font(F_test)
		if reason != "" {draw_text(room_width/2, 215, reason)}
	}
	else if room == R_Game_end {
		draw_set_font(F_menu)
		draw_set_halign(fa_center);
		draw_text(room_width/2, room_height/2, "Победитель: " + _winner)
		var draw_frame = 2
		if _winner == _id {draw_frame = 0}
		else if _winner == enemy {draw_frame = 1}
		else {draw_frame = 2}
		draw_sprite_ext(Spr_end_game, draw_frame, room_width/2, room_height/3.8, 1.2, 1.2, 0, c_white, 1);
		draw_set_halign(fa_left);
	}
}

