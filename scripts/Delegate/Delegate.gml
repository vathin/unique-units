function DelegateInvalidArgument() constructor {
    message = "The delegate only takes a function as an argument.";
}

function GetDelegatePool() {
    static pool = new Pool();
    return pool;
}

/// @returns {Struct.Delegate}
function GetDelegate(_context, to_add = undefined) {
    var pool = GetDelegatePool();
    
    var delegate_from_pool = pool.pull();
    if (delegate_from_pool == undefined) {
        return new Delegate(_context, to_add);
    }
    
    delegate_from_pool.apply_arguments(_context, to_add);
    
    return delegate_from_pool;
}
function ReleaseDelegate(delegate_instance) {
    var pool = GetDelegatePool();
    
    delegate_instance.free();
    
    pool.add(delegate_instance);
}

/// @function				Delegate()
/// @argument				{Struct} ?context - Scope at which functions will be executed.
/// @argument				{function} ?to_add - Function to add to the function list at construction.
/// @description			Container supporting multiple function executions at once.
/*  @example				var delegate = new Delegate()
*									.add(function() {})
*									.add(function() {})
*									.add(function() {}, true)
*									.call();
*/
function Delegate(_context, to_add) constructor {
    list = []; /// @is {array<function>} 
    sealed_context = undefined;
    cleared = false;
    
    static add = function(func, to_begin=false) {
        if (!is_method(func)) throw new DelegateInvalidArgument();
        
        if (to_begin)	array_push(list, func);
        else			array_insert(list, 0, func);
        
        return self;
    }
    static insert = function(func, index) {
        if (!is_method(func)) throw new DelegateInvalidArgument();
        
        array_insert(list, index, func);
        
        return self;
    }
    static replace = function(func, to_begin=false) {
        clear();
        add(func, to_begin);
        
        return self;
    }
    static set = replace;
    static size = function() {
        return array_length(list);
    }
    static remove = function(func) {
        var pos = array_get_index(list, func);
        if (pos != -1) array_delete(list, pos, 1);
        
        return self;
    }
    static clear = function() {
        array_delete(list, 0, array_length(list));
        cleared = true;
        
        return self;
    }
    call = function(arg0=undefined, arg1=undefined, arg2=undefined, arg3=undefined, arg4=undefined) {
        cleared = false;
        var out = undefined, result = undefined;
        for(var i = array_length(list) - 1; i >= 0; i--) {
            var f = list[i];
            with sealed_context {
                result = f(arg0, arg1, arg2, arg3, arg4);
            }
            if (result != undefined) out = result;
            
            if (cleared) break;
        }
        return out;
    }
    
    static free = function() {
        sealed_context = undefined;
        clear();
    }
    static apply_arguments = function(_context, to_add) {
        sealed_context = _context;
        if (to_add != undefined) {
            add(to_add);
        }
    }
    
    apply_arguments(_context, to_add);
}

