
function FigureAbilityAction() : Action() constructor{
	back = function() {
		instance_create_depth(0, 0, 0, O_FigureActionController);
		O_GameField.clear_all_marks();
		O_SummonButton.go_away();
		global.cell_click_callback = global.selected_cell;
		O_GameLoopController.action = undefined;
	}
}