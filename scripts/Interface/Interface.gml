// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function Interface() constructor {
	static screen = new InterfaceScreen();
    
    /// @return {Struct.InterfaceBase}
    static create = function(class, arg=undefined) {
        var instance = new class();
        instance.create(arg);
        return instance;
    }
    
    static step = function() {
        screen.step();
    }
    
    static draw = function() {
        screen.draw();
    }
}


new Interface();

