// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function ShieldbearerBehaviour() : FigureBehaviour() constructor{
	sprite = S_Shieldbearer;
	index = "shieldbearer";
	card = S_shieldbearer_card;
	logo = S_ShieldbearerLogo;
	ability = undefined;
	ability_effect_id = "shieldbearer_ability";
	rarity = 3;
	deck_class = "B";
	max_deck_amount = 5;
}
