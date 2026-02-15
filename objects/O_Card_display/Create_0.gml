is_active = 0;
rarity = 0;

set_figure = function(_new_figure) {
	figure_to_display = _new_figure
	update_sprite();
}

update_sprite = function() {
	if figure_to_display != "" {
		sprite_index = Behaviours.get_card_sprite(figure_to_display);
		rarity = Behaviours.get_rarity(figure_to_display);
	}
}
update_sprite();