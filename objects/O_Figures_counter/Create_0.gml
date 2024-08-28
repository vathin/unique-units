/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

player1_field_figures = 0;
player2_field_figures = 0;

get_field_figures = function(player) {
	if player = "player1" {return player1_field_figures}
	else {return player2_field_figures}
}

change_field_figures_amount = function(player, amount) {
	if player = "player1" {player1_field_figures += amount}
	else {player2_field_figures += amount}
}

update_turn = function() {
	global.current_player_figures = array_length(O_App.data.load(global.turn_owner).player_figures);
	if global.current_player_figures <= 0 {
		O_SummonButton.block();
	}
}

get_summon_figures_amount = function(player) {
	if player = "player1" {return Settings.max_field_figures - player1_field_figures}
	else {return Settings.max_field_figures - player2_field_figures}
}