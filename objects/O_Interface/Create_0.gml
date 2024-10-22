/// @description Insert description here
// You can write your code in this editor

ga_configureBuild("0.0.1");
ga_configureUserId("user1");
ga_setEnabledInfoLog(true);
ga_setEnabledVerboseLog(true);
ga_setEnabledEventSubmission(true);
ga_initialize("6ecb87e52b1c57d717568b48071fd5f3", "0ce0bbdb2b8c2cb7dc61d4e203239e1c5107db9c");

center = Interface.create(InterfaceSprite, {
    height: "100%",
    align: flexpanel_align.center,
    align_across: flexpanel_align.center,
    sprite: S_Summon_mark
    //add: [
        //Interface.create(InterfaceSprite),
        //Interface.create(InterfaceSprite)
    //]
})

Interface.screen.event_size_changed.add(function() {
    var screen_geometry = Interface.screen.get_geometry();
    
    var aspect = 1000/700;
    
    var w = min(screen_geometry.width, screen_geometry.height / aspect);
    var h = w * aspect;
    
    center.set_width(w);
    center.set_height(h);
    center.set_top((screen_geometry.height - h)/2);
})

Interface.screen.add(center);
