// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function TraderBehaviour() : FigureBehaviour() constructor{
	sprite = S_Trader;
	index = "trader";
	card = S_trader_card;
	logo = S_TraderLogo;
	ability = undefined;
	ability_effect_id = "trader_ability";
	rarity = 5;
	deck_class = "S";
	max_deck_amount = 1;
}
