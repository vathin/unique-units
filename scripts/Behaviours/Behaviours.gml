// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Behaviours() constructor{
	static figure_list = ["archer", "warrior", "trader", "spearman", "shieldbearer"];
	static behaviour_list = {
		archer : new ArcherBehaviour(),
		warrior : new WarriorBehaviour(),
		trader : new TraderBehaviour(),
		spearman : new SpearmanBehaviour(),
		shieldbearer : new ShieldbearerBehaviour()
	}

	static has = function(behaviour_type) {
		if (is_undefined(behaviour_type)) {return false}
		return variable_struct_exists(behaviour_list, string(behaviour_type));
	}
	static get_behaviour = function(behaviour_type) {
		if !has(behaviour_type) {
			show_debug_message("Behaviours: unknown behaviour type: " + string(behaviour_type));
			return undefined;
		}
		return behaviour_list[$ string(behaviour_type)];
	}
	static get_sprite = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return -1}
		return _behaviour.sprite
	}
	static get_card_sprite = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return -1}
		return _behaviour.card
	}
	static get_logo_sprite = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return -1}
		return _behaviour.logo
	}
	static get = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return undefined}
		return _behaviour.index
	}
	static get_rarity = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return 0}
		return _behaviour.rarity
	}
	static get_max_deck_amount = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return 0}
		return _behaviour.max_deck_amount
	}
	static get_random_figure = function() {
		randomise()
		return array_get(figure_list, random_range(0, array_length(figure_list)));
	}
	static get_ablility = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return undefined}
		return _behaviour.ability
	}
	static get_move_ability = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return undefined}
		return _behaviour.move_ability
	}
	static have_ability = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return false}
		return _behaviour.ability != undefined
	}
}

new Behaviours();
