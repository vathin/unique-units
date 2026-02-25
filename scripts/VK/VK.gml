function VK() constructor {
	
	vk_data = {sign: 0, vk_user_id: 0};
	vk_user = {first_name: "", last_name: ""};
	
	static Init = function() {
		__extension_init();
	}
	
	static __extension_init = function() {
		if (!extension_exists("extension_VK")) {
			show_debug_message("no extension");
			__extension_init_test();
			return false;
		}
		
		VKInit(method(self, __extension_init_result), method(self, __extension_init_test));
		
		return true;
	}
	
	static __extension_init_test = function() {
		vk_data = {sign: 0, vk_user_id: 14123};
		vk_user = {first_name: "test", last_name: "test"}
		LoginToServer();
	}
	
	static __extension_init_result = function() {
		vk_data = json_parse(VK_GetVkData());
		__get_user_info();
	}
	
	static __get_user_info = function() {
		show_debug_message("get user info");
		VK_GetPlayerInfo(method(self, __get_user_info_result));
	}
	
	static __get_user_info_result = function() {
		vk_user = json_parse(GetPlayerInfoResult());
		show_debug_message("getting info: " + json_stringify(vk_user))
		LoginToServer();
	}
	
	static LoginToServer = function() {
		show_debug_message("logging in");
		var msg = new ServerMessage(ServerMessageType.LoginVK, {
			userid: vk_data.vk_user_id,
			sign: vk_data.sign,
			vk_data: vk_user
		});
		Server.send(msg);
		show_debug_message("logging in");
	}
}

global.vk = new VK();
