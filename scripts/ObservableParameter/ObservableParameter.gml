

function IObservableProperty() {
	/// @interface {IObservableProperty}
	// / @hint IAsync extends IDestructable

	on_value_changed = new Delegate(/*#cast*/ self);
	get = function() {throw "not implemented"; }
	set = function(new_value, callable=false) {throw "not implemented"; }
}

/// @template T
/// @param {T} ?default_value
function ObservableParameter(_default = undefined) constructor {
	IObservableProperty(); /// @implements {IObservableProperty}
	
	default_value = _default;
	value = _default; /// @is {T}
	new_value_comparing_enabled = true;
	value_filter = function() {return true};
	value_filter_message = "";
	
	set_filter = function(filter_function, filter_message) /*=>*/ {
		value_filter = filter_function;
		value_filter_message = filter_message;
	}
	
	set_default_value = function(callable=true) /*=>*/ {
		set(default_value, callable);
	}
	
	/// @hint ObservableParameter<T>:get()->T
	get = function() {
		return value;
	}
	/// @hint ObservableParameter<T>:set(new_value:T, callable:bool=true)
	set = function(new_value, callable=true) {
		filter_value(new_value);
		
		if (value_equals(value, new_value) && new_value_comparing_enabled) return;
		var old_value = value;
		value = new_value;
		if (callable)
			on_value_changed.call(value, old_value, self);
	}
	value_equals = function(v1, v2) /*=>*/ {
		return v1 == v2;
	}
	/// @hint ObservableParameter<T>:set_from(new_value:IObservableProperty, callable:bool=true)
	set_from = function(new_value/*:IObservableProperty*/, callable/*:bool*/=true) {
		set(new_value.get(), callable);
	}
	
	filter_value = function(value) /*=>*/ {
		if (!value_filter(value)) {
			throw $"ObservableParameter invalid value: {value_filter_message}\n type:{typeof(value)}";
		}
	}
	
	
	toString = function() {
		return "[o:" + string(value) + "]";
	}
}

function UnconditionalObservableParameter(_default = undefined) : ObservableParameter(_default) constructor {
	new_value_comparing_enabled = false;
}