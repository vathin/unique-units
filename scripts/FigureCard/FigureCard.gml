// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureCard() constructor{
	rarity = 0;
	figure_ = undefined;
	sprite = undefined;
	draw_x = 0;
	draw_y = 0;
	scale = 0.1
	
	draw = function() {draw_sprite_ext(sprite, 0, draw_x, draw_y, scale, scale, 0, c_white, 1)}
	
	set_cord = function(_x, _y) {
		draw_x = _x;
		draw_y = _y;
	}
	
	set_figure = function(_behaviour) {
		figure_ = _behaviour;
		sprite = Behaviours.get_card_sprite(_behaviour);
		rarity = Behaviours.get_rarity(_behaviour);
	}
	get_rarity = function() {
		return rarity
	}
}