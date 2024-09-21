
function FigureAbilityAction() : Action() constructor{
	back = function() {
		O_GameField.clear_all_marks();
		O_SummonButton.go_away();
		global.cell_click_callback = global.selected_cell;
		global.using_ability = 0;
		instance_create_depth(0, 0, 0, O_FigureActionController);
		O_GameLoopController.action = undefined;
	}
	draw_previous_ability_cell = false;
	draw_previous_move_cell = false;
}