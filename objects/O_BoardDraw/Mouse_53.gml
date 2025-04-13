/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
selected_cell = Game.field.check_click()
if selected_cell != undefined {
	show_debug_message(selected_cell.get_coordinates())
}
