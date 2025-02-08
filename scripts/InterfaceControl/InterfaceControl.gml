function InterfaceControlApply() {
	if (variable_struct_exists(self, "control"))
		return false;
		
	control = new InterfaceControlComponent(self);
}

/// @arg {Struct.InterfaceBase} _element
function InterfaceControlComponent(_element) constructor {
	static global_selected = undefined;
	static global_deselect = function() {
		if (global_selected != undefined)
			global_selected.deselect();
	}
	
	if (_element != undefined) {
		element = _element;
		with element {
			InterfaceMouseApply();
		}
	}
	
	selected = false;
	
	event_selected = GetDelegate(self);
	event_deselected = GetDelegate(self);
	
	static is_selected = function() {
		return selected;
	}
	static select = function() {
		global_deselect();
		
		selected = true;
		global_selected = self;
		event_selected.call();
	}
	static deselect = function() {
		if (!selected)
			return;
			
		selected = false;
		if (global_selected == self) {
			global_selected = undefined;
		}
		event_deselected.call();
	}
}
new InterfaceControlComponent(undefined);