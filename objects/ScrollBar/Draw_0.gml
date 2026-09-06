draw_self();
if (controlled_element != "default" && controlled_el_layer != "default") {
	if (variable_instance_exists(UI_controller, "ui_scissor_for_scroll")) {
		var _viewport = UI_controller.ui_scissor_for_scroll(controlled_el_layer, controlled_element);
		if (_viewport != undefined) {
			viewport_gui = _viewport;
			viewport_has_scissor = true;
		}
		else {
			viewport_has_scissor = false;
		}
	}
	else {
		viewport_has_scissor = false;
		show_debug_message("ScrollBar scissor skipped: UI_controller.ui_scissor_for_scroll is missing");
	}
}
/*var _tx = x-(bar_width/2);
var _ty = scroll_top+thumb_offset+drag;
if(horizontal){
    _tx = _ty;
    _ty = y-(thumb_height/2);
    draw_sprite_stretched(thumb_sprite,0,_tx,_ty,thumb_width,10);
} else {
    draw_sprite_stretched(thumb_sprite,0,_tx,_ty,10,thumb_height);
}*/
//draw_text(x, y, scroll_speed)
