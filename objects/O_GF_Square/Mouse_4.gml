/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) {

	if self.marked_for_move {
		O_GameField.figure_place_set(xcord, ycord)
	}
	
	if (self.filled and filled_figure.able_to_move and !global.able_to_summon) {
		if !global.moving_figure{
			global.moving_figure = true;
			global.chosen_figure = filled_figure;
			global.selected_cell = self;
			O_GameField.check_clear_move_cells(xcord, ycord);
			O_SummonButton.change_sprite(S_Move_active, 2.32)
			{
		}
	}
}
}
if (position_meeting(mouse_x, mouse_y, self) and global.able_to_summon) {

	create_figure(global.figure_to_summon);
}

