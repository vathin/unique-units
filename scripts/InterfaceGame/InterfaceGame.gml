// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceGame() : InterfaceMainElement() constructor {
    
    player_you = Interface.create(InterfacePlayerInfo);
    player_opponent = Interface.create(InterfacePlayerInfo);
    field = Interface.create(InterfaceField);
    units_stack_dump = Interface.create(InterfaceGameUnitsStack);
    units_stack_captive = Interface.create(InterfaceGameUnitsStack);
    
    set_position_type(flexpanel_position_type.absolute)
    set_justify(flexpanel_justify.center)
    
    event_create.add(function() {
        
        field.configure({
            width: 900,
            height: 900,
            align: flexpanel_align.center,
            align_across: flexpanel_align.center,
            justify: flexpanel_justify.center
        });
        
        units_stack_dump.configure({
            left: 0,
            width: 200,
            height: 900
        });
        units_stack_captive.configure({
            right: 0,
            width: 200,
            height: 900
        });
        units_stack_dump.set_position_type(flexpanel_position_type.absolute);
        units_stack_captive.set_position_type(flexpanel_position_type.absolute);
        units_stack_dump.set_label("Dump");
        units_stack_captive.set_label("Captive");
        
        player_opponent.set_side(1);
        player_you.set_side(0);
        
        add(player_you);
        add(player_opponent);
        add(field);
        add(units_stack_dump);
        add(units_stack_captive);
    })
    
    event_draw.add(function() {
        var geometry = get_geometry();
        
        draw_rectangle(geometry.left, geometry.top, geometry.left + geometry.width, geometry.top + geometry.height, true);
    })
}

show_debug_message([string(false), string(bool(false)), is_bool(false), is_bool(bool(false))])