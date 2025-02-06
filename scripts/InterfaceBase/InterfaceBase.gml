// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

enum InterfaceUnit {
	pixel,
	percent
}

function InterfaceBase() constructor {
	ID = "";
	flex = flexpanel_create_node();
    
	active = true;
	visible = true;
    children = [];
    parent = undefined;
    is_broken = true;
    
    matrix = undefined;
    matrix_builder = new InterfaceMatrixBuilder();
    
    event_create = GetDelegate(self);
    event_destroy = GetDelegate(self);
    event_draw = GetDelegate(self);
    event_draw_end = GetDelegate(self);
    event_step_begin = GetDelegate(self);
    event_step = GetDelegate(self);
    event_size_changed = GetDelegate(self);
    
    old_width = 0;
    old_height = 0;
    
    color = c_white;
    alpha = 1;
    color_overwrite = undefined;
    alpha_overwrite = undefined;
	
	cached_geometry = undefined;
    
    static configurator = new InterfaceConfigurator();
    
    static create = function(data=undefined) {
        if (data != undefined)
            configure(data);
        
        event_create.call();
        
        set_broken();
    }
    static destroy = function(recursively=true) {
        remove_parent();
        
        if (recursively)
        for(var i = array_length(children) - 1; i >= 0; i--) {
            children[i].destroy(recursively);
        }
        
        event_destroy.call();
        
        ReleaseDelegate(event_create);
        ReleaseDelegate(event_destroy);
        ReleaseDelegate(event_draw);
        ReleaseDelegate(event_draw_end);
        ReleaseDelegate(event_step_begin);
        ReleaseDelegate(event_step);
        
        flexpanel_delete_node(flex);
    }
    static configure = function(data_struct) {
        configurator.configure_element_by_struct(self, data_struct);
    }
    
    static draw = function() {
        
        var matrix_old = undefined;
        if (matrix != undefined) {
            matrix_old = matrix_get(matrix_world);
            matrix_set(matrix_world, matrix);
        }
        
        var color_previous = draw_get_color();
        if (color_overwrite != undefined) {
            draw_set_color(color_overwrite);
        } else if (color != c_white) {
            draw_set_color(color_multiply(color_previous, color))
        }
        var alpha_previous = draw_get_alpha();
        if (alpha_overwrite != undefined) {
            draw_set_alpha(alpha_overwrite);
        } else if (alpha != 1) {
            draw_set_alpha(alpha * alpha_previous);
        }
        
		if (keyboard_check(vk_f1)) {
			var g = get_geometry();
			draw_rectangle(g.left, g.top, g.left + g.width, g.top + g.height, 1);
		}
		
        event_draw.call(self);
        for(var i = 0, i_size = array_length(children); i < i_size; i++) {
            children[i].draw();
        }
        event_draw_end.call(self);
        
        if (draw_get_color() != color_previous)
            draw_set_color(color_previous);
        if (draw_get_alpha() != alpha_previous)
            draw_set_alpha(alpha_previous);
        
        if (matrix_old != undefined) {
            matrix_set(matrix_world, matrix_old);
        }
    }
    static step = function() {
        event_step_begin.call(self);
        
        while (is_broken) {
            get_main_parent().calculate();
        }
        
        event_step.call(self);
        
        for(var i = array_length(children) - 1; i >= 0; i--) {
            children[i].step();
        }
    }
    
    static calculate = function() {
        var w, h;
        if (parent == undefined) {
            w = get_data_width();
            h = get_data_height();
        } else {
            var g = parent.get_geometry();
            w = g.width;
            h = g.height;
        }
        flexpanel_calculate_layout(flex, w, h, flexpanel_direction.LTR);
        
        set_calculated();
    }
    static set_calculated = function() {
        static child_set_calculated = function(_child) {
					_child.set_calculated();
                }
        
        is_broken = false; 
        array_foreach(children, child_set_calculated);
        
		cached_geometry = undefined;
		
        var geometry = get_geometry();
        var new_width = geometry.width;
        var new_height = geometry.height;
        if (new_width != old_width || new_height != old_height) {
            event_size_changed.call(self);
            old_width = new_width;
            old_height = new_height;
        }
    }
    static set_broken = function() {
        is_broken = true;
    }
    static get_main_parent = function() {
        var next = self, val = next;
        while (next != undefined) {
            val = next;
            next = next.parent;
        }
        return val;
    }
    static get_data_width = function() {
        return flexpanel_node_style_get_width(flex).value;
    }
    static get_data_height = function() {
        return flexpanel_node_style_get_height(flex).value;
    }
    
    static set_name = function(_name) {
		ID = _name;
        flexpanel_node_set_name(flex, _name);
    }
    static get_name = function() {
        return flexpanel_node_get_name(flex);
    }
    
	/// @desc Поиск элемента по имени
	static find = function(target_id) {
        if (self.ID == target_id) {
            return self; 
        }

        for (var i = 0; i < array_length(self.children); i++) {
            var child = self.children[i];
			
            var result = child.find(target_id);
            if (result != undefined) {
                return result; 
            }
        }

        return undefined;
    }
	
    /// @arg {Struct.InterfaceBase} _parent
    static set_parent = function(_parent) {
        _parent.add(self);
    }
    static get_parent = function() {
        return flexpanel_node_get_parent(flex);
    }
    static remove_parent = function() {
        if (parent != undefined) {
            parent.remove_child(self);
            parent = undefined;
        }
    }
    static remove_all_children = function() {
        repeat(array_length(children)) {
            remove_child(children[0]);
        }
    }
    /// @arg {Struct.InterfaceBase} _child
    static remove_child = function(_child) {
        var _i = array_get_index(children, _child);
        if (_i < 0) {
            return;
        }
        
        _child.parent = undefined;
        array_delete(children, _i, 1);
        flexpanel_node_remove_child(flex, _child.flex);
        set_broken();
    }
    /// @arg {Struct.InterfaceBase} _child
    static add = function(_child, _i = undefined) {
        if (_child.parent == self) {
            return;
        }
        
        _child.remove_parent();
        _child.parent = self;
        array_push(children, _child);
        
        _i ??= children_count_flex();
        flexpanel_node_insert_child(flex, _child.flex, _i);
        set_broken();
    }
    static children_count_flex = function() {
        return flexpanel_node_get_num_children(flex);
    }
    static children_count = function() {
        return array_length(children);
    }
    
	static set_active = function(_active) {
		active = _active;
	}
	static is_active = function() {
		var element = self;
		while (element.parent != undefined) {
			if (!element.active)
				return false;
		}
		return true;
	}
	static set_visible = function(_visible) {
		visible = _visible;
	}
	static is_visible = function() {
		var element = self;
		while (element.parent != undefined) {
			if (!element.visible)
				return false;
		}
		return true;
	}
	
	static set_left = function(_value, _unit=InterfaceUnit.pixel) {
		flexpanel_node_style_set_position(flex, flexpanel_edge.left, _value, GetFlexUnit(_unit));
        set_broken();
	}
    static set_top = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_position(flex, flexpanel_edge.top, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_right = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_position(flex, flexpanel_edge.right, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_bottom = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_position(flex, flexpanel_edge.bottom, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_indents = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_position(flex, flexpanel_edge.all_edges, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_size = function(_width, _height) {
		static val_width = []; configurator.parse_value(_width, val_width);
		static val_height = []; configurator.parse_value(_height, val_height);
		set_width(val_width[0], val_width[1]);
		set_height(val_height[0], val_height[1]);
	}
	static set_width = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_width(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_height = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_height(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_ratio = function(_value) {
        flexpanel_node_style_set_aspect_ratio(flex, _value);
        set_broken();
    }
    static set_align = function(_flexpanel_align) {
        flexpanel_node_style_set_align_self(flex, _flexpanel_align);
        set_broken();
    }
    static set_align_across = function(_flexpanel_align) {
        flexpanel_node_style_set_align_items(flex, _flexpanel_align)
        set_broken();
    }
    static set_justify_across = function(_flexpanel_justify) {
        flexpanel_node_style_set_align_content(flex, _flexpanel_justify)
        set_broken();
    }
    static set_justify = function(_flexpanel_justify) {
        flexpanel_node_style_set_justify_content(flex, _flexpanel_justify)
        set_broken();
    }
    static set_flex_direction = function(_flexpanel_flex_direction) {
        flexpanel_node_style_set_flex_direction(flex, _flexpanel_flex_direction);
        set_broken();
    }
    static set_flex_wrap = function(_flexpanel_wrap) {
        flexpanel_node_style_set_flex_wrap(flex, _flexpanel_wrap);
        set_broken();
    }
    static set_flex = function(_value) {
        flexpanel_node_style_set_flex(flex, _value);
        set_broken();
    }
    static set_anchor = function(_x, _y) {
		
	}
	
    static set_max_width = function(_value, _unit=InterfaceUnit.pixel) {
        show_debug_message("changed max width to " + string(_value))
        flexpanel_node_style_set_max_width(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_max_height = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_max_height(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_min_height = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_min_height(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    static set_min_width = function(_value, _unit=InterfaceUnit.pixel) {
        flexpanel_node_style_set_min_width(flex, _value, GetFlexUnit(_unit));
        set_broken();
    }
    
    static set_position_type = function(_flexpanel_position_type) {
        flexpanel_node_style_set_position_type(flex, _flexpanel_position_type);
        set_broken();
    }
    
    
    static matrix_move = function(offsetX, offsetY) {
        var _matrix = matrix_build(offsetX, offsetY, 0, 0, 0, 0, 1, 1, 1); 
        matrix_modify(_matrix);
    }
    static matrix_rotate = function(rotation, rotationX=0, rotationY=0) {
        var _matrix = matrix_build(0, 0, 0, rotationX, rotationY, rotation, 1, 1, 1); 
        matrix_modify(_matrix);
    }
    static matrix_scale = function(scaleX, scaleY, scaleZ=1) {
        var _matrix = matrix_build(0, 0, 0, 0, 0, 0, scaleX, scaleY, scaleZ);
        matrix_modify(_matrix);
    }
    static matrix_modify = function(other_matrix) {
        if (matrix == undefined) {
            set_matrix_null();
        }
        
        set_matrix(matrix_multiply(matrix, other_matrix));
        return self;
    }
    static set_matrix_ext = function(_x, _y, scaleX, scaleY, rotation) {
        set_matrix(matrix_build(_x, _y, 0, 0, 0, rotation, scaleX, scaleY, 0));
    }
    static set_matrix_null = function() {
        set_matrix(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1));
    }
    static set_matrix = function(_matrix) {
        matrix = _matrix;
		cached_geometry = undefined;
    }
    static reset_matrix = function() {
        matrix = undefined;
		cached_geometry = undefined;
    }
    
    /// @returns {Struct.InterfaceGeometry}
    static get_geometry = function() {
		if (is_undefined(cached_geometry)) {
			cached_geometry = flexpanel_node_layout_get_position(flex, false);
		}
		cached_geometry.right = cached_geometry.left + cached_geometry.width;
		cached_geometry.bottom = cached_geometry.top + cached_geometry.height;
		return cached_geometry;
    }
}

function InterfaceGeometry() constructor {
    left = 0;
    top = 0;
    right = 0;
    bottom = 0;
    width = 0;
    height = 0;
    hadOverflow = false;
    direction = 0;
}
InterfaceGeometry.Empty = new InterfaceGeometry();

function InterfaceMatrixBuilder() constructor {
    scaleX = 1;
    scaleY = 1;
    anchorX = 0.5;
    anchorY = 0.5;
    offsetX = 0;
    offsetY = 0;
    rotation = 0;
    
    /// @arg {Struct.InterfaceBase} _element
    static update = function(_element) {
        var geometry = _element.get_geometry();
        
        if (geometry.width == 0) {
            _element.calculate();
            geometry = _element.get_geometry();
        }
        
        var delay_x = geometry.left + geometry.width * anchorX;
        var delay_y = geometry.top + geometry.height * anchorY;
        
        _element.set_matrix_null();
        _element.matrix_move(-delay_x, -delay_y);
        _element.matrix_rotate(rotation);
        _element.matrix_scale(scaleX, scaleY);
        _element.matrix_move(delay_x + offsetX, delay_y + offsetY);
        show_debug_message([geometry, scaleX, scaleY, offsetX, offsetY])
    }
}

function GetFlexUnit(_v) {
	var unit = _v;
	if (is_string(_v)) {
		unit = GetInterfaceUnitByString(_v);
	}
    
    switch(unit) {
        case InterfaceUnit.percent: return flexpanel_unit.percent; 
        default: return flexpanel_unit.point;
    }
}
function GetInterfaceUnitByString(str) {
	switch(str) {
		case "%":
		case "percent":
			return InterfaceUnit.percent;
		case "px":
		case "p":
		case "point":
		case "pixel":
			return InterfaceUnit.pixel;
	}
    
    show_debug_message($"unknown unit {str}");
	return InterfaceUnit.pixel;
}


function point_matrix_multiply(_x, _y, matrix) {
	var point_matrix = matrix_build(_x, _y, 0, 0, 0, 0, 1, 1, 1);
	var result = matrix_multiply(point_matrix, matrix);
	return [result[12], result[13]];
}

