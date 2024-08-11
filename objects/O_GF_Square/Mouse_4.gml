/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

if position_meeting(mouse_x, mouse_y, self) {

	if self.marked and global.moving_figure {
		figure_to_move = global.selected_cell.filled_figure;
		global.cell_click_callback = self;
		figure_to_move.click();
	}
	
	if (is_filled() and filled_figure.able_to_move and !global.able_to_summon and !global.moving_figure) {
		global.cell_click_callback = self;
		filled_figure.click();
	}

	if (global.able_to_summon and marked) {
		global.cell_click_callback = self;
		O_GameLoopController.chooze_cell_for_summon();
	}	
}





