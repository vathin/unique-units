// ЛКМ - Добавить фигуру в колоду
// ПКМ - Удалить фигуру из колоды

decks = [];
deck_layer = "MenuDeckSettings";
ingame_layer = UI_controller.InGame_layer;
decks_panel = "DeckList";
cards_panel = "CardInstances";
figure_buttons_panel = "ButtonInstances";
deck_create_button = "CreateButton";
deck_name_panel = "DeckNameField";
card_display_panel = ["CardsDisplay_1", "CardsDisplay_2"];
default_deck = {id: "000", name: "", owner: "",units: {"trader": 1, "archer": 1, "warrior": 1, "shieldbearer": 1, "spearman": 1}}
available_figures = ["trader", "archer", "warrior", "shieldbearer", "spearman"];
max_figures_in_deck = 20;
deck_limit = 5;
next_dynamic_element_id = 1000;

selected_deck = {id: undefined};

allocate_dynamic_element_id = function() {
	var _id = next_dynamic_element_id;
	next_dynamic_element_id++;
	return _id;
}

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
	reset_decks_page();
	if array_length(decks) == 0 {create_new_deck()}
	if _index != undefined and array_length(decks) > _index {switch_deck(decks[_index].id)}
	else {switch_deck(decks[0].id)}
}

get_deck_from_id = function(_deck_id) {
	var _index = get_deck_index(_deck_id);
	if _index != undefined {
		return decks[_index];
	}
	return undefined;
}

get_deck_index = function(_deck_id) {
	for (var i = 0; i < array_length(decks); i++) {
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
	for (var i = 0; i < array_length(_names); i++) {
		for (var m = 0; m < struct_get(_deck_units, _names[i]); m++) {
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
		for (var i = 0; i < array_length(_names); i++) {
			var _figure = _names[i];
			var _amount = struct_get(selected_deck.units, _figure);
			card_add(_figure, _amount);
		}
	}
	if get_selected_deck() != undefined {
		flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, deck_name_panel)).layerElements[0].instanceId.set_text(selected_deck.name);
	}
}

reset_decks_page = function() {
	clear_figure_buttons();
	clear_cards();
	clear_deck_buttons();
	create_figure_buttons(available_figures);
	create_deck_buttons();
	update_create_button_position();
	var _display = flexpanel_display.none;
	if array_length(decks) < deck_limit { _display = flexpanel_display.flex; }
	flexpanel_node_style_set_display(UI_controller.get_element_on_ui(deck_layer, deck_create_button), _display);
}

update_create_button_position = function() {
	var _create_button = UI_controller.get_element_on_ui(deck_layer, deck_create_button);
	var _deck_list =  UI_controller.get_element_on_ui(deck_layer, decks_panel);
	flexpanel_node_remove_child(_deck_list, _create_button);
	flexpanel_node_insert_child(_deck_list, _create_button, array_length(decks))
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
	if get_deck_from_id(_deck_id) != "-1" {
		UI_controller.switch_menu_page(menu_pages.DeckSettingsPage);
		switch_figure_buttons(get_deck_figures_array(get_deck_from_id(_deck_id).units));
	}
}

card_add = function(_figure, _amount) {
	var _node = find_first_available_card();
	flexpanel_node_get_struct(_node).layerElements[0].instanceId.set_figure(_figure, _amount);
	flexpanel_node_style_set_display(_node, 0);
}

card_click = function(_figure) {
	var _card = card_get_instance(_figure);
	if array_length(get_deck_figures_array(get_deck_from_cards())) <= max_figures_in_deck
	and get_selected_deck() != undefined {
		if _card != undefined {
			_card.change_amount();
		}
		else {
			var _node = find_first_available_card();
			flexpanel_node_get_struct(_node).layerElements[0].instanceId.set_figure(_figure);
			flexpanel_node_style_set_display(_node, 0);
		}
	}
}

