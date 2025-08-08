// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureCard() constructor{
	rarity = 0;
	figure_ = undefined;
	sprite = undefined;
	
	set_figure = function(_behaviour) {
		figure_ = _behaviour;
		sprite = Behaviours.get_sprite(_behaviour);
		rarity = Behaviours.get_rarity(_behaviour);
	}
	get_rarity = function() {
		return rarity
	}
}