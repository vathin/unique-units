decks = [ {deckid: "30391203921", author: "000", owner: "000", name: "123123", units: {"trader": 2, "warrior": 3, "spearman": 7}},
	{deckid: "30391203311", author: "000", owner: "000", name: "23", units: {"trader": 1, "warrior": 4, "spearman": 6}}];
deck_layer = "MenuDeckSettings";
cards_panel = "CardPlaces";
figure_buttons_panel = "Cards";
deck_window_default_height = flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, "Window")).height
default_deck = {units: {"trader": 1, "archer": 4, "warrior": 5, "shieldbearer": 5, "spearman": 5}}
available_figures = ["trader", "archer", "warrior", "shieldbearer", "spearman"]

selected_deck = decks[1];

set_decks = function(_decks) {
	//decks = _decks;
	reset_decks_page();
}

get_deck = function(_deck_name) {
	for (i = 0; i < array_length(decks); i++) {
		var _deck = decks[i];
		if _deck.name == "deckelement" + _deck_name {
			return _deck
		}
	}
	return undefined;
}

get_deck_from_id = function(_deck_id) {
	for (i = 0; i < array_length(decks); i++) {
		var _deck = decks[i];
		if _deck.deckid == _deck_id {
			return _deck
		}
	}
	return undefined;
}

get_deck_figures_array = function(_deck_units) {
	var _names = struct_get_names(_deck_units);
	var _array = [];
	for (i = 0; i < array_length(_names); i++) {
		for (m = 0; m < struct_get(_deck_units, _names[i]); m++) {
			array_push(_array, _names[i]);
		}
	}
	if array_length(_array) > 20 {array_resize(_array, 20)}
	return _array
}

get_selected_deck_array = function() {
	return get_deck_figures_array(selected_deck.units)
}


switch_deck = function(_new_deck) {
	reset_decks_page();
	selected_deck = _new_deck;
	var _names = struct_get_names(selected_deck.units);
	for (i = 0; i < array_length(_names); i++) {
		var _figure = _names[i];
		var _amount = struct_get(selected_deck.units, _figure);
		add_card_ui_panel(_figure, _amount);
	}
}
reset_decks_page = function() {
	clear_figure_buttons();
	clear_cards();
	var _decks_list_node = UI_controller.get_element_on_ui(deck_layer, "UpPanel");
	for (i = flexpanel_node_get_num_children(_decks_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_decks_list_node, i);
		flexpanel_delete_node(node, true);
	}
	
	for (i = 0; i < array_length(decks); i++) {
		//add_deck_ui_panel(decks[i].name, decks[i].deckid);
	}
	//check_deck_window();
	create_figure_buttons(available_figures);
}


/*check_deck_window = function() {
	if array_length(decks) > 6 {
		var _multiplier = ceil((array_length(decks)-6) / 2);
		var _p = UI_controller.get_element_on_ui(deck_layer, "Window");
		var _height = deck_window_default_height + 350*_multiplier;
		flexpanel_node_style_set_height(_p, _height, flexpanel_unit.point);
		UI_controller.switch_menu_page(UI_controller.get_current_page());
	}
}*/

create_new_deck = function() {
	var _name = "Deck" + string(array_length(decks));
	O_LoginController.create_deck(_name, default_deck.units);
	reset_decks_page();
}


deck_button_click = function(_deck_id) {
	if get_deck_from_id(_deck_id) != undefined {
		UI_controller.switch_menu_page(menu_pages.DeckSettingsPage);
		switch_figure_buttons(get_deck_figures_array(get_deck_from_id(_deck_id).units));
	}
}

card_click = function(_figure) {
	var _card = card_get_instance(_figure);
	if _card != undefined {
		_card.change_amount();
	}
	else {
		add_card_ui_panel(_figure);
	}
}

card_get_instance = function(_figure) {
	var _node = card_get_node(_figure);
	if _node != undefined {
		return flexpanel_node_get_struct(_node).layerElements[0].instanceId;
	}
	return undefined;
}

