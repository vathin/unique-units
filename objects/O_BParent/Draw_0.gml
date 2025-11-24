draw_self();
if position_meeting(mouse_x, mouse_y, self) {image_alpha = lerp(image_alpha, 0.7, 0.14)}
else if image_alpha < 1 {image_alpha = lerp(image_alpha, 1, 0.14)}