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

get_first_deck_id = function() {
	for (var i = 0; i < array_length(decks); i++) {
		if is_struct(decks[i]) {
			if variable_struct_exists(decks[i], "id") {
				return decks[i].id;
			}
		}
	}
	return undefined;
}

set_decks = function(_decks) {
	var _selected_id = undefined;
	if get_selected_deck() != undefined {
		_selected_id = selected_deck.id;
	}
	if !is_array(_decks) {
		show_debug_message("DeckManager: set_decks received non-array decks");
		_decks = [];
	}
	decks = _decks;
	reset_decks_page();
	if array_length(decks) == 0 {
		selected_deck = {id: undefined};
		set_deck_name_text("");
		create_new_deck();
		return;
	}
	if _selected_id != undefined and get_deck_from_id(_selected_id) != undefined {
		switch_deck(_selected_id);
	}
	else {
		var _first_deck_id = get_first_deck_id();
		if _first_deck_id != undefined {
			switch_deck(_first_deck_id);
		}
		else {
			selected_deck = {id: undefined};
			set_deck_name_text("");
		}
	}
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
		if is_struct(_deck) {
			if variable_struct_exists(_deck, "id") {
				if _deck.id == _deck_id {
					return i
				}
			}
		}
	}
	return undefined;
}

get_deck_figures_array = function(_deck_units) {
	if !is_struct(_deck_units) {
		show_debug_message("DeckManager: deck units is not a struct");
		return [];
	}
	var _names = struct_get_names(_deck_units);
	var _array = [];
	for (var i = 0; i < array_length(_names); i++) {
		var _figure = _names[i];
		if !Behaviours.has(_figure) {
			show_debug_message("DeckManager: skipped unknown figure in deck units: " + string(_figure));
			continue;
		}
		var _amount = struct_get(_deck_units, _figure);
		if (is_undefined(_amount)) {
			show_debug_message("DeckManager: skipped undefined amount for figure: " + string(_figure));
			continue;
		}
		if !is_real(_amount) {
			show_debug_message("DeckManager: skipped invalid amount for figure: " + string(_figure) + ", amount=" + string(_amount));
			continue;
		}
		if _amount <= 0 {
			show_debug_message("DeckManager: skipped invalid amount for figure: " + string(_figure) + ", amount=" + string(_amount));
			continue;
		}
		_amount = clamp(floor(_amount), 1, Behaviours.get_max_deck_amount(_figure));
		for (var m = 0; m < _amount; m++) {
			array_push(_array, _figure);
		}
	}
	if array_length(_array) > 20 {array_resize(_array, 20)}
	return _array
}

get_selected_deck_array = function() {
	if get_selected_deck() == undefined {return []}
	if !variable_struct_exists(selected_deck, "units") {return []}
	return get_deck_figures_array(selected_deck.units)
}

get_selected_deck_names_list = function() {
	if get_selected_deck() == undefined {return []}
	if !variable_struct_exists(selected_deck, "units") {return []}
	if !is_struct(selected_deck.units) {return []}
	return struct_get_names(selected_deck.units)
}

switch_deck = function(_new_deck_id) {
	reset_decks_page();
	var _deck = get_deck_from_id(_new_deck_id);
	if _deck != undefined {
		selected_deck = _deck;
		if !variable_struct_exists(selected_deck, "name") {
			selected_deck.name = "";
		}
		if !variable_struct_exists(selected_deck, "units") {
			show_debug_message("DeckManager: selected deck has invalid units: " + string(_new_deck_id));
			selected_deck.units = {};
		}
		if !is_struct(selected_deck.units) {
			show_debug_message("DeckManager: selected deck has invalid units: " + string(_new_deck_id));
			selected_deck.units = {};
		}
		var _names = struct_get_names(selected_deck.units);
		for (var i = 0; i < array_length(_names); i++) {
			var _figure = _names[i];
			if !Behaviours.has(_figure) {
				show_debug_message("DeckManager: switch_deck skipped unknown figure: " + string(_figure));
				continue;
			}
			var _amount = struct_get(selected_deck.units, _figure);
			if !is_real(_amount) {
				show_debug_message("DeckManager: switch_deck skipped invalid amount for figure: " + string(_figure) + ", amount=" + string(_amount));
				continue;
			}
			if _amount <= 0 {
				show_debug_message("DeckManager: switch_deck skipped invalid amount for figure: " + string(_figure) + ", amount=" + string(_amount));
				continue;
			}
			card_add(_figure, _amount);
		}
	}
	else {
		show_debug_message("DeckManager: switch_deck failed, unknown deck id: " + string(_new_deck_id));
		selected_deck = {id: undefined};
	}
	if get_selected_deck() != undefined {
		set_deck_name_text(selected_deck.name);
	}
	else {
		set_deck_name_text("");
	}
}

