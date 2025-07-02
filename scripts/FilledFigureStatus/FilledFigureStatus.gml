// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function FilledFigureStatus() constructor{
	start = function() {
		will_be_captured = false;
		will_be_dropped = false;
		will_be_filled = false;
		will_be_moved = false;
		will_conquest = false;
		will_be_summoned = false;
		selected = false;
	}
	
	status_sprites_list = {
		will_be_captured: undefined, //
		will_be_dropped: undefined, //
		will_be_moved: undefined, //
		will_be_filled: undefined, //
		will_conquest: undefined, //
		will_be_summoned: undefined, //
		selected: undefined //
	}
	
	get_status_sprite = function(_status) {
		return status_sprites_list[$ _status]
	}
	
	get_active_draw_statuses = function() {
		active_statuses = []
		if will_be_captured {array_push(active_statuses, "will_be_captured")}
		if will_be_dropped {array_push(active_statuses, "will_be_dropped")}
		if will_be_summoned {array_push(active_statuses, "will_be_summoned")}
		if will_be_moved {array_push(active_statuses, "will_be_moved")}
		if will_conquest {array_push(active_statuses, "will_conquest")}
		if selected {array_push(active_statuses, "selected")}
		return active_statuses
	}
	
	get_draw_statuses_amount = function() {
		return array_length(get_active_statuses())
	}
	
	set_status = function(_new_status, _value) {
		if _new_status == "will_be_captured" {will_be_captured = _value}
		if _new_status == "will_be_dropped" {will_be_dropped = _value}
		if _new_status == "will_be_summoned" {will_be_summoned = _value}
		if _new_status == "will_be_moved" {will_be_moved = _value}
		if _new_status == "will_conquest" {will_conquest = _value}
		if _new_status == "selected" {selected = _value}
	}
	
	start();
	
}