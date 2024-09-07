/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if(position_meeting(mouse_x, mouse_y, self) and !is_blocked() and global.input) {
	instance_create_depth(0, 0, 0, O_SummonInputController)
	block()
}
if (position_meeting(mouse_x, mouse_y, self) and back) {
	if O_GameLoopController.have_action() {O_GameLoopController.action.back()}
	if instance_exists(O_MoveInputController) {O_MoveInputController.back()}
	if instance_exists(O_AbilityInputController) {O_AbilityInputController.back()}
}

