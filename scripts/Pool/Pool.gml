
function Pool() constructor {
    list = ds_queue_create();
    
    pull_callback = function(_) {};
    add_callback = function(_) {};
    
    static add = function(element) {
        ds_queue_enqueue(list, element);
        add_callback(element);
    }
    static pull = function() {
        if (size() == 0) {
            return undefined;
        }
        
        var element = ds_queue_dequeue(list);
        
        pull_callback(element);
        return element;
    }
    static clear = function() {
        ds_queue_clear(list);
    }
    static size = function() {
        return ds_queue_size(list);
    }
}
