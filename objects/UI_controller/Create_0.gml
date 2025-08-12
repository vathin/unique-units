/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

check_layers = function() {
	if room == R_Main_menu and O_LoginController.logged_in {layer_set_visible(layer_get_id("MainMenu"), 1)}
	else {{layer_set_visible(layer_get_id("MainMenu"), 0)}}
	if room == R_Invite {layer_set_visible("InviteRoom", 1)}
	else {layer_set_visible("InviteRoom", 0)}
	if room == R_Game_search {layer_set_visible("SearchRoom", 1)}
	else {layer_set_visible("SearchRoom", 0)}
}