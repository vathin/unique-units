/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

O_SummonButton.change_sprite(S_Move_active, 2.32)
global.mark = S_Move_mark

start_move = function(to_x,to_y) {
	O_GameLoopController.set_action(new MoveAction(global.selected_cell.xcord, global.selected_cell.ycord, 
		to_x, to_y, global.selected_cell.filled_figure.sprite_index));
	instance_destroy();
	
}