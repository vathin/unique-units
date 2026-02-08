event_inherited();
figure_inside = undefined;

set_figure = function(_figure) {
	figure_inside = _figure;
	sprite_index = Behaviours.get_card_sprite(_figure)
}
set_figure("warrior");

//O_DeckManager.card_click(figure_inside)