find_first_available_card = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_cards_list_node, i);
		var _instance = flexpanel_node_get_struct(node).layerElements[0].instanceId
		if _instance.figure_inside == undefined {
			return node
			}
	}
}

card_delete_click = function(_figure) {
	var _card = card_get_instance(_figure);
	if _card != undefined and get_selected_deck() != undefined{
		_card.change_amount(-1);
	}
	if _card.get_amount() <= 0 {
		flexpanel_node_style_set_display(card_get_node_with_0(_figure), 1);
		_card.clear();
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
	for (var i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node);
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.get_figure() == _figure 
		and _struct.layerElements[0].instanceId.figure_amount > 0 {
			return _node
		}
	}
	return undefined;
}

card_get_node_with_0 = function(_figure) {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	for (var i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node);
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.get_figure() == _figure {
			return _node
		}
	}
	return undefined;
}

clear_cards = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_cards_list_node, i);
		flexpanel_node_get_struct(node).layerElements[0].instanceId.clear();
		flexpanel_node_style_set_display(node, 1);
	}
}

get_deck_from_cards = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	figures_struct = {};
	for (i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node)
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.figure_inside != undefined {
			var _figure = _struct.layerElements[0].instanceId.figure_inside;
			var _amount = _struct.layerElements[0].instanceId.figure_amount;
			struct_set(figures_struct, _figure, _amount)
		}
	}
	return figures_struct;
}

create_figure_buttons = function(_figures) {
	var _figure_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel);
	var m = min(array_length(_figures), flexpanel_node_get_num_children(_figure_buttons_list_node))
	for (var i = 0; i < m; i++) {
		var node = flexpanel_node_get_child(_figure_buttons_list_node, i);
		if flexpanel_node_get_struct(node).layerElements[0].instanceId.get_figure() == undefined {
			flexpanel_node_style_set_display(node, 0);
			flexpanel_node_get_struct(node).layerElements[0].instanceId.set_figure(_figures[i]);
		}
	}
}


clear_figure_buttons = function() {
	var _figure_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel);
	for (var i = flexpanel_node_get_num_children(_figure_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_figure_buttons_list_node, i);
		var _struct = flexpanel_node_get_struct(node);
		_struct.layerElements[0].instanceId.clear();
		flexpanel_node_style_set_display(node, 1);
	}
}

create_deck_buttons = function() {
	for (var i = 0; i < array_length(decks); i++) {
		add_deck_button(decks[i].id);
	}
}

add_deck_button = function(_deck_id) {
	var _name = get_deck_from_id(_deck_id).name;
	var _node = find_first_available_deck_button();
	if _node != undefined {
		var _struct = flexpanel_node_get_struct(_node);
		flexpanel_node_style_set_display(_node, 0);
		_struct.layerElements[0].instanceId.set_deck(_deck_id, _name);
	}
}

find_first_available_deck_button = function() {
	var _deck_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, decks_panel);
	for (i = 0; i < flexpanel_node_get_num_children(_deck_buttons_list_node); i++) {
		var node = flexpanel_node_get_child(_deck_buttons_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" {
			if flexpanel_node_get_struct(node).layerElements[0].instanceId.is_available() {
				return node;
			}
		}  
	}
	return undefined;
}

clear_deck_buttons = function() {
	var _deck_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, decks_panel);
	for (i = flexpanel_node_get_num_children(_deck_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_deck_buttons_list_node, i);
		if flexpanel_node_get_struct(node).name != "CreateButton" {
			flexpanel_node_get_struct(node).layerElements[0].instanceId.clear();
			flexpanel_node_style_set_display(node, 1);
		}
	}
}

create_card_displays = function(_player_id, _position) {
	_figures = Game.user_data.load(_player_id).player_cards;
	for (var i = 0; i < array_length(_figures); i++) {
		var _index = find_card_insert_index(Behaviours.get_rarity(_figures[i]), _position);
		add_card_display_ui_panel(_figures[i], _position, _index);
	}
}

