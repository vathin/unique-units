// ЛКМ - Добавить фигуру в колоду
// ПКМ - Удалить фигуру из колоды


decks = [];
deck_layer = "MenuDeckSettings";
decks_panel = "DeckList";
cards_panel = "CardInstances";
figure_buttons_panel = "ButtonInstances";
deck_create_button = "CreateButton";
deck_name_panel = "DeckNameField";
default_deck = {id: "000", name: "", owner: "",units: {"trader": 1, "archer": 1, "warrior": 1, "shieldbearer": 1, "spearman": 1}}
available_figures = ["trader", "archer", "warrior", "shieldbearer", "spearman"]
max_figures_in_deck = 20;
deck_limit = 5;

selected_deck = {id: undefined};

get_selected_deck = function() {
	if selected_deck.id == undefined {return undefined}
	return selected_deck
}

set_decks = function(_decks) {
	var _index = undefined;
	if get_selected_deck() != undefined {
		_index = get_deck_index(selected_deck.id);
	}
	decks = _decks;
	if array_length(decks) == 0 {create_new_deck()}
	if _index != undefined and array_length(decks) > _index {switch_deck(decks[_index].id)}
	else {reset_decks_page();}
}

get_deck_from_id = function(_deck_id) {
	var _index = get_deck_index(_deck_id);
	if _index != undefined {
		return decks[_index];
	}
	return undefined;
}

get_deck_index = function(_deck_id) {
	for (i = 0; i < array_length(decks); i++) {
		var _deck = decks[i];
		if _deck.id == _deck_id {
			return i
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

get_selected_deck_names_list = function() {
	return struct_get_names(selected_deck.units)
}

switch_deck = function(_new_deck_id) {
	reset_decks_page();
	if get_deck_from_id(_new_deck_id) != undefined {
		selected_deck = get_deck_from_id(_new_deck_id);
		var _names = struct_get_names(selected_deck.units);
		for (i = 0; i < array_length(_names); i++) {
			var _figure = _names[i];
			var _amount = struct_get(selected_deck.units, _figure);
			add_card_ui_panel(_figure, _amount);
		}
	}
	if get_selected_deck != undefined {
		flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, deck_name_panel)).layerElements[0].instanceId.set_text(selected_deck.name);
	}
}
reset_decks_page = function() {
	clear_figure_buttons();
	clear_cards();
	clear_deck_buttons();
	create_figure_buttons(available_figures);
	create_deck_buttons();
	var _display = flexpanel_display.none;
	if array_length(decks) < deck_limit { _display = flexpanel_display.flex; }
	flexpanel_node_style_set_display(UI_controller.get_element_on_ui(deck_layer, deck_create_button), _display);
}

create_new_deck = function() {
	if array_length(decks) < deck_limit {
		var _name = "Deck" + string(array_length(decks)+1);
		server_create_deck(_name, default_deck.units);
	}
}

update_deck = function() {
	if get_selected_deck() != undefined {
		selected_deck.units = get_deck_from_cards();
		selected_deck.name = get_name_from_textfield();
		server_update_deck(selected_deck.id, selected_deck.name, selected_deck.units);
	}
}

get_name_from_textfield = function() {
	return flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, deck_name_panel)).
	layerElements[0].instanceId.get_text();
}

delete_deck = function(_deck_id) {
	if get_selected_deck() != undefined {
		var _to_delete = get_deck_index(_deck_id);
		if _to_delete != undefined {
			array_delete(decks, i, 1);
			server_delete_deck(_deck_id);
		}
		selected_deck = {id: undefined}
		reset_decks_page();
	}
}

deck_button_click = function(_deck_id) {
	if get_deck_from_id(_deck_id) != undefined {
		UI_controller.switch_menu_page(menu_pages.DeckSettingsPage);
		switch_figure_buttons(get_deck_figures_array(get_deck_from_id(_deck_id).units));
	}
}

