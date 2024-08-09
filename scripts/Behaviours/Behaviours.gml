// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Behaviours() constructor{
	static behaviour_list = {
		archer : new ArcherBehaviour(),
		warrior : new WarriorBehaviour(),
		trader : new TraderBehaviour(),
		spearman : new SpearmanBehaviour(),
		shieldbearer : new ShieldbearerBehaviour()
	}

	static get_sprite = function(behaviour_type) {
		return behaviour_list[$ behaviour_type].sprite
	}
	static get = function(behaviour_type) {
		return behaviour_list[$ behaviour_type].index
	}
}

new Behaviours();