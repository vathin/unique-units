/// @description Insert description here
// You can write your code in this editor
Interface.screen.add(Interface.create(InterfaceSprite, { sprite: S_Background, width: "100%", height: "100%"}));
Interface.screen.add(Interface.create(InterfaceGame, {  }));

Interface.screen.add(Interface.create(InterfaceButton, {
	x: 100,
	y: 100,
	width: 128,
	height: 48,
	position_type: flexpanel_position_type.absolute
}))