set_deck_name_text = function(_name) {
	var _node = UI_controller.get_element_on_ui(deck_layer, deck_name_panel);
	if _node == undefined {return;}
	var _struct = flexpanel_node_get_struct(_node);
	if array_length(_struct.layerElements) > 0 {
		var _field = _struct.layerElements[0].instanceId;
		if variable_instance_exists(_field, "set_text") {
			_field.set_text(string(_name));
		}
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
	var _create_button = UI_controller.get_element_on_ui(deck_layer, deck_create_button);
	if _create_button != undefined {
		flexpanel_node_style_set_display(_create_button, _display);
	}
}

update_create_button_position = function() {
	var _create_button = UI_controller.get_element_on_ui(deck_layer, deck_create_button);
	var _deck_list =  UI_controller.get_element_on_ui(deck_layer, decks_panel);
	if _create_button == undefined or _deck_list == undefined {return;}
	flexpanel_node_remove_child(_deck_list, _create_button);
	flexpanel_node_insert_child(_deck_list, _create_button, array_length(decks))
}

create_new_deck = function() {
	if array_length(decks) < deck_limit {
		var _name = "Deck" + string(array_length(decks)+1);
		server_create_deck(_name, default_deck.units);
	}
	else {
		show_debug_message("DeckManager: create_new_deck skipped, deck limit reached");
	}
}

update_deck = function() {
	if get_selected_deck() != undefined {
		selected_deck.units = get_deck_from_cards();
		selected_deck.name = get_name_from_textfield();
		server_update_deck(selected_deck.id, selected_deck.name, selected_deck.units);
	}
	else {
		show_debug_message("DeckManager: update_deck skipped, no selected deck");
	}
}

get_name_from_textfield = function() {
	var _node = UI_controller.get_element_on_ui(deck_layer, deck_name_panel);
	if _node == undefined {return ""}
	var _struct = flexpanel_node_get_struct(_node);
	if array_length(_struct.layerElements) > 0 {
		var _field = _struct.layerElements[0].instanceId;
		if variable_instance_exists(_field, "get_text") {
			return _field.get_text();
		}
	}
	return "";
}

delete_deck = function(_deck_id) {
	if get_selected_deck() != undefined {
		var _to_delete = get_deck_index(_deck_id);
		if _to_delete != undefined {
			array_delete(decks, _to_delete, 1);
			server_delete_deck(_deck_id);
		}
		else {
			show_debug_message("DeckManager: delete_deck skipped, unknown deck id: " + string(_deck_id));
			return false;
		}
		selected_deck = {id: undefined}
		reset_decks_page();
		var _first_deck_id = get_first_deck_id();
		if _first_deck_id != undefined {
			switch_deck(_first_deck_id);
		}
		else {
			set_deck_name_text("");
		}
	}
	else {
		show_debug_message("DeckManager: delete_deck skipped, no selected deck");
	}
}

deck_button_click = function(_deck_id) {
	var _deck = get_deck_from_id(_deck_id);
	if _deck != undefined {
		UI_controller.switch_menu_page(menu_pages.DeckSettingsPage);
		switch_deck(_deck_id);
	}
}

card_add = function(_figure, _amount) {
	if !Behaviours.has(_figure) {
		show_debug_message("DeckManager: card_add skipped unknown figure: " + string(_figure));
		return false;
	}
	if !is_real(_amount) {
		show_debug_message("DeckManager: card_add fixed invalid amount for figure: " + string(_figure) + ", amount=" + string(_amount));
		_amount = 1;
	}
	_amount = clamp(floor(_amount), 1, Behaviours.get_max_deck_amount(_figure));
	var _node = find_first_available_card();
	if _node == undefined {
		show_debug_message("DeckManager: card_add failed, no free card slot for: " + string(_figure));
		return false;
	}
	flexpanel_node_get_struct(_node).layerElements[0].instanceId.set_figure(_figure, _amount);
	flexpanel_node_style_set_display(_node, 0);
	return true;
}

card_click = function(_figure) {
	if !Behaviours.has(_figure) {
		show_debug_message("DeckManager: card_click skipped unknown figure: " + string(_figure));
		return false;
	}
	var _card = card_get_instance(_figure);
	if array_length(get_deck_figures_array(get_deck_from_cards())) < max_figures_in_deck
	and get_selected_deck() != undefined {
		if _card != undefined {
			_card.change_amount();
		}
		else {
			var _node = find_first_available_card();
			if _node == undefined {
				show_debug_message("DeckManager: card_click failed, no free card slot for: " + string(_figure));
				return false;
			}
			flexpanel_node_get_struct(_node).layerElements[0].instanceId.set_figure(_figure);
			flexpanel_node_style_set_display(_node, 0);
		}
	}
	else {
		return false
	}
	return true
}

find_first_available_card = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	if _cards_list_node == undefined {return undefined}
	for (var i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(node);
		if array_length(_struct.layerElements) <= 0 {continue;}
		var _instance = _struct.layerElements[0].instanceId
		if _instance.figure_inside == undefined {
			return node
			}
	}
	return undefined;
}

