/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if global.moving_figure{
	if marked and draw_mark {
		draw_sprite(S_Move_mark, -1, self.x, self.y);
	}
}
if global.able_to_summon {
	if marked and draw_mark {
		draw_sprite(S_Summon_mark, -1, self.x, self.y);
	}
}
