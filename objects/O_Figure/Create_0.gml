/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
in_move = false;
owner = "player1";

image_speed = 0;
image_xscale = Settings.figure_scale;
image_yscale = Settings.figure_scale;

able_to_move = true;
friendly = true;
var behaviour;
sprite_index = Behaviours.get_sprite(global.figure_to_summon);
sprite = Behaviours.get_sprite(global.figure_to_summon);

set_behaviour = function(new_behaviour) {
	behaviour = Behaviours.get(new_behaviour);
}