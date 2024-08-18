// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function SpearmanBehaviour() : FigureBehaviour() constructor{
	sprite = S_Spearman;
	index = "spearman";
	card = S_spearman_card;
	ability = SpearmanAbility;
	move_ability = StandartMoveAbility;
}