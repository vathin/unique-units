/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

event_inherited();
if type == "Mode_switch" {
	draw_set_halign(fa_center);
	draw_set_font(F_test)
	if UI_controller.login_mode == LOGIN_MODES.login {
		draw_text(x, y-15, "У меня нет аккаунта")
	}
	else {
		draw_text(x, y-15, "У меня уже есть аккаунт")
	}
	draw_set_font(F_menu)
	draw_set_halign(fa_left)
}