card_click = function(_figure) {
	var _card = card_get_instance(_figure);
	if array_length(get_deck_figures_array(get_deck_from_cards())) < max_figures_in_deck
	and get_selected_deck() != undefined{
		if _card != undefined {
			_card.change_amount();
		}
		else {
			add_card_ui_panel(_figure);
		}
	}
}

card_delete_click = function(_figure) {
	var _card = card_get_instance(_figure);
	if _card != undefined and get_selected_deck() != undefined{
		_card.change_amount(-1);
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
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	figures_struct = {};
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node)
		if array_length(_struct.layerElements) > 0 {
			var _figure = _struct.layerElements[0].instanceId.figure_inside;
			var _amount = _struct.layerElements[0].instanceId.figure_amount;
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

create_deck_buttons = function() {
	for (i = 0; i < array_length(decks); i++) {
		add_deck_button_ui_panel(decks[i].id)
	}
}

add_deck_button_ui_panel = function(_deck_id) {
	var _struct = deep_copy(default_deck_button_struct);
	var _name = get_deck_from_id(_deck_id).name;
	_struct.name = "deckButtonElement" + _name;
	array_push(_struct.layerElements, deck_button_instance_create());
	var _panel = flexpanel_create_node(_struct);
	
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(deck_layer, decks_panel), _panel, 0);
	flexpanel_node_get_struct(_panel).layerElements[0].instanceId.set_deck(_deck_id, _name);
}

deck_button_instance_create = function() {
	var _struct = { type : "Instance", instanceVariables : {  }, 
	instanceObjectIndex : O_DeckButton, instanceOffsetX : 0, instanceOffsetY : 0, instanceScaleX : 1, 
	instanceScaleY : 1, instanceImageSpeed : 1, instanceImageIndex : 0, instanceColour : -1, instanceAngle : 0, flexVisible : 1, flexAnchor : "MiddleCentre", flexStretchWidth : 1, flexStretchHeight : 1, 
	flexTileHorizontal : 0, flexTileVertical : 0, flexStretchKeepAspect : 0, elementOrder : 50 }
	return deep_copy(_struct)
}

clear_deck_buttons = function() {
	var _deck_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, decks_panel);
	for (i = flexpanel_node_get_num_children(_deck_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_deck_buttons_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" { flexpanel_delete_node(node, true); }
	}
}

default_deck_button_struct = { layerElements : [ ], height : "95%", gapColumn : 0,
	gapRow : 0, justifyContent : "center", marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0, 
	name : "Deckel1", clipContent : 0, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 94, 
	paddingBottom : 0, alignItems : "center" } 

default_card_struct = { gapColumn : 0, gapRow : 0, justifyContent : "center", 
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0, clipContent : 0, 
	paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 115, paddingBottom : 0, alignItems : "center", 
	name : "Figure1", height : 125 }
	
default_figure_button_struct = { height : 125, gapColumn : 0, gapRow : 0, justifyContent : "center", 
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0, 
	marginBottom : 0, clipContent : 1, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 155, 
	paddingBottom : 0, alignItems : "center", name : "Card1" }

#region server
server_create_deck = function(_name, _deck) {
	Server.send(new ServerMessage(ServerMessageType.DeckCreate, {name: _name, units: _deck}));
}

server_update_deck = function(_deck_id, _name, _new_deck) {
	Server.send(new ServerMessage(ServerMessageType.DeckUpdate, {deckid: _deck_id, name: _name, units: _new_deck}))
}

server_delete_deck = function(_deck_id) {
	Server.send(new ServerMessage(ServerMessageType.DeckRemove, {deckid: _deck_id}))
}

Server.add_reaction(function(msg)
{
	if (msg.type == ServerMessageType.Decks) {
		O_DeckManager.set_decks(msg.data.decks);
		if array_length(msg.data.decks) != 0 {O_DeckManager.selected_deck = O_DeckManager.decks[0]}
	}
})
#endregion
//show_message(flexpanel_node_style_get_border(UI_controller.get_element_on_ui("MenuDeckSettings", "ButtonInstances"), flexpanel_edge.top))
