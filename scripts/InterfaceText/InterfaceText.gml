// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceText() : InterfaceBase() constructor {
    
    text = "";
    text_to_render = "";
    text_halign = fa_center;
    text_valign = fa_center;
    
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