/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
draw_self();
if is_active {draw_text(x + 115, y - 110, O_Figures_counter.get_current_player_figures())}
draw_text(standart_x + 115, standart_y + 55, "Доступно: " + string(O_Figures_counter.get_summon_figures_amount(global.turn_owner)))