card_delete_click = function(_figure) {
	if !Behaviours.has(_figure) {
		show_debug_message("DeckManager: card_delete_click skipped unknown figure: " + string(_figure));
		return false;
	}
	var _card = card_get_instance(_figure);
	if _card != undefined and get_selected_deck() != undefined {
		_card.change_amount(-1);
		if _card.get_amount() <= 0 {
			var _node = card_get_node_with_0(_figure);
			if _node != undefined {
				flexpanel_node_style_set_display(_node, 1);
			}
			_card.clear();
		}
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
	if _cards_list_node == undefined {return undefined}
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
	if _cards_list_node == undefined {return undefined}
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
	if _cards_list_node == undefined {return;}
	for (var i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(node);
		if array_length(_struct.layerElements) > 0 {
			flexpanel_node_get_struct(node).layerElements[0].instanceId.clear();
		}
		flexpanel_node_style_set_display(node, 1);
	}
}

get_deck_from_cards = function() {
	var _cards_list_node = UI_controller.get_element_on_ui(deck_layer, cards_panel);
	var figures_struct = {};
	if _cards_list_node == undefined {return figures_struct;}
	for (var i = flexpanel_node_get_num_children(_cards_list_node) - 1; i >= 0; i--) {
		var _node = flexpanel_node_get_child(_cards_list_node, i);
		var _struct = flexpanel_node_get_struct(_node)
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.figure_inside != undefined {
			var _figure = _struct.layerElements[0].instanceId.figure_inside;
			var _amount = _struct.layerElements[0].instanceId.figure_amount;
			if Behaviours.has(_figure) {
				if is_real(_amount) {
					if _amount > 0 {
						struct_set(figures_struct, _figure, floor(_amount))
					}
				}
			}
		}
	}
	return figures_struct;
}

create_figure_buttons = function(_figures) {
	var _figure_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel);
	if _figure_buttons_list_node == undefined {return;}
	var m = min(array_length(_figures), flexpanel_node_get_num_children(_figure_buttons_list_node))
	for (var i = 0; i < m; i++) {
		if !Behaviours.has(_figures[i]) {continue;}
		var node = flexpanel_node_get_child(_figure_buttons_list_node, i);
		var _struct = flexpanel_node_get_struct(node);
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.get_figure() == undefined {
			flexpanel_node_style_set_display(node, 0);
			_struct.layerElements[0].instanceId.set_figure(_figures[i]);
		}
	}
}


clear_figure_buttons = function() {
	var _figure_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, figure_buttons_panel);
	if _figure_buttons_list_node == undefined {return;}
	for (var i = flexpanel_node_get_num_children(_figure_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_figure_buttons_list_node, i);
		var _struct = flexpanel_node_get_struct(node);
		if array_length(_struct.layerElements) > 0 {
			_struct.layerElements[0].instanceId.clear();
		}
		flexpanel_node_style_set_display(node, 1);
	}
}

create_deck_buttons = function() {
	for (var i = 0; i < array_length(decks); i++) {
		if is_struct(decks[i]) {
			if variable_struct_exists(decks[i], "id") {
				add_deck_button(decks[i].id);
			}
			else {
				show_debug_message("DeckManager: skipped invalid deck entry at index " + string(i));
			}
		}
		else {
			show_debug_message("DeckManager: skipped invalid deck entry at index " + string(i));
		}
	}
}

add_deck_button = function(_deck_id) {
	var _deck = get_deck_from_id(_deck_id);
	if _deck == undefined {return false;}
	var _name = _deck.name;
	var _node = find_first_available_deck_button();
	if _node != undefined {
		var _struct = flexpanel_node_get_struct(_node);
		if array_length(_struct.layerElements) > 0 {
			flexpanel_node_style_set_display(_node, 0);
			_struct.layerElements[0].instanceId.set_deck(_deck_id, _name);
			return true;
		}
	}
	show_debug_message("DeckManager: add_deck_button failed, no free deck slot for: " + string(_deck_id));
	return false;
}

find_first_available_deck_button = function() {
	var _deck_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, decks_panel);
	if _deck_buttons_list_node == undefined {return undefined;}
	for (var i = 0; i < flexpanel_node_get_num_children(_deck_buttons_list_node); i++) {
		var node = flexpanel_node_get_child(_deck_buttons_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" {
			var _struct = flexpanel_node_get_struct(node);
			if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.is_available() {
				return node;
			}
		}  
	}
	return undefined;
}

