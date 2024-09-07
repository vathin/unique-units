/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

draw_self();
if state.is_conquesting and !overturning{
	if position_meeting(mouse_x, mouse_y, self) {
		draw_sprite_ext(S_Conquesting, image_index, x, y, image_xscale, image_yscale, 0, c_white, 0.25);
	}
	else {
		draw_sprite_ext(S_Conquesting, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
	}
}
