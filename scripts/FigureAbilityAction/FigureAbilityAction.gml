
function FigureAbilityAction() : Action() constructor{
	back = function() {
		Game.field.clear_all_marks();
		//O_SummonButton.go_away();
		global.cell_click_callback = global.selected_cell;
		global.using_ability = 0;
		Game.figure_action_controller = new FigureActionController()
		Game.game_loop_controller.action = undefined;
	}
	draw_previous_move_cell = false;
}