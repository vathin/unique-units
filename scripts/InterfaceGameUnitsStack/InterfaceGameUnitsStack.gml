// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceGameUnitsStack() : InterfaceBase() constructor {
    
    units_your = [];
    units_opponent = [];
    unit_size = {x: 64, y: 64};
    
    set_justify(flexpanel_justify.center);
    set_justify_across(flexpanel_justify.center);
    
    label = Interface.create(InterfaceText, {
        width: "100%",
        height: 48
    });
    add(label);
    
    get_position_of = function(is_your, index) {
        var geometry = get_geometry();
        var labelOffset = label.get_geometry().height;
        var centerY = geometry.top + geometry.height/2;
        
        return centerY + (unit_size.y * index + labelOffset) * (is_your ? 1 : -1);
    }
    
    static set_label = function(text) {
        label.set_text(text);
    }
    
}