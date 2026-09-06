function VK() constructor {
	
	vk_data = {sign: 0, vk_user_id: 0};
	vk_user = {first_name: "", last_name: ""};
	init_started = false;
	login_sent = false;
	
	static Init = function() {
		if (os_browser == browser_not_a_browser) {
			return false;
		}
		
		if (init_started || login_sent) {
			show_debug_message("VK login: init already started or login already sent");
			return true;
		}
		
		show_debug_message("VK login: start");
		init_started = true;
		return __extension_init();
	}
	
	static __extension_init = function() {
		if (!extension_exists("extension_VK")) {
			show_debug_message("no extension_VK");
			init_started = false;
			return false;
		}
		
		show_debug_message("VK login: initializing VK bridge");
		VKInit(method(self, __extension_init_result), method(self, __extension_init_error));
		
		return true;
	}
	
	static __extension_init_error = function() {
		show_debug_message("VK init failed");
		init_started = false;
	}
	
	static __extension_init_result = function() {
		vk_data = json_parse(VK_GetVkData());
		show_debug_message("VK login: launch params received: " + json_stringify(vk_data));
		__get_user_info();
	}
	
	static __get_user_info = function() {
		show_debug_message("VK login: getting account info");
		VK_GetPlayerInfo(method(self, __get_user_info_result));
	}
	
	static __get_user_info_result = function() {
		vk_user = json_parse(VK_GetPlayerInfoResult());
		show_debug_message("VK login: account info received: " + json_stringify(vk_user));
		LoginToServer();
	}
	
	static LoginToServer = function() {
		if (login_sent) {
			return;
		}
		
		if (!Server.connected) {
			show_debug_message("VK login skipped: server is not connected");
			init_started = false;
			return;
		}
		
		show_debug_message("VK login: sending login to server");
		login_sent = true;
		var msg = new ServerMessage(ServerMessageType.LoginVK, {
			userid: vk_data.vk_user_id,
			sign: vk_data.sign,
			vk_data: vk_user
		});
		Server.send(msg);
		show_debug_message("VK login: login request sent");
	}
}

global.vk = new VK();
