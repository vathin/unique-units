// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function WarriorBehaviour() : FigureBehaviour() constructor{
	sprite = S_Warrior;
	index = "warrior";
	card = S_warrior_card;
	logo = S_WarriorLogo;
	ability = undefined;
	move_effect_id = "warrior_move";
	ability_effect_id = "warrior_ability";
	rarity = 2;
	deck_class = "C";
	max_deck_amount = 5;
}
