/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
draw_set_font(F_test);
draw_self()
draw_text_transformed(x-sprite_width/2+7, y-12, text, 0.8, 0.8, 0)
if selected {image_index = 1}
else{image_index = 0}
draw_set_font(F_turn_timer);