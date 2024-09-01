/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

player1_field_figures = 0;
player2_field_figures = 0;
current_player_figures = 20;

get_field_figures = function(player) {
	if player = "player1" {return player1_field_figures}
	else {return player2_field_figures}
}
get_player_figures_amount = function(player) {
	return array_length(O_App.data.load(player).player_figures);
}

change_field_figures_amount = function(player, amount) {
	if player = "player1" {player1_field_figures += amount}
	else {player2_field_figures += amount}
}

update_turn = function() {
	current_player_figures = array_length(O_App.data.load(global.turn_owner).player_figures);
	if current_player_figures <= 0 or (player1_field_figures >= Settings.max_field_figures or player2_field_figures >= Settings.max_field_figures){
		O_SummonButton.block();
	}
}

get_summon_figures_amount = function(player) {
	if player = "player1" {
		if get_player_figures_amount(player) < Settings.max_field_figures - player1_field_figures {return get_player_figures_amount(player)}
		else {return Settings.max_field_figures - player1_field_figures}}
	else {
		if get_player_figures_amount(player) < Settings.max_field_figures - player2_field_figures {return get_player_figures_amount(player)}
		else {return Settings.max_field_figures - player2_field_figures}}
}

get_current_player_figures = function() {
	return current_player_figures;
}