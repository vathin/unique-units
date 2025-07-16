/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
if active 
{
	draw_sprite(S_Login_window, 0, login_window_x, login_window_y )
	draw_set_font(F_test)
	draw_text_transformed(login_x - 156, login_y -40, "Логин:", 0.75, 0.75, 0)
	draw_text_transformed(email_x - 156, email_y -40, "Эл. почта:", 0.75, 0.75, 0)
	draw_text_transformed(password_x - 156, password_y -40, "Пароль:", 0.75, 0.75, 0)
	draw_text_transformed(login_window_x - 255, login_window_y + 130, reason, 0.8, 0.8, 0)
}

if logged_in {
	if room == R_Main_menu {
		invite_button_draw();
		invite_button_check();
		draw_set_font(F_turn_timer)
		draw_text(50, 50, _nickname)
		if invited {
			invite_accept_window_draw();
			invite_accept_window_check();
		}
	}
	if room == R_Invite {
		invite_cancel_button_draw();
		invite_cancel_button_check();
	}
}

