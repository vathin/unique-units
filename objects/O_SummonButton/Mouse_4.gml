/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if(position_meeting(mouse_x, mouse_y, self) and is_active) {
	global.able_to_summon = true;
	instance_create_depth(0, 0, 0, O_SummonInputController)
}

