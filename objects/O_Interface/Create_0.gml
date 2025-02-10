/// @description Insert description here
// You can write your code in this editor
Interface.screen.add(Interface.create(InterfaceSprite, { sprite: S_Background, width: "100%", height: "100%"}));
Interface.screen.add(Interface.create(InterfaceGame, {  }));

Interface.screen.add(Interface.create(InterfaceButtonSprite, {
	x: 100,
	y: 100,
	width: 400,
	height: 128,
	position_type: flexpanel_position_type.absolute,
	text: "TEST"
}))

var element = Interface.create(InterfaceSequence, {
	position_type: flexpanel_position_type.absolute,
	x: 100, y: 400
});
Interface.screen.add(element);

element.set_sequence(design_test);