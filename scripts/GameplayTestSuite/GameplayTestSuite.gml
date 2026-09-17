function GameplayTestSuite(_name) constructor {
	name = _name;
	passed = 0;
	failed = 0;

	log = function(_message) {
		show_debug_message(_message);
		if os_get_config() == "test" {
			var _file = file_text_open_append("gameplay-tests.log");
			file_text_write_string(_file, _message + "\n");
			file_text_close(_file);
		}
	}

	assert_true = function(_condition, _description) {
		if _condition {
			passed++;
			log("TEST PASS: " + name + " | " + _description);
		}
		else {
			failed++;
			log("TEST FAIL: " + name + " | " + _description);
		}
	}

	assert_equal = function(_actual, _expected, _description) {
		assert_true(_actual == _expected, _description + " (actual=" + string(_actual) + ", expected=" + string(_expected) + ")");
	}

	run_case = function(_name, _test) {
		try {
			_test();
		}
		catch (_error) {
			failed++;
			log("TEST ERROR: " + name + " | " + _name + " | " + string(_error));
		}
	}

	finish = function() {
		log("TEST SUMMARY: " + name + " | passed=" + string(passed) + ", failed=" + string(failed));
		return failed == 0;
	}
}
