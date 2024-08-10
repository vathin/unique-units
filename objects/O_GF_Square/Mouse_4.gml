/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) {

	if self.marked and global.moving_figure {
		if O_GameLoopController.have_action(){
			O_GameLoopController.action.set_new_target_coordinates(xcord, ycord);
		}
		else {
			O_MoveInputController.start_move(xcord, ycord);
		}
	}
	
	if (is_filled() and filled_figure.able_to_move and !global.able_to_summon and !global.moving_figure) {
		global.moving_figure = true;
		global.selected_cell = self;
		O_GameField.check_clear_move_cells(xcord, ycord);
		instance_create_depth(0, 0, 0, O_MoveInputController)
	}

	if (global.able_to_summon and !is_filled() and marked) {
		if global.selected_cell = "" {
			marked = 0;
			global.selected_cell = self;
			O_SummonInputController.start_summon(self.xcord, self.ycord);
		}
	else {
		global.selected_cell.marked = 1;
		global.selected_cell = self;
		marked = 0;
		O_GameLoopController.action.set_new_target_coordinates(self.xcord, self.ycord);
	}
}

	
}





