function GameplayTestSuite(_name) constructor {
	name = _name;
	passed = 0;
	failed = 0;

	assert_true = function(_condition, _description) {
		if _condition {
			passed++;
			show_debug_message("TEST PASS: " + name + " | " + _description);
		}
		else {
			failed++;
			show_debug_message("TEST FAIL: " + name + " | " + _description);
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
			show_debug_message("TEST ERROR: " + name + " | " + _name + " | " + string(_error));
		}
	}

	finish = function() {
		show_debug_message("TEST SUMMARY: " + name + " | passed=" + string(passed) + ", failed=" + string(failed));
		return failed == 0;
	}
}
