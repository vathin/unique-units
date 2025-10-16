decks = [];
deck_layer = "MenuDeck";
deck_window_default_height = flexpanel_node_get_struct(UI_controller.get_element_on_ui(deck_layer, "Window")).height

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
	,{layerElements : [ { type : "Sprite", elementId : 76, flexVisible : 1, flexAnchor : "MiddleCentre", 
	flexStretchWidth : 1, flexStretchHeight : 1, flexTileHorizontal : 0, spriteIndex : S_ui_circle, 
	flexTileVertical : 0, spriteOffsetX : 0, flexStretchKeepAspect : 0, spriteOffsetY : 0, 
	elementOrder : 20, spriteScaleX : 1, spriteScaleY : 1, spriteColour : -1, spriteImageSpeed : 1, 
	spriteSpeedType : 0, spriteImageIndex : 0, spriteAngle : 0 } ], gapColumn : 0, gapRow : 0, 
	justifyContent : "center", marginLeft : 0, marginRight : 0, positionType : "absolute", 
	marginTop : 0, marginBottom : 0, name : "UI_sprite", clipContent : 0, paddingLeft : 0, 
	paddingRight : 0, paddingTop : 0, width : "100%", paddingBottom : 0, height : "100%", 
	alignItems : "center" } ], name : "Deck1", clipContent : 0, paddingLeft : 0, paddingRight : 0, 
	paddingTop : 0, width : 175, paddingBottom : 0, height : 175, alignContent : "center" }

default_deck = {"trader": 1, "archer": 4, "warrior": 5, "shieldbearer": 5, "spearman": 5}

add_deck_ui_panel = function(_name){
	var _struct = Default_deck_list_node;
	_struct.name = _name;
	_struct.nodes[0].layerElements[0].textText = _name;
	var _panel = flexpanel_create_node(_struct);
	flexpanel_node_insert_child(UI_controller.get_element_on_ui(deck_layer, "DecksList"), _panel, 0);
}

check_deck_window = function() {
	if array_length(decks) > 6 {
		var _multiplier = ceil((array_length(decks)-6) / 2);
		var _p = UI_controller.get_element_on_ui(deck_layer, "Window");
		var _height = deck_window_default_height + 250*_multiplier;
		
		flexpanel_node_style_set_height(_p, _height, flexpanel_unit.point);
		//flexpanel_node_style_set_position(_p, flexpanel_edge.top, 10*_multiplier, flexpanel_unit.percent)
		UI_controller.switch_menu_page(UI_controller.get_current_page());
	}
}

create_new_deck = function() {
	var _name = "Deck" + string(array_length(decks));
	O_LoginController.create_deck(_name, default_deck);
	reset_decks_page();
}

reset_decks_page = function() {
	flexpanel_node_remove_all_children(UI_controller.get_element_on_ui(deck_layer, "DecksList"));
	for (i = 0; i < array_length(decks); i++) {
		add_deck_ui_panel(decks[i].name)
	}
	check_deck_window();
}
