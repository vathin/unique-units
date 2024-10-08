/// @description 

if (async_load[? "id"] == socket) {
	show_debug_message(json_encode(async_load));
		
	if (async_load[? "type"] == network_type_non_blocking_connect) {
		if (!async_load[? "succeeded"]) {
			connect_failure_callback();
		} else {
			connected_callback();
		}
	}
	
	if (async_load[? "type"] == network_type_disconnect) {
	
		disconnected_callback();
	}

	if (async_load[? "type"] == network_type_data) {
		var buffer = async_load[? "buffer"];
		buffer_seek(buffer, buffer_seek_start, 0);
		var text = buffer_read(buffer, buffer_string);
		
		message_callback(text);
	}
}