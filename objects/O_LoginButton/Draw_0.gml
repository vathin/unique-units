/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

draw_self()
draw_set_font(F_test)
if type == "Login_acc" {draw_text_transformed(x-sprite_width/2 + 7, y- sprite_height/3, "Логин", 0.7, 0.7, 0)}
else if type == "Register_acc" {draw_text_transformed(x-sprite_width/2 + 7, y- sprite_height/3, "Регистр.", 0.7, 0.7, 0)}
