// This is the only automatic test entry point in the project.
if (os_get_config() == "test") {
	new Maps_list();
	new Settings();
	global.map = "map1";
	global.game = {game_input: new GameInput()};
	var _suite = new GameplayTestSuite("Gameplay rules");
	new GameplayRulesTests(_suite).run();
	_suite.finish();
	game_end();
}
