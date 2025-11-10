figure_inside = undefined;
figure_amount = 1;
image_speed = 0;

clear = function() {
	flexpanel_delete_node(O_DeckManager.card_get_node(figure_inside), 1)
	figure_inside = undefined;
	figure_amount = 0;
	instance_destroy();
}

change_amount = function() {
	figure_amount++;
	if figure_amount > Behaviours.get_max_deck_amount(figure_inside) {
		clear();
	}
}

set_figure = function(_figure, _amount = 1) {
	figure_inside = _figure;
	figure_amount = _amount;
	sprite_index = Behaviours.get_sprite(figure_inside);
}

get_figure = function() {
	return figure_inside
}