
function SummonAction(target_x, target_y, figure_sprite) : Action() constructor{
	type = "summon"
	self.target_x = target_x;
	self.target_y = target_y;
	self.figure_sprite = figure_sprite;
	O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
	O_SummonButton.back = 1
	execute = function() {
		O_GameField.field[self.target_y][self.target_x].create_figure(global.figure_to_summon)
	}
	draw = function() {
		if target_x != undefined {
			draw_sprite_ext(self.figure_sprite, 0, O_GameField.field[self.target_y][self.target_x].x, O_GameField.field[self.target_y][self.target_x].y, 
			Settings.figure_scale, Settings.figure_scale, 0, c_white, 0.5);
		}
	}
	set_new_target_coordinates = function(new_x, new_y) {
		self.target_x = new_x;
		self.target_y = new_y;
		O_EndTurn.unblock();
		O_SummonButton.change_sprite(S_Back, O_SummonButton.standart_scale);
		O_SummonButton.back = 1;
	}
	
	back = function() {
		if target_x != undefined {
			O_GameField.get_cell(target_x, target_y).marked = 1;
			target_x = undefined;
			target_y = undefined;
			O_EndTurn.block();
			O_SummonButton.change_sprite(figure_sprite, Settings.summon_button_figure_scale);
			O_SummonButton.back = 0;
			global.cell_click_callback = undefined;
		}
	}
}

