
function Pool() constructor {
    list = [];
    
    pull_callback = function(_) {};
    remove_callback = function(_) {};
    add_callback = function(_) {};
    
    static add = function(element) {
        array_push(list, element);
        add_callback(element);
    }
    static pull = function() {
        if (size() == 0) {
            return undefined;
        }
        
        var element = list[0];
        remove_by_index(0);
        
        pull_callback(element);
        return element;
    }
    static clear = function() {
        repeat (size()) {
            remove_by_index(0);
        }
    }
    static remove = function(element) {
        var ind = array_get_index(list, element);
        if (ind == -1) return;
        
        return remove_by_index(ind);
    }
    static remove_by_index = function(index) {
        if (index < 0 || index >= size())
            throw "index out of range in Pool.remove_by_index";
            
        var element = list[index];
        array_delete(list, index, 1);
        
        remove_callback(element);
    }
    static size = function() {
        return array_length(list);
    }
}
