
SequenceInterfaceClasses().register("sprite", InterfaceSprite);
function InterfaceSprite() : InterfaceBase() constructor {
    
    sprite = S_Ability_mark;
    frame = 0;
    fit_type = SpriteFitType.stretched;
    
    event_draw.add(function() {
        var geometry = get_geometry();
        
        switch (fit_type) {
            case SpriteFitType.stretched: 
                draw_sprite_stretched(sprite, frame, geometry.left, geometry.top, geometry.width, geometry.height);
            break;
        }
    })
}

enum SpriteFitType {
    stretched,
    tiled,
    scaleMin,
    scaleMax
}