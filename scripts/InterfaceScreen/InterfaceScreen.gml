// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function InterfaceScreen() : InterfaceBase() constructor {

    window_w = 0;
    window_h = 0;
    
    static base_height = 1920;
    static base_width = 1344;
    gui_width = 0;
    gui_height = 0;
    
    color_override = c_white;
    alpha_override = 1;
    
    event_create.add(function() {
        set_align_across(flexpanel_align.center);
        set_justify_across(flexpanel_justify.center);
        set_justify(flexpanel_justify.space_evenly);
        set_flex_direction(flexpanel_flex_direction.column);
    });
    event_step_begin.add(function() {
        if (window_get_width() != window_w || window_get_height() != window_h) {
            window_w = window_get_width();
            window_h = window_get_height();
            
            recalculate_screen();
        }
    })
    recalculate_screen = function() {
        gui_height = base_height;
        gui_width = window_w * (gui_height / window_h);
        
        display_set_gui_size(gui_width, gui_height);
        set_width(gui_width);
        set_height(gui_height);
    }
    
}