clear_deck_buttons = function() {
	var _deck_buttons_list_node = UI_controller.get_element_on_ui(deck_layer, decks_panel);
	if _deck_buttons_list_node == undefined {return;}
	for (var i = flexpanel_node_get_num_children(_deck_buttons_list_node) - 1; i >= 0; i--) {
		var node = flexpanel_node_get_child(_deck_buttons_list_node, i);
		if flexpanel_node_get_struct(node).name != "CreateButton" {
			var _struct = flexpanel_node_get_struct(node);
			if array_length(_struct.layerElements) > 0 {
				_struct.layerElements[0].instanceId.clear();
			}
			flexpanel_node_style_set_display(node, 1);
		}
	}
}

create_card_displays = function(_player_id, _position) {
	var _data = Game.user_data.load(_player_id);
	if !is_struct(_data) {return;}
	if !variable_struct_exists(_data, "player_cards") {return;}
	if !is_array(_data.player_cards) {return;}
	var _figures = _data.player_cards;
	for (var i = 0; i < array_length(_figures); i++) {
		if !Behaviours.has(_figures[i]) {continue;}
		var _index = find_card_insert_index(Behaviours.get_rarity(_figures[i]), _position);
		add_card_display(_figures[i], _position, _index);
	}
}

add_card_display = function(_figure, _position, _index) {
	if !Behaviours.has(_figure) {return false;}
	var _node = find_first_available_card_display(_position);
	if _node != undefined {
		var _struct = flexpanel_node_get_struct(_node);
		var _parent = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[_position]);
		if _parent == undefined {return false;}
		if array_length(_struct.layerElements) <= 0 {return false;}
		flexpanel_node_style_set_display(_node, 0);
		flexpanel_node_remove_child(_parent, _node)
		_struct.layerElements[0].instanceId.set_figure(_figure);
		flexpanel_node_insert_child(_parent, _node, _index);
		return true;
	}
	return false;
}

find_card_insert_index = function(_rarity, _position) {
	var _parent = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[_position]);
	if _parent == undefined {return 0;}
	var _length = flexpanel_node_get_num_children(_parent);
	for (var i = 0; i < _length; i++) {
		var _struct = flexpanel_node_get_struct(flexpanel_node_get_child(_parent, i));
		if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.rarity <= _rarity {
			return i
			}
	}
	return 0
}

find_first_available_card_display = function(_position) {
	var _card_displays_list_node = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[_position]);
	if _card_displays_list_node == undefined {return undefined;}
	for (var i = 0; i < flexpanel_node_get_num_children(_card_displays_list_node); i++) {
		var node = flexpanel_node_get_child(_card_displays_list_node, i);
		if flexpanel_node_get_name(node) != "CreateButton" {
			var _struct = flexpanel_node_get_struct(node);
			if array_length(_struct.layerElements) > 0 and _struct.layerElements[0].instanceId.is_available() {
				return node;
			}
		}  
	}
	return undefined;
}

clear_card_displays = function() {
	var _card_display_list_node = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[0]);
	if _card_display_list_node != undefined {
		for (var i = flexpanel_node_get_num_children(_card_display_list_node) - 1; i >= 0; i--) {
			var node = flexpanel_node_get_child(_card_display_list_node, i);
			var _struct = flexpanel_node_get_struct(node);
			if array_length(_struct.layerElements) > 0 {
				_struct.layerElements[0].instanceId.clear();
			}
			flexpanel_node_style_set_display(node, 1);
		}
	}
	_card_display_list_node = UI_controller.get_element_on_ui(ingame_layer, card_display_panel[1]);
	if _card_display_list_node != undefined {
		for (var i = flexpanel_node_get_num_children(_card_display_list_node) - 1; i >= 0; i--) {
			var node = flexpanel_node_get_child(_card_display_list_node, i);
			var _struct = flexpanel_node_get_struct(node);
			if array_length(_struct.layerElements) > 0 {
				_struct.layerElements[0].instanceId.clear();
			}
			flexpanel_node_style_set_display(node, 1);
		}
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
	marginBottom : 0, clipContent : 0, paddingLeft : 0, paddingRight : 0, paddingTop : 0, width : 138,
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
		} catch(e) {
			show_debug_message("DeckManager: failed to handle Decks message: " + string(e));
		}
		//if array_length(msg.data.decks) != 0 {switch_deck(decks[0].id)}
	}
})
#endregion
//show_message(flexpanel_node_style_get_border(UI_controller.get_element_on_ui("MenuDeckSettings", "ButtonInstances"), flexpanel_edge.top))
