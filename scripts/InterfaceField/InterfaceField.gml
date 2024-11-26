// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceField() : InterfaceBase() constructor {
    sprite = S_Map;
    cells_x = 6;
    cells_y = 6;
    
    event_draw.add(function() {
        var geometry = get_geometry();
        draw_sprite_stretched(sprite, 0, geometry.left, geometry.top, geometry.width, geometry.height);
    })
}