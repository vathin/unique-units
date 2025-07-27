// Ресурсы скриптов были изменены для версии 2.3.0, подробности см. по адресу
// https://help.yoyogames.com/hc/en-us/articles/360005277377
function Figure_state() constructor{
	is_active = false;
	is_dropped = false;
	is_closed = false;
	is_overturned = false;
	is_captured = false;
	is_conquesting = false;
	
	export = function() {
		export_data = {
			ex_is_active: is_active,
			ex_is_dropped: is_dropped,
			ex_is_closed: is_closed,
			ex_is_overturned: is_overturned,
			ex_is_captured: is_captured,
			ex_is_conquesting: is_conquesting
		}
		return export_data
	}
	
	import = function(_import_data) {
		is_active = _import_data.ex_is_active;
		is_dropped = _import_data.ex_is_dropped;
		is_closed = _import_data.ex_is_closed;
		is_overturned = _import_data.ex_is_overturned;
		is_captured = _import_data.ex_is_captured;
		is_conquesting = _import_data.ex_is_conquesting;
	}
}