// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function SpearmanBehaviour() : FigureBehaviour() constructor{
	sprite = S_Spearman;
	index = "spearman";
	card = S_spearman_card;
	logo = S_SpearmanLogo;
	ability = undefined;
	ability_effect_id = "spearman_ability";
	rarity = 1;
	deck_class = "D";
	max_deck_amount = 5;
}
