// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceGame() : InterfaceMainElement() constructor {
    
    player_you = Interface.create(InterfacePlayerInfo);
    player_opponent = Interface.create(InterfacePlayerInfo);
    field = Interface.create(InterfaceField);
    
    set_position_type(flexpanel_position_type.absolute)
    set_justify(flexpanel_justify.center)
    
    event_create.add(function() {
        
        field.configure({
            width: 1024,
            height: 1024,
            align: flexpanel_align.center,
            align_across: flexpanel_align.center,
            justify: flexpanel_justify.center
        });
        
        player_opponent.set_side(1);
        player_you.set_side(0);
        
        add(player_you);
        add(player_opponent);
        add(field);
    
    })
    
}

show_debug_message([string(false), string(bool(false)), is_bool(false), is_bool(bool(false))])