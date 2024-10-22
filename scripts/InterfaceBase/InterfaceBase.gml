// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

enum InterfaceUnit {
	pixel,
	percent
}

function InterfaceBase() constructor {
	flex = flexpanel_create_node();
    
    children = [];
    parent = undefined;
    is_broken = true;
    
    event_create = GetDelegate(self);
    event_destroy = GetDelegate(self);
    event_draw = GetDelegate(self);
    event_draw_end = GetDelegate(self);
    event_step_begin = GetDelegate(self);
    event_step = GetDelegate(self);
    event_size_changed = GetDelegate(self);
    
    old_width = 0;
    old_height = 0;
    
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
        
        event_draw.call(self);
        
        for(var i = 0, i_size = array_length(children); i < i_size; i++) {
            children[i].draw();
        }
        
        event_draw_end.call(self);
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
        
        show_debug_message($"calculate {get_name()}: {w}-{h} {get_geometry()}")
        
        set_calculated();
    }
    static set_calculated = function() {
        static child_calculated = function(_child) {
                    _child.set_calculated();
                }
        
        is_broken = false; 
        array_foreach(children, child_calculated);
        
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
        flexpanel_node_set_name(flex, _name);
    }
    static get_name = function() {
        return flexpanel_node_get_name(flex);
    }
    
    /// @arg {Struct.InterfaceBase} _parent
    static set_parent = function(_parent) {
        _parent.insert_child(self);
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
    
    /// @returns {Struct.InterfaceGeometry}
    static get_geometry = function() {
        return flexpanel_node_layout_get_position(flex, false);
    }
}
function InterfaceGeometry() {
    left = 0;
    top = 0;
    right = 0;
    bottom = 0;
    width = 0;
    height = 0;
    hadOverflow = false;
    direction = 0;
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




