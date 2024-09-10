/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

draw_self();
if state.is_conquesting and !overturning{
	if position_meeting(mouse_x, mouse_y, self) and mouse_check_button(mb_left){
		click_while_conquesting();
	}
	else {
		if instance_exists(O_FigureActionController) and !O_FigureActionController.buttons_visiblity {
			O_FigureActionController.set_buttons_alpha(1);
		}
		draw_sprite_ext(S_Conquesting, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
	}
}
