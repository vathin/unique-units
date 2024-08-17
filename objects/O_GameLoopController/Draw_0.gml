/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if have_action() {
	action.draw();
}
draw_set_font(F_test);
if global.turn_owner = "player1" {
	draw_text(955, 30, "ходит игрок 1");
}
else {
	draw_text(955, 30, "ходит игрок 2");
}
draw_text(1110, 510, "плен")
draw_text(490 , 510, "сброс")