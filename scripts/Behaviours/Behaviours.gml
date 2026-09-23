// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Behaviours() constructor{
	static figure_list = ["archer", "warrior", "trader", "spearman", "shieldbearer"];
	static behaviour_list = {
		archer : new ArcherBehaviour(),
		warrior : new WarriorBehaviour(),
		trader : new TraderBehaviour(),
		spearman : new SpearmanBehaviour(),
		shieldbearer : new ShieldbearerBehaviour(),
		rider : new RiderBehaviour(), ogre : new OgreBehaviour(), illusionist : new IllusionistBehaviour(), petrified : new PetrifiedBehaviour(), zombie : new ZombieBehaviour(),
		acrobat : new AcrobatBehaviour(), adling : new AdlingBehaviour(), alchemist : new AlchemistBehaviour(), slime : new SlimeBehaviour(), valravn : new ValravnBehaviour(), skeleton : new SkeletonBehaviour(),
		ghoul : new GhoulBehaviour(), goblin : new GoblinBehaviour(), witch : new WitchBehaviour(), vampire : new VampireBehaviour(),
		mermaid : new MermaidBehaviour(), berserk : new BerserkBehaviour(), healer : new HealerBehaviour(), ghost : new GhostBehaviour(),
		seer : new SeerBehaviour(), cannibal : new CannibalBehaviour(), dryad : new DryadBehaviour(), navigator : new NavigatorBehaviour(), lich : new LichBehaviour()
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
	static get_deck_class = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return undefined}
		return _behaviour.deck_class
	}
	static get_deck_class_max_amount = function(_deck_class) {
		switch string(_deck_class) {
			case "D": return 20;
			case "C": return 15;
			case "B": return 10;
			case "A": return 5;
			case "S": return 1;
		}
		return 0;
	}
	static get_max_deck_class_amount = function(behaviour_type) {
		return get_deck_class_max_amount(get_deck_class(behaviour_type));
	}
	static get_max_deck_amount = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		if (is_undefined(_behaviour)) {return 0}
		return _behaviour.max_deck_amount
	}
	static get_move_effect_id = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		return _behaviour == undefined ? undefined : _behaviour.move_effect_id;
	}
	static get_ability_effect_id = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		return _behaviour == undefined ? undefined : _behaviour.ability_effect_id;
	}
	static is_development_only = function(behaviour_type) {
		var _behaviour = get_behaviour(behaviour_type);
		return _behaviour == undefined || _behaviour.dev;
	}
	static get_deckbuilder_figure_list = function() {
		var _available = [];
		for (var _index = 0; _index < array_length(figure_list); _index++) {
			var _figure = figure_list[_index];
			if !is_development_only(_figure) {
				array_push(_available, _figure);
			}
		}
		return _available;
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
