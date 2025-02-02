// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function InterfaceConfigurator() constructor {
    additional_keys = {};
    
    /// @arg {Struct.InterfaceBase} element
    /// @arg {Struct} struct
    static configure_element_by_struct = function(element, struct) {
        var keys = variable_struct_get_names(struct);
        for(var i = 0; i < array_length(keys); i++) {
            var key = keys[i];
            configure_element_by_key_value(element, key, struct[$ key]);
        }
    }
    /// @arg {Struct.InterfaceBase} element
    static configure_element_by_key_value = function(element, key, value) {
        static val_container = [];
        parse_value(value, val_container);
        
        switch (key) {
            case "name":
                element.set_name(value);
                break;
            case "x":
            case "left":
                element.set_left(val_container[0], val_container[1]);
                break;
            case "y":
            case "top":
                element.set_top(val_container[0], val_container[1]);
                break;
            case "right":
                element.set_right(val_container[0], val_container[1]);
                break;
            case "bottom":
                element.set_bottom(val_container[0], val_container[1]);
                break;
            case "width":
            case "w":
                element.set_width(val_container[0], val_container[1]);
                break;
            case "height":
            case "h":
                element.set_height(val_container[0], val_container[1]);
                break;
            case "min_height":
            case "min_h":
            case "min-h":
            case "min-height":
                element.set_min_height(val_container[0], val_container[1]);
                break;
            case "max_height":
            case "max_h":
            case "max-h":
            case "max-height":
                element.set_max_height(val_container[0], val_container[1]);
                break;
            case "min_width":
            case "min_w":
            case "min-w":
            case "min-width":
                element.set_min_width(val_container[0], val_container[1]);
                break;
            case "max_width":
            case "max_w":
            case "max-w":
            case "max-width":
                element.set_max_width(val_container[0], val_container[1]);
                break;
            case "indent":
            case "indents":
                element.set_indents(val_container[0], val_container[1]);
                break;
            case "ratio":
            case "aspect":
            case "aspect_ratio":
            case "aspect-ratio":
                element.set_ratio(val_container[0]);
                break;
            case "align":
                element.set_align(val_container[0]);
                break; 
            case "align-across":
            case "align-cross":
            case "align_across":
            case "align_cross":
                element.set_align_across(val_container[0]);
                break;
            case "justify":
                element.set_justify(val_container[0]);
                break;
            case "justify-cross":
            case "justify-across":
            case "justify_cross":
            case "justify_across":
                element.set_justify_across(val_container[0]);
                break;
            case "flex-direction":
            case "flex_direction":
                element.set_flex_direction(val_container[0]);
                break;
            case "flex-wrap":
            case "flex_wrap":
                element.set_flex_wrap(val_container[0]);
                break;
            case "flex":
                element.set_flex(val_container[0]);
                break;
            case "add":
            case "child":
            case "children":
                var children = is_array(value) ? value : [value];
                self.element = element;
                array_foreach(children, add_children_by_data);
                break;
			case "position_type":
				element.set_position_type(value);
				break;
            default:
                handle_undefined_key(element, key, value)
            
        }
    }
    static parse_value = function(_val, _out) {
        if (!is_string(_val)) {
            _out[0] = _val;
            _out[1] = undefined;
            return;
        }
        
        switch (_val) {
            case "true":
                _out[0] = true;
                _out[1] = undefined;
                return;
            case "false":
                _out[0] = false;
                _out[1] = undefined;
                return;
            case "undefined":
                _out[0] = undefined;
                _out[1] = undefined;
                return;
        }
        
        var number_part = string_digits(_val);
        var unit_part = string_replace(_val, number_part, "");
        var unit = GetInterfaceUnitByString(unit_part);
        var number = number_part == "" ? get_default_value_for_unit(unit) : real(number_part);
        
        _out[0] = number;
        _out[1] = unit;
    }
    static get_default_value_for_unit = function(_unit) {
        switch (_unit) {
            case InterfaceUnit.percent: return 100;
            default: return 0;
        }
    }
    static add_children_by_data = function(data) {
        element.add(data);
    }
    static handle_undefined_key = function(element, key, value, parsed_value) {
        var handler = get_key_handler(key);
        if (handler != undefined) {
            handler(element, key, value, parsed_value);
        }
        
        element[$ key] = value;
    }
    
    static get_key_handler = function(key) {
        return additional_keys[$ key];
    }
    static add_key_handler = function(key, func) {
        additional_keys[$ key] = func;
    }
}