card_get_node = function(_figure) {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node);
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.get_figure() == _figure {
			return _node
		}
	}
	return undefined;
}

add_card_ui_panel = function(_figure, _amount = 1) {
	var _struct = deep_copy(default_card_struct);
	//var _struct = Default_card_struct;
	_struct.name = "cardelement" + string(_figure);
	//_struct.nodes[0].layerElements[0].textText = _name;
	array_push(_struct.layerElements, card_instance_create());
	var _panel = flexpanel_create_node(_struct);
	
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(deck_layer, cards_panel), _panel, 0);
	flexpanel_node_get_struct(_panel).layerElements[0].instanceId.set_figure(_figure, _amount);
}

card_instance_create = function() {
	var _struct = { type : "Instance", instanceVariables : {  },
	instanceObjectIndex : O_Deck_figure_place, instanceOffsetX : 0, instanceOffsetY : 0,
	instanceScaleX : 1, instanceScaleY : 1, instanceImageSpeed : 1, instanceImageIndex : 0, instanceColour : -1, 
	instanceAngle : 0, elementId : 43, flexVisible : 1, flexAnchor : "MiddleCentre", flexStretchWidth : 1, 
	flexStretchHeight : 1, flexTileHorizontal : 0, flexTileVertical : 0, flexStretchKeepAspect : 0, 
	elementOrder : 10 }
	return deep_copy(_struct)
}

clear_cards = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_cards_list_node, i);
		flexpanel_delete_node(node, true);
	}
}

get_deck_from_cards = function() {
	figures_struct = {};
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		if array_length(_node.layerElements) > 0 {
			var _figure = _node.layerElements[0].figure_inside;
			var _amount = _node.layerElements[0].amount;
			struct_set(figures_struct, _figure, _amount)
		}
	}
	return figures_struct;
}

create_figure_buttons = function(_figures) {
	for (i = 0; i < array_length(_figures); i++) {
		add_figure_button_ui_panel(_figures[i])
	}
}

add_figure_button_ui_panel = function(_figure) {
	var _struct = deep_copy(default_figure_button_struct);
	_struct.name = "figureButtonElement" + string(_figure);
	array_push(_struct.layerElements, figure_button_instance_create());
	var _panel = flexpanel_create_node(_struct);
	
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel), _panel, 0);
	flexpanel_node_get_struct(_panel).layerElements[0].instanceId.set_figure(_figure);
}

figure_button_instance_create = function() {
	var _struct = { type : "Instance", instanceVariables : {  }, 
		instanceObjectIndex : O_figureSelectionButton, instanceOffsetX : 0, instanceOffsetY : 0, 
		instanceScaleX : 1, instanceScaleY : 1, instanceImageSpeed : 1, instanceImageIndex : 0, 
		instanceColour : -1, instanceAngle : 0, elementId : 44, flexVisible : 1, flexAnchor : "MiddleCentre", 
		flexStretchWidth : 1, flexStretchHeight : 1, flexTileHorizontal : 0, flexTileVertical : 0, 
		flexStretchKeepAspect : 0, elementOrder : 20 }
	return deep_copy(_struct)
}

clear_figure_buttons = function() {
	var _figure_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel);
	for (i = flexpanel_node_get_num_children(_figure_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_figure_buttons_list_node, i);
		flexpanel_delete_node(node, true);
	}
}

default_card_struct = { gapColumn : 0, gapRow : 0, justifyContent : "center", 
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0, clipContent : 0, 
	paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 115, paddingBottom : 0, alignItems : "center", 
	name : "Figure1", height : 125 }
	
default_figure_button_struct = { height : 125, gapColumn : 0, gapRow : 0, justifyContent : "center", 
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0, 
	marginBottom : 0, clipContent : 1, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 155, 
	paddingBottom : 0, alignItems : "center", name : "Card1" }
	
save_deck = function() {
	selected_deck.units = get_deck_from_cards();
}

show_debug_message(flexpanel_node_get_struct(UI_controller.get_element_on_ui("MenuDeckSettings", "Cards")).nodes)