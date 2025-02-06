function Box(_left/*:number*/, _top/*:number*/, _right/*:number*/, _bottom/*:number*/) constructor {
	left = _left; /// @is {number}
	top = _top; /// @is {number}
	right = _right; /// @is {number}
	bottom = _bottom; /// @is {number}
	center_point = new Point(1, 1);
	
	static size_for_orientation = function(_orientation) {
		if (_orientation == orientation.hor)
			return width();
		else
			return height();
	}
	static width = function() {
		return right - left;
	}
	static height = function() {
		return bottom - top;
	}
	static center = function() {
		center_point.set((left + right) * 0.5, (top + bottom) * 0.5);
		return center_point;
	}
	static set = function(_left/*:number*/, _top/*:number*/, _right/*:number*/, _bottom/*:number*/)/*->void*/ {
	
		left = _left; /// @is {number}
		top = _top; /// @is {number}
		right = _right; /// @is {number}
		bottom = _bottom; /// @is {number}
	}
	static toString = function() /*=>*/ {
		return $"[{instanceof(self)}: {left}, {top}, {right}, {bottom}]";
	}
	static equals = function(_box/*:Box*/) /*=>*/ {
		return _box.left == left && _box.top == top && _box.right == right && _box.bottom == bottom;
	}
}