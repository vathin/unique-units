// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceMainElement() : InterfaceBase() constructor{
    
    event_create.add(function() {
        set_align(flexpanel_align.center);
        set_align_across(flexpanel_align.center);
        set_width(InterfaceScreen.base_width);
        set_height(InterfaceScreen.base_height);

        Interface.screen.event_size_changed.add(method(self, update_scale));
    });
    
    static update_scale = function() {
        var screen_geometry = Interface.screen.get_geometry();
        
        var scale = min(screen_geometry.width / InterfaceScreen.base_width, screen_geometry.height / InterfaceScreen.base_height);

        matrix_builder.scaleX = scale;
        matrix_builder.scaleY = scale;
        matrix_builder.update(self);
    }
}