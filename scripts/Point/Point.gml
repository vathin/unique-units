function Point(_x = 0, _y = 0) constructor {
	x = _x;
	y = _y;
	
	static set = function(_x, _y) {
		x = _x;
		y = _y;
	}
	static set_from_point = function(_point) {
		x = _point.x;
		y = _point.y;
	}
	static add = function(point) {
		x += point.x;
		y += point.y;
	}
	static add_number = function(number) {
		x += number;
		y += number;
	}
	static multiply = function(point) {
		x *= point.x;
		y *= point.y;
	}
	static multiply_number = function(number) {
		x *= number;
		y *= number;
	}
	static subtract = function(point) {
        x -= point.x;
        y -= point.y;
    }

    // Вычитание числа
    static subtract_number = function(number) {
        x -= number;
        y -= number;
    }

    // Деление на другую точку
    static divide = function(point) {
        if (point.x != 0 && point.y != 0) {
            x /= point.x;
            y /= point.y;
        } else {
            show_message("Деление на ноль невозможно!");
        }
    }

    // Деление на число
    static divide_number = function(number) {
        if (number != 0) {
            x /= number;
            y /= number;
        } else {
            show_message("Деление на ноль невозможно!");
        }
    }

    // Инверсия точки (изменение знака)
    static invert = function() {
        x = -x;
        y = -y;
    }

    // Длина вектора точки
    static length = function() {
        return sqrt(x * x + y * y);
    }

    // Нормализация точки (приведение длины к 1)
    static normalize = function() {
        var len = length();
        if (len != 0) {
            x /= len;
            y /= len;
        } else {
            x = 0;
			y = 0;
			show_debug_message("trying to normalize null vector!");
        }
    }

    // Расстояние до другой точки
    static distance_to = function(point) {
        var dx = x - point.x;
        var dy = y - point.y;
        return sqrt(dx * dx + dy * dy);
    }
	
	static point_round = function() {
	    x = round(x);
	    y = round(y);
	}
	
	static copy = function() {
	    return new Point(x, y);
	}
	
	static is_equals = function(point) {
	    return x == point.x && y == point.y;
	}
	
	static toString = function() {
	    return "(" + string(x) + ", " + string(y) + ")";
	}
	
}