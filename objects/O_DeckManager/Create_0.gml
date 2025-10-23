decks = [ {deckid: "30391203921", author: "000", owner: "000", name: "123123", units: {"trader": 2, "warrior": 3, "spearman": 7}},
	{deckid: "30391203311", author: "000", owner: "000", name: "23", units: {"trader": 1, "warrior": 4, "spearman": 6}}];
deck_layer = "MenuDeck";
deck_window_default_height = flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, "Window")).height
default_deck = {units: {"trader": 1, "archer": 4, "warrior": 5, "shieldbearer": 5, "spearman": 5}}

selected_deck = undefined;

Default_deck_list_node = { layerElements : [  ], flexWrap : "wrap", gapColumn : 0, gapRow : 0, 
	justifyContent : "center", marginLeft : 0, marginRight : 0, marginTop : 0, marginBottom : 0, 
	nodes : [ { layerElements : [ { textAngle : 0, textColour : -1, textOriginX : 0, type : "Text", 
	textOriginY : 0, textOrigin : 4, textAlignment : 257, textCharacterSpacing : 0, textLineSpacing : 0, 
	textFrameWidth : 352, textFrameHeight : 64, textWrap : 0, textWrapMode : 1, textText : "Test_name", 
	elementId : 75, flexVisible : 1, flexAnchor : "MiddleCentre", flexStretchWidth : 1, 
	flexStretchHeight : 1, flexTileHorizontal : 0, flexTileVertical : 0, flexStretchKeepAspect : 1, 
	elementOrder : 10, textFontIndex : F_menu, textOffsetX : 0, textOffsetY : 0, textScaleX : 1, 
	textScaleY : 1 } ], gapColumn : 0, gapRow : 0, justifyContent : "center", marginLeft : 0, 
	marginRight : 0, marginTop : 0, marginBottom : 0, name : "NameText", clipContent : 0, paddingLeft : 0, 
	paddingRight : 0, paddingTop : 0, width : "95%", paddingBottom : 0, height : "55%", alignItems : "center" }
	,{layerElements : [ /*{ type : "Sprite", elementId : 76, flexVisible : 1, flexAnchor : "MiddleCentre", 
	flexStretchWidth : 1, flexStretchHeight : 1, flexTileHorizontal : 0, spriteIndex : S_ui_circle, 
	flexTileVertical : 0, spriteOffsetX : 0, flexStretchKeepAspect : 0, spriteOffsetY : 0, 
	elementOrder : 20, spriteScaleX : 1, spriteScaleY : 1, spriteColour : -1, spriteImageSpeed : 1, 
	spriteSpeedType : 0, spriteImageIndex : 0, spriteAngle : 0 }*/ ], /*gapColumn : 0, gapRow : 0, 
	justifyContent : "center", marginLeft : 0, marginRight : 0, positionType : "absolute", 
	marginTop : 0, marginBottom : 0, name : "UI_sprite", clipContent : 0, paddingLeft : 0, 
	paddingRight : 0, paddingTop : 0, width : "100%", paddingBottom : 0, height : "100%", 
	alignItems : "center"*/ } ], name : "Deck1", clipContent : 0, paddingLeft : 0, paddingRight : 0, 
	paddingTop : 0, width : 175, paddingBottom : 0, height : 175, alignContent : "center" }

create_deck_button = function() {
	var _struct = { type : "Instance", instanceObjectIndex : O_DeckButton, instanceVariables : {  }, 
	instanceOffsetX : 0, instanceOffsetY : 0, instanceScaleX : 1, instanceScaleY : 1,  instanceImageSpeed : 1, 
	instanceImageIndex : 0, instanceColour : -1, instanceAngle : 0, flexVisible : 1, flexAnchor : "MiddleCentre", flexStretchWidth : 1, flexStretchHeight : 1, 
	flexTileHorizontal : 0, flexTileVertical : 0, flexStretchKeepAspect : 0, elementOrder : 11 }
	return _struct
}

set_decks = function(_decks) {
	//decks = _decks;
	reset_decks_page();
}

get_deck = function(_deck_name) {
	for (i = 0; i < array_length(decks); i++) {
		var _deck = decks[i];
		if _deck.name == _deck_name {
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

selected_deck = default_deck;

add_deck_ui_panel = function(_name, _deck_id = "3"){
	var _struct = Default_deck_list_node;
	_struct.name = _name;
	_struct.nodes[0].layerElements[0].textText = _name;
	array_push(_struct.layerElements, create_deck_button())
	var _panel = flexpanel_create_node(_struct);
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(deck_layer, "DecksList"), _panel, 0);
	flexpanel_node_get_struct(_panel).layerElements[0].instanceId.deck_id = _deck_id
	//show_message(flexpanel_node_get_struct(_panel).layerElements[0].instanceId.deck_id);
}

clear_figure_buttons = function() {
	for (i = 0; i < 20; i++) {
		var _place = UI_controller.get_element_on_ui("MenuDeckSettings", "place" + string(i+1));
		flexpanel_node_get_struct(_place).layerElements[0].instanceId.clear()
	}
}

switch_figure_buttons = function(_figures) {
	clear_figure_buttons();
	for (i = 0; i < array_length(_figures); i++) {
		var _place = UI_controller.get_element_on_ui("MenuDeckSettings", "place" + string(i+1));
		flexpanel_node_get_struct(_place).layerElements[0].instanceId.sprite_index = Behaviours.get_sprite(_figures[i]);
		flexpanel_node_get_struct(_place).layerElements[0].instanceId.figure_inside = _figures[i];
	}
	
}

check_deck_window = function() {
	if array_length(decks) > 6 {
		var _multiplier = ceil((array_length(decks)-6) / 2);
		var _p = UI_controller.get_element_on_ui(deck_layer, "Window");
		var _height = deck_window_default_height + 350*_multiplier;
		flexpanel_node_style_set_height(_p, _height, flexpanel_unit.point);
		UI_controller.switch_menu_page(UI_controller.get_current_page());
	}
}

create_new_deck = function() {
	var _name = "Deck" + string(array_length(decks));
	O_LoginController.create_deck(_name, default_deck.units);
	reset_decks_page();
}

reset_decks_page = function() {
	var _decks_list_node = UI_controller.get_element_on_ui(deck_layer, "DecksList");
	var _to_delete = flexpanel_node_get_struct(_decks_list_node).nodes;
	for (i = 0; i < array_length(_to_delete); i++) {
		var _name = _to_delete[i].name;
		if array_length(_to_delete[i].layerElements) > 0 {
			//var _instance = _to_delete[i].layerElements[0].instanceId;
			instance_destroy(_to_delete[i].layerElements[0].instanceId);
		}
		flexpanel_node_style_set_display(flexpanel_node_get_child(_decks_list_node, _name), flexpanel_display.none)
		flexpanel_delete_node(flexpanel_node_get_child(_decks_list_node, _name), 1);
	}
	flexpanel_node_remove_all_children(_decks_list_node);
	for (i = 0; i < array_length(decks); i++) {
		add_deck_ui_panel(decks[i].name, decks[i].deckid);
	}
	check_deck_window();
}

deck_button_click = function(_deck_id) {
	if get_deck_from_id(_deck_id) != undefined {
		UI_controller.switch_menu_page(menu_pages.DeckSettingsPage);
		switch_figure_buttons(get_deck_figures_array(get_deck_from_id(_deck_id).units));
	}
}


//show_message(flexpanel_node_get_struct(UI_controller.get_element_on_ui("MenuDeck", "Button")))