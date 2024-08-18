// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function ArcherBehaviour() : FigureBehaviour() constructor{
	sprite = S_Archer;
	index = "archer";
	card = S_archer_card;
	ability = undefined;
	move_ability = StandartMoveAbility;
}