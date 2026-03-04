function FindArcherTrajectory(_x_from, _y_from, _x_to, _y_to){
	x_from = _x_from;
	y_from = _y_from;
	x_to = _x_to;
	y_to = _y_to
	{
	var _ability = new ArcherMoveAbility(_x_from, _y_from, _x_to, _y_to, undefined);
	Game.field.clear_all_marks();
	_ability.check_all_cells();
	}
	current_trajectory_length = 0;
	min_trajectory_length = 99999;
	best_trajectory = [];
	trajectory = array_create(60, [])
	cell_array = [];
	for (var i = 0; i < 6; i++) {
		for (var m = 0; m < 6; m++) {
			cell_array[m][i] = ArcherMoveAbility_Cell.uncalculated;
		}
	}
	var _available_cells = Game.field.get_marked_cells();
	
	check_cell = function(_x, _y) {
		cell_array[_x, _y] = ArcherMoveAbility_Cell.calculated;
		trajectory[current_trajectory_length] = [_x, _y];
		if current_trajectory_length >= min_trajectory_length {
			cell_array[_x, _y] = ArcherMoveAbility_Cell.uncalculated;
			return false;
			}
		current_trajectory_length += 1;
		for (var i = -1; i < 2; i++) {
			for (var m = -1; m < 2; m++) {
				if Game.field.get_cell(_x + m, _y + i) != undefined {
					if _x + m == x_to and  _y + i == y_to {
						trajectory[current_trajectory_length] = [_x + m, _y + i];
						min_trajectory_length = current_trajectory_length;
						best_trajectory = [];
						array_copy(best_trajectory, 0, trajectory, 0, min_trajectory_length+1);
						current_trajectory_length -= 1;
						cell_array[_x, _y] = ArcherMoveAbility_Cell.uncalculated;
						return true;
					}
					if (Game.field.get_cell(_x + m, _y + i).is_marked()
					and cell_array[_x + m][_y + i] == ArcherMoveAbility_Cell.uncalculated) {
						check_cell(_x + m, _y + i);
					}
				}
			}
		}
		current_trajectory_length -= 1;
		cell_array[_x, _y] = ArcherMoveAbility_Cell.uncalculated;
	}
	check_cell(_x_from, _y_from);
	Game.field.clear_all_marks();
	return best_trajectory;
}