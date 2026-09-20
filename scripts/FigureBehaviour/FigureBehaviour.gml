// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FigureBehaviour() constructor{
	index = "";
	sprite = undefined;
	rarity = 0;
	deck_class = "";
	dev = false;
}

/// Placeholder behaviour for a future figure. It has no art, effects or move
/// logic and must never enter normal deckbuilding until its implementation is ready.
function DevFigureBehaviour(_index, _deck_class) : FigureBehaviour() constructor {
	index = _index;
	deck_class = _deck_class;
	dev = true;
	max_deck_amount = _deck_class == "S" ? 1 : 5;
	switch _deck_class {
		case "D": rarity = 1; break;
		case "C": rarity = 2; break;
		case "B": rarity = 3; break;
		case "A": rarity = 4; break;
		case "S": rarity = 5; break;
	}
}

function RiderBehaviour() : DevFigureBehaviour("rider", "D") constructor {}
function OgreBehaviour() : DevFigureBehaviour("ogre", "D") constructor {}
function IllusionistBehaviour() : DevFigureBehaviour("illusionist", "D") constructor {}
function PetrifiedBehaviour() : DevFigureBehaviour("petrified", "D") constructor {}
function ZombieBehaviour() : DevFigureBehaviour("zombie", "D") constructor {}

function AcrobatBehaviour() : DevFigureBehaviour("acrobat", "C") constructor {}
function AdlingBehaviour() : DevFigureBehaviour("adling", "C") constructor {}
function AlchemistBehaviour() : DevFigureBehaviour("alchemist", "C") constructor {}
function SlimeBehaviour() : DevFigureBehaviour("slime", "C") constructor {}
function ValravnBehaviour() : DevFigureBehaviour("valravn", "C") constructor {}
function SkeletonBehaviour() : DevFigureBehaviour("skeleton", "C") constructor {}

function GhoulBehaviour() : DevFigureBehaviour("ghoul", "B") constructor {}
function GoblinBehaviour() : DevFigureBehaviour("goblin", "B") constructor {}
function WitchBehaviour() : DevFigureBehaviour("witch", "B") constructor {}
function VampireBehaviour() : DevFigureBehaviour("vampire", "B") constructor {}

function MermaidBehaviour() : DevFigureBehaviour("mermaid", "A") constructor {}
function BerserkBehaviour() : DevFigureBehaviour("berserk", "A") constructor {}
function HealerBehaviour() : DevFigureBehaviour("healer", "A") constructor {}
function GhostBehaviour() : DevFigureBehaviour("ghost", "A") constructor {}

function SeerBehaviour() : DevFigureBehaviour("seer", "S") constructor {}
function CannibalBehaviour() : DevFigureBehaviour("cannibal", "S") constructor {}
function DryadBehaviour() : DevFigureBehaviour("dryad", "S") constructor {}
function NavigatorBehaviour() : DevFigureBehaviour("navigator", "S") constructor {}
function LichBehaviour() : DevFigureBehaviour("lich", "S") constructor {}
