// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfacePlayerInfo() : InterfaceBase() constructor {
    set_width(600);
    set_height(200);
    set_position_type(2); // static
    set_top(0);
    
    side = 0;
    player_name = "unnamed";
    player_icon = S_Archer;
    
    
    event_draw.add(function() {
        var geometry = get_geometry();
        var center_x = geometry.left + geometry.width/2;
        var center_y = geometry.top + geometry.height/2;
        var scale = 0.2;
        draw_sprite_ext(player_icon, side, side < 0.5 ? geometry.left + 64 : geometry.left + geometry.width - 64, center_y, scale, scale, 0, c_white, 1);
        
        draw_set_font(F_test);
        draw_set_valign(fa_center);
        draw_set_halign(fa_center);
        draw_text(center_x + 32, center_y, player_name);
    })
    
    static set_side = function(_side) {
        side = _side;
        if (side < 0.5) {
            set_left(0);
        } else {
            set_right(0);
        }
    }
    static set_icon = function(_icon) {
        player_icon = _icon;
    }
    static set_name = function(_name) {
        player_name = _name;
    }
}