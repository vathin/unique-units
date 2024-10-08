address = "ws://127.0.0.1";
port = 987;

socket = undefined;
connect_request = noone;

connected = false;

callbacks = [];

connect = function() {
	socket = network_create_socket(network_socket_ws);
	network_connect_raw_async(socket, address, port);
}
disconnected_callback = function() {
	show_debug_message("disconnected");
	connected = false;
}
connected_callback = function() {
	show_debug_message("connected");
	connected = true;
	
	send(new ServerMessage(ServerMessageType.Login, {
		email: "vishnya@yandex.ru",
		password: "12345678"
	}))
}
connect_failure_callback = function() {
	show_debug_message("connect failure!")
}
message_callback = function(message_text) {
	show_debug_message("<< " + message_text)
	var msg = ServerMessage.Parse(message_text);
	call_reaction(msg);
}

send = function(_server_message) {
	var text = _server_message.toString();
	send_string(text);
}
send_string = function(_server_message_string) {
	buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(buffer, buffer_seek_start, 0);
	buffer_write(buffer, buffer_string, _server_message_string)
	
	show_debug_message(">> " + _server_message_string)
	
	network_send_raw(socket, buffer, buffer_tell(buffer) - 1, network_send_text);
	buffer_delete(buffer)
}

call_reaction = function(_message) {
	for(var i = array_length(callbacks) - 1; i >= 0; i--) {
		var reaction = callbacks[i];
		
		if (reaction.message_type == undefined || _message.is(reaction.message_type))
			reaction.func();
	}
}

add_reaction = function(func, message_type=undefined) {
	var new_callback = {message_type, func}
	array_push(callbacks, new_callback);
	return new_callback;
}
remove_reaction = function(_reaction) {
	var ind = array_get_index(callbacks, _reaction);
	if (ind < 0) return;
	array_delete(callbacks, ind, 1)
}

connect();