find_card_insert_index = function(_rarity, _position) {
	var _length = flexpanel_node_get_num_children(UI_controller.get_element_on_ui(ingame_layer, 
	card_display_panel[_position]));
	for (var i = 0; i < _length; i++) {
		if flexpanel_node_get_struct(flexpanel_node_get_child(UI_controller.get_element_on_ui(ingame_layer, 
		card_display_panel[_position]), i)).layerElements[0].instanceId.rarity <= _rarity {
			return i
			}
	}
	return 0
}

add_card_display_ui_panel = function(_figure, _position, _index = 0) {
	var _struct = deep_copy(default_card_display_struct);
	var _name = _figure + string(flexpanel_node_get_num_children(UI_controller.get_element_on_ui(ingame_layer, 
	card_display_panel[_position])));
	_struct.name = "cardDisplay" + _name;
	array_push(_struct.layerElements, card_display_instance_create(_figure));
	var _panel = flexpanel_create_node(_struct);
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(ingame_layer, card_display_panel[_position]), _panel, _index);
}

card_display_instance_create = function(_figure) {
	var _struct = { type : "Instance", instanceVariables : {
		figure_to_display : _figure,
		layout_width : default_card_display_struct.width
	}, instanceObjectIndex : O_Card_display,
	instanceOffsetX : 0, instanceOffsetY : 0, instanceScaleX : 1, instanceScaleY : 1, instanceImageSpeed : 1, 
	instanceImageIndex : 0, instanceColour : -1, instanceAngle : 0, elementId : allocate_dynamic_element_id(), flexVisible : 1,
	flexAnchor : "MiddleCentre", flexStretchWidth : 1, flexStretchHeight : 1, flexTileHorizontal : 0,
	flexTileVertical : 0, flexStretchKeepAspect : 0, elementOrder : 30 }
	return deep_copy(_struct)
}

clear_card_displays = function() {
	var _card_display_list_node = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[0]);
	for (i = flexpanel_node_get_num_children(_card_display_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_card_display_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" { flexpanel_delete_node(node, true); }
	}
	_card_display_list_node = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[1]);
	for (i = flexpanel_node_get_num_children(_card_display_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_card_display_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" { flexpanel_delete_node(node, true); }
	}
}

default_deck_button_struct = { layerElements : [ ], flexDirection : 0, height : 90, gapColumn : 0,
	gapRow : 0, justifyContent : "center", marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0,
	name : "Deckel1", clipContent : 0, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 88,
	paddingBottom : 0, alignItems : "center" }

default_card_struct = { gapColumn : 0, gapRow : 0, justifyContent : "center", flexDirection : 0,
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0, clipContent : 0,
	paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 110, paddingBottom : 0, alignItems : "center",
	name : "Figure1", height : 125 }

default_figure_button_struct = { height : 125, gapColumn : 0, gapRow : 0, justifyContent : "center", flexDirection : 0,
	layerElements : [ ], marginLeft : 0, marginRight : 0, marginTop : 0,
	marginBottom : 0, clipContent : 1, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 138,
	paddingBottom : 0, alignItems : "center", name : "Card1" }

default_card_display_struct = {height : "100%", gapColumn : 0, gapRow : 0, justifyContent : "center", flexDirection : 0,
	layerElements: [], marginLeft : 0, marginRight : 0,
	marginTop : 0, marginBottom : 0, clipContent : 0, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 64,
	name : "CardDisplay", paddingBottom : 0, alignItems : "center"}

//reset_decks_page();

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
		try {
			set_decks(msg.data.decks);
			reset_decks_page();
		} catch(e) {}
		//if array_length(msg.data.decks) != 0 {switch_deck(decks[0].id)}
	}
})
#endregion
//show_message(flexpanel_node_style_get_border(UI_controller.get_element_on_ui("MenuDeckSettings", "ButtonInstances"), flexpanel_edge.top))
