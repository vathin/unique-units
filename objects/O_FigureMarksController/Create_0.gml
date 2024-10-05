/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе
standart_scale = 1;
marks_sprites = [];
image_xscale = standart_scale;

draw_marks = function() {
	for (i = 0; i < array_length(marks_sprites); i++) {
		if array_length(marks_sprites) == 1 {
			draw_sprite_ext(marks_sprites[i], 0, x, y, 1, 1, 0, c_white, 0.85);
		}
		if array_length(marks_sprites) == 2 {
			draw_sprite_ext(marks_sprites[i], 0, x-(image_xscale*15+i*image_xscale*30), y, 1, 1, 0, c_white, 0.85);
		}
		//if array_length(marks_sprites) == 3
	} 
}