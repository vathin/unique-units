/// Default UI renderer for a choice input. It can be replaced through
/// Game.effect_choice_view_factory without changing an effect or controller.
function EffectChoiceView(_spec, _on_select) constructor {
	spec = _spec;
	on_select = _on_select;
	active = true;
	spacing = 82 * (display_get_gui_height() / max(1, room_height));
	center_x = display_get_gui_width() / 2;
	y = display_get_gui_height() / 1.25;

	step = function() {
		if !active {
			return;
		}
		var _offset = (array_length(spec.options) - 1) / 2;
		for (var _index = 0; _index < array_length(spec.options); _index++) {
			var _option = spec.options[_index];
			var _x = center_x + (_index - _offset) * spacing;
			if variable_struct_exists(_option, "behaviour") {
				draw_sprite_ext(Behaviours.get_sprite(_option.behaviour), 0, _x, y, Settings.figure_scale * 1.3, Settings.figure_scale * 1.3, 0, c_white, 1);
			}
			else {
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_text(_x, y, _option.label);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
			}
			if mouse_check_button_pressed(mb_left) {
				var _mouse_x = UI_controller.gui_mouse_x();
				var _mouse_y = UI_controller.gui_mouse_y();
				if point_in_rectangle(_mouse_x, _mouse_y, _x - spacing / 2, y - spacing / 2, _x + spacing / 2, y + spacing / 2) {
					on_select(_option.id);
					return;
				}
			}
		}
	}

	destroy = function() {
		active = false;
		var _step_index = array_get_index(Game.do_every_step_list, step);
		if _step_index != -1 {
			array_delete(Game.do_every_step_list, _step_index, 1);
		}
	}

	array_push(Game.do_every_step_list, step);
}
