
SequenceInterfaceClasses().register("text", InterfaceText);
function InterfaceText() : InterfaceBase() constructor {
    
    text = "";
    text_to_render = "";
    text_halign = fa_center;
    text_valign = fa_center;
    
	static configurator = new InterfaceConfiguratorText();
	
	
    static set_text = function(_text) {
        if (_text == text)
            return;
        
        text = _text;
        
        text_to_render = text;
    }
    
    event_draw.add(function() {
        var geometry = get_geometry();
        
        draw_set_halign(text_halign);
        draw_set_valign(text_valign);
        draw_text(  geometry.left + geometry.width * (text_halign/2),
                    geometry.top + geometry.height * (text_valign/2),
                    text_to_render);
    })
}

function InterfaceConfiguratorText() : InterfaceConfigurator() constructor {
	static handle_text = function(element, key, val, parsed_val) {
		element.set_text(val);
		return true;
	}
	static handle_halign = function(element, key, val, parsed_val) {
		element.text_halign = parsed_val[0];
		return true;
	}
	static handle_valign = function(element, key, val, parsed_val) {
		element.text_valign = parsed_val[0];
		return true;
	}
	add_key_handler("text", handle_text);
	add_key_handler("halign", handle_halign);
	add_key_handler("valign", handle_valign);
}