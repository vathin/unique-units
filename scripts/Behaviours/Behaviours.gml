// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Behaviours() constructor{
	static figure_list = ["archer", "warrior", "trader", "spearman", "shieldbearer"]
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
	static get_random_figure = function() {
		randomise()
		return array_get(figure_list, random_range(0, array_length(figure_list)));
	}
	static get_figure_card = function(behaviour_type) {
		return behaviour_list[$ behaviour_type].card
	}
}

new Behaviours();