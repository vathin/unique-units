// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function ShieldbearerBehaviour() : FigureBehaviour() constructor{
	sprite = S_Shieldbearer;
	index = "shieldbearer";
	card = S_shieldbearer_card;
	logo = S_ShieldbearerLogo;
	ability = ShieldbearerAbility;
	move_ability = StandartMoveAbility;
	rarity = 3;
	max_deck_amount = 10;
}