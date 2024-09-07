/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

animation_length = 30;
animation_enabled = false;
animation_frame = 0;
x_from = 0;
y_from = 0;
x_to = 0;
y_to = 0;
percent = 0;
animate_figure = undefined;

start_animation = function(x_from, y_from, x_to, y_to, animation_length, animate_figure) {
	self.x_from = x_from;
	self.y_from = y_from;
	self.x_to = x_to;
	self.y_to = y_to;
	self.animation_length = animation_length;
	self.animate_figure = animate_figure;
	animation_frame = 0;
	animation_enabled = 1;
	percent = 0;
}

update_animation = function() {
	animation_frame++;
	percent = animation_frame / animation_length;
	animate();
}

animate = function() {
	
}
	