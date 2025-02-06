// Sequence element types
enum eELEMENT_TYPE { 
    SPRITE      		= 1, 
    SOUND       		= 2, 
    GENERAL     		= 3, 
    BLEND       		= 4, 
    SEQUENCE    		= 7, 
    CLIPMASK			= 8,
    CLIPMASK_MASK		= 9,
    CLIPMASK_SUBJECT	= 10,
	GROUP				= 11,
    TEXT        		= 17, 
    PARTICLE    		= 18 
}

/// @returns {SequenceTextEffectsNames}
function GetSequenceTextEffectsNames() {
	static inst = new SequenceTextEffectsNames();
	return inst;
}
function SequenceTextEffectsNames() constructor {
	thickness = "texteffect_thickness";
	hash_thickness = variable_get_hash(thickness);
	
	shadowSoftness = "textEffect_shadowSoftness";
	hash_shadowSoftness = variable_get_hash(shadowSoftness);
	
	shadowOffset = "textEffect_shadowOffset";
	hash_shadowOffset = variable_get_hash(shadowOffset);
	
	shadowColour = "textEffect_shadowColour";
	hash_shadowColour = variable_get_hash(shadowColour);
	
	shadowAlpha = "textEffect_shadowAlpha";
	hash_shadowAlpha = variable_get_hash(shadowAlpha);
	
	outlineDist = "texteffect_outlineDist";
	hash_outlineDist = variable_get_hash(outlineDist);
	
	outlineColour = "texteffect_outlineColour";
	hash_outlineColour = variable_get_hash(outlineColour);
	
	outlineAlpha = "texteffect_outlineAlpha";
	hash_outlineAlpha = variable_get_hash(outlineAlpha);
	
	glowStart = "texteffect_glowStart";
	hash_glowStart = variable_get_hash(glowStart);
	
	glowEnd = "texteffect_glowEnd";
	hash_glowEnd = variable_get_hash(glowEnd);
	
	glowColour = "texteffect_glowColour";
	hash_glowColour = variable_get_hash(glowColour);
	
	glowAlpha = "texteffect_glowAlpha";
	hash_glowAlpha = variable_get_hash(glowAlpha);
	
	coreColour = "texteffect_coreColour";
	hash_coreColour = variable_get_hash(coreColour);
	
	coreAlpha = "texteffect_coreAlpha";
	hash_coreAlpha = variable_get_hash(coreAlpha);
	
	paragraphSpacing = "paragraphSpacing";
	hash_paragraphSpacing = variable_get_hash(paragraphSpacing);
	
	lineSpacing = "lineSpacing";
	hash_lineSpacing = variable_get_hash(lineSpacing);
	
	characterSpacing = "characterSpacing";
	hash_characterSpacing = variable_get_hash(characterSpacing);
	
	hashes = [
		hash_characterSpacing,
		hash_coreAlpha,
		hash_coreColour,
		hash_glowAlpha,
		hash_glowColour,
		hash_glowStart,
		hash_glowEnd,
		hash_lineSpacing,
		hash_outlineAlpha,
		hash_outlineColour,
		hash_outlineDist,
		hash_paragraphSpacing,
		hash_shadowAlpha,
		hash_shadowColour,
		hash_shadowOffset,
		hash_shadowSoftness,
		hash_thickness
	]
	default_values = {}
	struct_set_from_hash(default_values, hash_characterSpacing, 0);
    struct_set_from_hash(default_values, hash_coreAlpha, 1);
    struct_set_from_hash(default_values, hash_coreColour, c_white);
    struct_set_from_hash(default_values, hash_glowAlpha, 1);
    struct_set_from_hash(default_values, hash_glowColour, c_white);
    struct_set_from_hash(default_values, hash_glowStart, 0);
    struct_set_from_hash(default_values, hash_glowEnd, 0);
    struct_set_from_hash(default_values, hash_lineSpacing, 0);
    struct_set_from_hash(default_values, hash_outlineAlpha, 1);
    struct_set_from_hash(default_values, hash_outlineColour, c_black);
    struct_set_from_hash(default_values, hash_outlineDist, 0);
    struct_set_from_hash(default_values, hash_paragraphSpacing, 0);
    struct_set_from_hash(default_values, hash_shadowAlpha, 1);
    struct_set_from_hash(default_values, hash_shadowColour, c_black);
    struct_set_from_hash(default_values, hash_shadowOffset, new Point(0, 0));
    struct_set_from_hash(default_values, hash_shadowSoftness, 0);
    struct_set_from_hash(default_values, hash_thickness, 0);
	
	equals = function(obj1, obj2) {
		for(var i = array_length(hashes) - 1; i >= 0; i--) {
			var hash = hashes[i];
			var value0 = struct_get_from_hash(obj1, hash);
			var value1 = struct_get_from_hash(obj2, hash);
			
			if (is_struct(value0)) {
				if (!value0.equals(value1)) {
					return false;
				}
			} else {
				if (value0 != value1) {
					return false;
				}
			}
		}
		
		return true;
	}
	
	set_default = function(obj) {
		copy(default_values, obj);
	}
	
	copy = function(obj_source, obj_destination) {
		for(var i = array_length(hashes) - 1; i >= 0; i--) {
			var hash = hashes[i];
			var source_value = struct_get_from_hash(obj_source, hash);
			
			if (is_struct(source_value)) {
				var value_dest = struct_get_from_hash(obj_destination, hash);
				if (value_dest == undefined) {
					struct_set_from_hash(obj_destination, hash, source_value.clone());
				} else {
					value_dest.copy(source_value);
				}
				continue;
			}
			
			struct_set_from_hash(obj_destination, hash, source_value);
		}
	}
}

function SequenceParser(_sequence, options=undefined) constructor {
	animator = /*#cast*/ undefined; /// @is {SequenceParserAnimator}
	
	autoplay = false;
	head_old = -1;
	
    elements = []; /// @is {array<SequenceElement>}
    root = /*#cast*/ undefined; /// @is {SequenceElement}
    sequence    = _sequence;
    frame = 0;
    length = 0;
    messages = {};	/// @is {struct<SequenceMessage>}
    messages_list = []; /// @is {array<SequenceMessage>}
    
    smooth_animation = true;
    
    size_calculated = false;
    size = new Point(0);
    anchor = new Point(0);
    origin = new Point(0);
    geometry = /*#cast*/ undefined; /// @is {SequenceElementGeometry}
    
    geometry_calculate = false;
    fast = false;
    
    text_effects = GetSequenceTextEffectsNames(); /// @is {SequenceTextEffectsNames}
    
    on_frame_changed = new Delegate(self);
    
    static width = function() {
    	return size.x;
    }
    static height = function() {
    	return size.y;
    }
    static get_size = function() {
    	// return new Point(width(), height());
    	return size;
    }
    
    static init=function(options)/*=>*/{
    	if (options != undefined)
    		forced_struct_apply(self, options);
        
        size_calculated = false;
        
        var timer = get_timer();
        
        var sequence_inst;
        if (typeof(sequence) != "struct") {
			sequence_inst = sequence_get(sequence);
        } else {
        	sequence_inst = sequence;
        }
		speed = sequence_inst.playbackSpeed / room_speed;
		length = sequence_inst.length - 1;
        parse_all(sequence_inst);
        initialize_frame();
        	
        calculate_size();
		root.size = size;
		root.origin = origin;
		root.origin_summary = origin.clone();
        	
        init_other();
    }
    static init_other = function() /*=>*/ {
    	if (geometry_calculate)
    		init_geometry();
    		
    	if (autoplay) {
    		play();
    	}
    }
    static init_geometry = function() /*=>*/ {
		geometry = new SequenceElementGeometry(root);
		geometry.calculate();
	}
	static calculate_size = function() /*=>*/ {
		if (size_calculated)
			return;
			
		var bbox = root.get_bbox();
		size.x = bbox.width();
		size.y = bbox.height();
		origin.x = -bbox.left;
		origin.y = -bbox.top;
		
		size_calculated = true;
	}
    
    static parse_all = function(sequence_struct) /*=>*/ {
		root = new SequenceElement(self);
		
		parse_messages(sequence_struct.messageEventKeyframes);
		
    	for(var i = 0; i < array_length(sequence_struct.tracks); i++) {
        	parse(root, sequence_struct.tracks[i]);
        }
    }
    static parse = function(element_parent/*:SequenceElement*/, element_to_parse/*:struct*/)/*=>*/{
        var to_parse = [];
        
        var element_type = get_element_type(element_to_parse);
        var parsed/*:SequenceElement*/ = new element_type(self); 
		//show_debug_message(element_to_parse.name);
        for( var i = 0; i < array_length(element_to_parse.tracks); i++ ){
            var track = element_to_parse.tracks[i];
            switch(track.type){
                case eELEMENT_TYPE.BLEND: 
                	switch (track.name) {
                		case "blend_multiply": insert_color_data(parsed, "color", "alpha", track); break;
                		case text_effects.shadowColour: insert_color_data(parsed, text_effects.shadowColour, text_effects.shadowAlpha, track); break;
                		case text_effects.coreColour: insert_color_data(parsed, text_effects.coreColour, text_effects.coreAlpha, track); break;
                		case text_effects.glowColour: insert_color_data(parsed, text_effects.glowColour, text_effects.glowAlpha, track); break;
                		case text_effects.outlineColour: insert_color_data(parsed, text_effects.outlineColour, text_effects.outlineAlpha, track); break;
                	}
                	break;
                case eELEMENT_TYPE.GENERAL:
                    switch (track.name) {
                        case "frameSize": insert_point_data(parsed, "frame_size", track); break;
                        case "image_index": insert_number_data(parsed, "frame", track); break;
                        case "position": insert_point_data(parsed, "position", track); break;
                        case "rotation": insert_number_data(parsed, "angle", track); break;
                        case "scale": insert_point_data(parsed, "scale", track); break;
                        case "origin": insert_point_data(parsed, "origin", track); break;
                    	case text_effects.thickness: insert_number_data(parsed, text_effects.thickness, track); break;
                        case text_effects.shadowSoftness: insert_number_data(parsed, text_effects.shadowSoftness, track); break;
                        case text_effects.shadowOffset: insert_point_data(parsed, text_effects.shadowOffset, track); break;
                        case text_effects.outlineDist: insert_number_data(parsed, text_effects.outlineDist, track); break;
                        case text_effects.glowStart: insert_number_data(parsed, text_effects.glowStart, track); break;
                        case text_effects.glowEnd: insert_number_data(parsed, text_effects.glowEnd, track); break;
                        case text_effects.paragraphSpacing: insert_number_data(parsed, text_effects.paragraphSpacing, track); break;
                        case text_effects.lineSpacing: insert_number_data(parsed, text_effects.lineSpacing, track); break;
                        case text_effects.characterSpacing: insert_number_data(parsed, text_effects.characterSpacing, track); break;
                    }
                    break;
                default:
                	array_push(to_parse, track);
            }
        }
        
        for( var i = 0; i < array_length(element_to_parse.keyframes); i++) {
        	var keyframe = element_to_parse.keyframes[i];
        	array_push(parsed.frames.keyframes, {
        		frame: keyframe.frame,
        		length: keyframe.length
        	})
        }
        
        parsed.extract(element_to_parse);
        
        var callback = parse_callback(element_parent, parsed);
        if (callback < 0)
        	return;
        	
		array_push(elements, parsed);
        element_parent.add(parsed);
        
        switch (element_to_parse.type) {
        	case eELEMENT_TYPE.SPRITE:
        		if (parsed.parent.class == "clipmask_mask") {
					parsed.visible = false;
        		}
        		break;
        	case eELEMENT_TYPE.CLIPMASK_MASK:
        		(/*#cast*/ parsed.parent /*#as SequenceClipmask*/).mask = /*#cast*/ parsed /*#as SequenceClipmaskMask*/;
        		break;
        	case eELEMENT_TYPE.CLIPMASK_SUBJECT:
        		(/*#cast*/ parsed.parent /*#as SequenceClipmask*/).subject = /*#cast*/ parsed /*#as SequenceClipmaskSubject*/;
        		break;
        }
        
        for ( var i = 0; i < array_length(to_parse); i++ ) {
            parse(parsed, to_parse[i]);
        }
    }
    static parse_callback = function(element_parent/*:SequenceElement*/, parsed/*:SequenceElement*/) {
    	if (parsed.name == "#SIZE#") {
    		parsed.set_frame(0);
    		
    		size = new Point(parsed.size.x * parsed.scale.x, parsed.size.y * parsed.scale.y);
    		origin = new Point(-parsed.get_left(), -parsed.get_top());
    		anchor = new Point(parsed.origin_summary.x, parsed.origin_summary.y);
    		size_calculated = true;
    		
    		return -1; // do not add to parsed data
    	}
    	if (parsed.name == "#ANCHOR#") {
    		parsed.set_frame(0);
    		
    		anchor = new Point(-parsed.get_left(), -parsed.get_top());
    		
    		return -1; // do not add to parsed data
    	}
    	if (string_char_at(parsed.name, 1) == ".") {
    		parsed.set_frame(0);
    		element_parent.property_add(string_delete(parsed.name, 1, 1), parsed);
    		return -1;
    	}
    	return 0; // continue
    }
    static parse_messages = function(_messages/*:Keyframe<seqtracktype_message>[]*/) {
		for (var i = 0, length = array_length(_messages); i < length; i++) {
			var _message = _messages[i];
			var _message_name = _message.channels[0].events[0];
			
			messages[$ _message_name] = new SequenceMessage(
	    		_message_name,
	    		_message.frame
	    	);
	    	array_push(messages_list, messages[$ _message_name]);
		}
    }
    static get_type =function(etype)/*=>*/{
        var type = SequenceElement;
        switch(etype){
			case eELEMENT_TYPE.GROUP:	  type = SequenceElement; break;
            case eELEMENT_TYPE.SPRITE:    type = SequenceSprite; break;
            case eELEMENT_TYPE.TEXT:      type = SequenceText; break;
            case eELEMENT_TYPE.SEQUENCE:  type = SequenceSequence; break;
        }
        return type;
    }
    static frame_is_curve = function(frame) /*=>*/ {
    	return frame.channels[0].curve != -1;
    }
    
    static insert_color_data = function(parsed, color_name, alpha_name, track, once=true) {
    	if (once && parsed.frames.parameter_get(color_name) != undefined)
    		return;
    		
    	for(var t = 0; t < array_length(track.keyframes); t++) {
        	var frame = track.keyframes[t];
            
        	parsed.frames.insert(frame.frame, color_name, get_frame_color(frame), "color");
        	parsed.frames.insert(frame.frame, alpha_name, get_frame_alpha(frame));
        }
    }
    static get_frame_color = function(keyframe) {
		var data = keyframe.channels[0].color;
		return make_colour_rgb(data[1]*255, data[2]*255, data[3]*255);
	}
	static get_frame_alpha = function(keyframe) {
		var data = keyframe.channels[0].color;
		return data[0];
	}
	
    static insert_point_data = function(parsed/*:SequenceElement*/, name, track, once=true) {
    	if (once && parsed.frames.parameter_get(name) != undefined)
    		return;
    		
    	for(var t = 0; t < array_length(track.keyframes); t++) {
        	var frame = track.keyframes[t];
        	if (frame_is_curve(frame))
        		parsed.frames.assign_curve(name, new Point(frame.channels[0].curve.channels[0], frame.channels[0].curve.channels[1]), frame.length);
        	else {
        		//show_debug_message(track)
        		parsed.frames.insert(frame.frame, name, new Point(get_channel_value(frame.channels, 0), get_channel_value(frame.channels, 1)));
        	}
        }
    }
    static insert_number_data = function(parsed, name, track, once=true) {
    	if (once && parsed.frames.parameter_get(name) != undefined)
    		return;
    		
    	for(var t = 0; t < array_length(track.keyframes); t++) {
        	var frame = track.keyframes[t];
        	if (frame_is_curve(frame))
        		parsed.frames.assign_curve(name, frame.channels[0].curve.channels[0], frame.length);
        	else
        		parsed.frames.insert(frame.frame, name, get_channel_value(frame.channels, 0));
        }
    }
    
    static get_channels =function(track)/*=>*/{
        var channels    = track.keyframes[0].channels;
        var curve       = -1;
        var values      = [];
        for ( var c=0; c<array_length(channels); c++ ){
        	values[c] = get_channel_value(channels, c);
	    }
	    return {
            curve: curve,
            value: values
        }
    }
    static get_channel_value = function(channels, index, posx=0) {
    	var channel = channels[index],
    		curve = channel.curve;
    	return curve == -1 ? channel.value : animcurve_channel_evaluate(animcurve_get_channel(curve, index), posx);
    }
    static get_element_type = function(element) /*=>*/ {
    	switch (element.type) {
    		case eELEMENT_TYPE.GROUP: return SequenceGroup;
    		case eELEMENT_TYPE.SPRITE: return SequenceSprite;
    		case eELEMENT_TYPE.TEXT: return SequenceText;
    		case eELEMENT_TYPE.SEQUENCE: return SequenceSequence;
    		case eELEMENT_TYPE.CLIPMASK: return SequenceClipmask;
    		case eELEMENT_TYPE.CLIPMASK_MASK: return SequenceClipmaskMask;
    		case eELEMENT_TYPE.CLIPMASK_SUBJECT: return SequenceClipmaskSubject;
    		case eELEMENT_TYPE.PARTICLE: return SequenceParticle;
    		case eELEMENT_TYPE.SOUND: return SequenceSound;
    		default: 
    			if (Build.is_debug) {
    				show_debug_message("Cannot get sequence element type of " + string(element.type) + "!");
    				show_debug_message(json_stringify(element));
    			}
    			return SequenceElement;
    	}
    }
	
	static get_message_frame = function(message_text) /*=>*/ {
		var func = method({message_text}, function(msg/*:SequenceMessage*/, i/*:number*/)/*->bool*/ {
			return msg.message == message_text;
		});
		
		var index = array_find_index(messages_list, func);
		
		if (index == -1) {
			return -1;
		}
		
		return messages_list[index].frame;
	}
	
	#region animator
	static play = function() /*=>*/ {
		make_sure_animator_exists();
		
		animator.play();
	}
	static set_direction = function(_dir) /*=>*/ {
		make_sure_animator_exists();
		
		animator.set_direction(_dir);
	}
	static set_head = function(_head) /*=>*/ {
		make_sure_animator_exists();
		
		animator.set_head(_head);
	}
	static stop = function() /*=>*/ {
		make_sure_animator_exists();
		
		animator.stop();
	}
	static update = function() /*=>*/ {
		if (animator_is_exists())
			animator.update();
	}
	static animator_is_exists = function() /*=>*/ {
		return animator != undefined;
	}
	static make_sure_animator_exists = function() /*=>*/ {
		Main.logger.internal.warning(["SequenceParse going to loose IPlayable interface! Please remove any IPlayable calls to SequenceParse and use SequenceParseAnimator instead!", debug_get_callstack(2)[1]]);
		
		if (animator == undefined) {
			animator = create(SequenceParserAnimator);
			animator.set_parser(self);
			animator.on_return.add(function() /*=>*/ {on_return.call(0); });
		}
	}
	#endregion
	
	static initialize_frame = function() /*=>*/ {
		set_frame(frame);
	}
	static set_frame = function(frame) /*=>*/ {
		self.frame = frame;
		self.head = frame;
		
		//for(var i = array_length(elements) - 1; i >= 0 ; i--)
		//	elements[i].set_frame(frame, false);
		root.set_frame_recursively(frame);
		on_frame_changed.call(self);
	}

	static get = function(name)/*->SequenceElement?*/ {
		return root.get(name);
	}
	
	static cleanup = function() {
		root.cleanup();
		if (geometry != undefined)
			geometry.cleanup();
		elements = [];
	}

    init(options);
}

function SequenceElement(_parser) constructor {

    parser = _parser; /// @is {SequenceParser}
    class = "element";
    name = "Sequence element";
    
	parent  	= /*#cast*/ undefined; /// @is {SequenceElement}
    elements = []; /// @is {array<SequenceElement>}
    properties = {}; /// @is {struct<SequenceElement>}
	
	position = new Point(0);
	origin = new Point(0);
	origin_summary = new Point(0);
	size = new Point(0);
	scale = new Point(1);
	angle = 0;
	color = c_white;
	alpha = 1;
	visible = true;
	
	bbox = /*#cast*/ undefined; /// @is {Box}
	bbox_parent_state = {scale: undefined, position: undefined};
	
    frames = new SequenceFrames(); /// @is {SequenceFrames}
    active = true;
    current_frame = -1;
    animation_is_isolated = false;

	dirty = true;
    on_changed = new Delegate();
    
    static point_ones = new Point(1);
    static point_zeros = new Point(0);

	property_get_particle = function(name)/*->SequenceParticle*/ {
		return /*#cast*/ property_get(name, "particle");
	}
	property_get_sprite = function(name)/*->SequenceSprite*/ {
		return /*#cast*/ property_get(name, "sprite");
	}
	property_get_text = function(name)/*->SequenceText*/ {
		return /*#cast*/ property_get(name, "text");
	}
	property_get = function(name, class = undefined)/*->SequenceElement*/ {
		var prop = properties[$ name];
		if (prop != undefined) {
			if (prop.class != class && class != undefined)
				return /*#cast*/ undefined;
		}
		return prop;
	}
	property_add = function(name, element) /*=>*/ {
		properties[$ name] = element;
	}
	
    add = function(add_element/*:SequenceElement*/) /*=>*/ {
    	add_element.parent = self;
    	array_push(elements, add_element);
    }
    children_free = function() /*=>*/ {
		elements = [];
		parent = /*#cast*/ undefined;
	}
	
    extract = function(element) { 
    	name = element.name; 
    	visible = element.visible;
    	
    	extract_extra(element);
    }
    extract_extra = function(element) /*=>*/ {}
    
    equals = function(element/*:SequenceElement*/) /*=>*/ {
    	return element.name == name &&
    		element.position.equals(position) &&
    		element.origin.equals(origin) &&
    		element.size.equals(size) &&
    		element.scale.equals(scale) &&
    		element.angle == angle &&
    		element.color == color &&
    		element.alpha == alpha &&
    		element.visible == visible;
    }
    set_frame_recursively = function(frame, force=true) /*=>*/ {
    	if (animation_is_isolated && !force)
    		return;
    		
    	for(var i = 0; i < array_length(elements); i++) {
    		elements[i].set_frame_recursively(frame, false);
    	}
    	
    	set_frame(frame, force)
    }
    set_frame = function(frame/*:real*/, force/*:bool*/=true) /*=>*/ {
    	if (animation_is_isolated && !force)
    		return;
    		
    	current_frame = frame;
    		
    	if (frames == undefined)
    		return;
    		
		var is_changed = frames.accept(self, frame, parser.smooth_animation);
		if (is_changed) {
			origin_summary.x = origin.x;
			origin_summary.y = origin.y;
			apply_callback();
			
			if (!parser.fast) {
				set_dirty();
				on_changed.call(self);
			}
		}
    }
    apply	= function(data/*:struct*/ = {}) {
    	forced_struct_apply(self, data);
        origin_summary.x = origin.x;
        origin_summary.y = origin.y;
        
        set_dirty();
        
        apply_callback();
        
        on_changed.call(self);
    }
    apply_callback = function() /*=>*/ {}
    set_dirty = function() /*=>*/ {
    	if (dirty)
    		return;
    		
    	dirty = true;
    	if (parent != undefined)
    		parent.set_dirty();
    }
    
    get_total_scale = function() /*=>*/ {
    	var scale = new Point(1, 1);
    	var next_parent = parent;
    	while (next_parent != undefined) {
    		scale.x *= next_parent.scale.x;
    		scale.y *= next_parent.scale.y;
    		next_parent = next_parent.parent;
    	}
    	return scale;
    }
    get_total_position = function() /*=>*/ {
    	var position = new Point(0, 0);
    	var scale = new Point(1, 1);
    	var next_parent = parent;
    	
    	var parent_queue = [];
    	
    	while (next_parent != undefined) {
    		array_insert(parent_queue, 0, next_parent);
    		next_parent = next_parent.parent;
    	}
    	for(var i = 0; i < array_length(parent_queue); i++) {
    		var next_parent = parent_queue[i];
    		position.x += next_parent.position.x * scale.x;
    		position.y += next_parent.position.y * scale.y;
    		
    		scale.x *= next_parent.scale.x;
    		scale.y *= next_parent.scale.y;
    	}
    	return position;
    }
    get_total_angle = function() /*=>*/ {
    	var angle = self.angle;
    	var _parent = parent;
    	while (_parent != undefined) {
    		angle += _parent.angle;
    		_parent = _parent.parent;
    	}
    	return angle;
    }
    
    get_top = function(parent_scale/*:Point*/=point_ones, parent_position/*:Point*/=point_zeros) /*=>*/ {return (position.y - origin_summary.y * scale.y) * parent_scale.y + parent_position.y};
    get_bottom = function(parent_scale/*:Point*/=point_ones, parent_position/*:Point*/=point_zeros) /*=>*/ {return get_top(parent_scale, parent_position) + size.y * scale.y * parent_scale.y};
    get_left = function(parent_scale/*:Point*/=point_ones, parent_position/*:Point*/=point_zeros) /*=>*/ {return (position.x - origin_summary.x * scale.x) * parent_scale.x + parent_position.x};
    get_right = function(parent_scale/*:Point*/=point_ones, parent_position/*:Point*/=point_zeros) /*=>*/ {return get_left(parent_scale, parent_position) + size.x * scale.x * parent_scale.x};
    
    get_box = function(parent_scale/*:Point*/=point_ones, parent_position/*:Point*/=point_zeros) /*=>*/ {return new Box(get_left(parent_scale, parent_position), get_top(parent_scale, parent_position), get_right(parent_scale, parent_position), get_bottom(parent_scale, parent_position))};
    get_bbox = function(parent_scale=undefined, parent_position=undefined)/*->Box*/ {
    	if (parent_scale == undefined)
    		parent_scale = get_total_scale();
    	if (parent_position == undefined)
    		parent_position = get_total_position();
    	
    	if (!dirty && bbox != undefined) {
    		if (parent_scale.equals(bbox_parent_state.scale) && parent_position.equals(bbox_parent_state.position))
    			return bbox;
    	}
    		
    	dirty = false;
    	
    	bbox = get_box(parent_scale, parent_position);
    	bbox_parent_state = {scale: parent_scale, position: parent_position};
    		
    	var total_scale = new Point(parent_scale.x * scale.x, parent_scale.y * scale.y);
    	var total_position = new Point(parent_position.x + position.x * parent_scale.x, parent_position.y + position.y * parent_scale.y);
    		
    	for(var i = 0; i < array_length(elements); i++) {
    		var child_bbox/*:Box*/ = elements[i].get_bbox(total_scale, total_position);
    		
    		bbox.left = min(child_bbox.left, bbox.left);
    		bbox.top = min(child_bbox.top, bbox.top);
    		bbox.right = max(child_bbox.right, bbox.right);
    		bbox.bottom = max(child_bbox.bottom, bbox.bottom);
    	}
    	
    	return bbox;
    }
	
	get = function(name)/*->SequenceElement?*/ {
		for(var i = 0; i < array_length(elements); i++) {
			if (elements[i].name == name)
				return elements[i];
			
			var find_answer = elements[i].get(name);
			if (find_answer != undefined)
				return find_answer;
		}
		return undefined;
	}
	
	info = function() /*=>*/ {
		return {
			name: name,
			position: position,
			origin: origin,
			size: size,
			scale: scale,
			angle: angle,
			color: color,
			alpha: alpha,
			visible: visible
		}
	}

	cleanup = function() /*=>*/ {
		for(var i = 0; i < array_length(elements); i++) {
			elements[i].cleanup();
		}
		children_free();
		
		delete frames;
	}
}
function SequenceGroup(_parser) : SequenceElement(_parser) constructor {
    class = "group";
    
    size_calculated = false;
    calculate_dimensions_enable = !parser.fast;
    
    apply_callback = function() /*=>*/ {
    	if (calculate_dimensions_enable)
    		calculate_dimensions();
    }
  	
    calculate_dimensions = function() /*=>*/ {
    	
    	if (!size_calculated) {
    		get_bbox();
	    	size.x = bbox.width();
	    	size.y = bbox.height();
	    	size_calculated = true;
    	}
	    	
    	origin_summary.x -= (bbox.left - position.x);
    	origin_summary.y -= (bbox.top - position.y);
    }
}
function SequenceClipmask(_parser) : SequenceGroup(_parser) constructor {
	class = "clipmask";
	
	mask = undefined;	/// @is {SequenceClipmaskMask?}
	subject = undefined;	/// @is {SequenceClipmaskSubject?}
}
function SequenceClipmaskMask(_parser) : SequenceGroup(_parser) constructor {
	class = "clipmask_mask";
}
function SequenceClipmaskSubject(_parser) : SequenceGroup(_parser) constructor {
	class = "clipmask_subject";
}
function SequenceText(_parser) : SequenceElement(_parser) constructor {
    
    class		= "text";
    text		= "";
    halign      = fa_left;
    valign      = fa_top;
    font        = /*#cast*/ -1 /*#as font*/;
    frame_size  = new Point(0, 0);
    text_dirty	= true;
    wrap		= false;
    scribble_uuid = "";
    
    font_scale = 0.5;
    
    replace_color_with_core_color = false;
    
    static text_effects = GetSequenceTextEffectsNames(); /// @is {SequenceTextEffectsNames}
    effects_previous = {};
    text_effects.set_default(self);
    text_effects.set_default(effects_previous);
    
    size_is_dynamic = true;
    
    extract_extra =function(element)/*=>*/{
        var keyframes  = element.keyframes[0].channels[0];
        for(var i = 0; i < array_length(element.keyframes); i++) {
        	var frame = element.keyframes[i].frame;
        	var channel = element.keyframes[i].channels[0];
        	text = channel.text;
        	halign = channel.alignmentH;
        	valign = channel.alignmentV;
        	font = channel.fontIndex;
        	wrap = channel.wrap;
        }
        
        replace_color_with_core_color = frames.parameter_get(text_effects.coreColour) != undefined;
        scribble_uuid = "SequenceText_" + name + "_" + string(irandom(999999));
    }
    
    apply_callback = function() /*=>*/ {
    	if (!parser.fast) {
	    	if (!text_effects.equals(self, effects_previous)) {
	    		text_dirty = true;
	    		text_effects.copy(self, effects_previous);
	    	}
	    	if (!size.equals(frame_size)) {
	    		text_dirty = true;
	    	}
    	}
    	size.set_point(frame_size);
    	
    	if (replace_color_with_core_color) {
    		color = struct_get_from_hash(self, text_effects.hash_coreColour);
    		alpha = struct_get_from_hash(self, text_effects.hash_coreAlpha);
    	}
    }
    
    set_text = function(_text/*:string*/ = text, _halign/*:horizontal_alignment*/ = halign, _valign/*:vertical_alignment*/ = valign, _font/*:font*/ = font) {
    	text = _text;
    	halign = _halign;
    	valign = _valign;
    	font = _font;
    	
    	text_dirty = true;
    }

	build_scribble = function(_font_scale = undefined) /*=>*/ {
		
		if (_font_scale != undefined)
			font_scale = _font_scale;
		
		var uid = scribble_uuid;
		var scribble_font = scribble_font_parse(font);
		var localized_font = LocalizationCollectionGet().get_font_variant(scribble_font);
		var scribble_instance = scribble("[scale," + string(font_scale) + "][" + font_get_name(localized_font) + "]" + text, uid)
			.starting_format(font_get_name(localized_font), color)
			.align(halign , valign)
			.transform(scale.x, scale.y)
			.blend(c_white, alpha);
			
		if (wrap)
			scribble_instance = scribble_instance.wrap(frame_size.x, -1, false);
			
		text_dirty = false;
			
		return scribble_instance;
	}
	
	shadow_is_enabled = function() /*=>*/ {
		 var offset = shadow_get_offset();
		 return (offset.x != 0 && offset.y != 0) || (shadow_get_softness() > 0);
	}
	shadow_get_offset = function()/*->Point*/ {
		return struct_get_from_hash(self, text_effects.hash_shadowOffset);
	}
	shadow_get_color = function() {
		return struct_get_from_hash(self, text_effects.hash_shadowColour);
	}
	shadow_get_alpha = function() {
		return struct_get_from_hash(self, text_effects.hash_shadowAlpha);
	}
	shadow_get_softness = function() {
		return struct_get_from_hash(self, text_effects.hash_shadowSoftness);
	}
	
	outline_is_enabled = function() /*=>*/ {
		return outline_get_distance() > 0;
	}
	outline_get_distance = function() {
		return struct_get_from_hash(self, text_effects.hash_outlineDist);
	}
	outline_get_color = function() {
		return struct_get_from_hash(self, text_effects.hash_outlineColour);
	}
	outline_get_alpha = function() {
		return struct_get_from_hash(self, text_effects.hash_outlineAlpha);
	}
}
function SequenceSequence(_parser) : SequenceElement(_parser) constructor {
    
    class = "sequence";
    sequence = /*#cast*/ undefined; /// @is {SequenceParser}
    
    set_frame_recursively = function(frame, force=true) /*=>*/ {
    	if (animation_is_isolated && !force)
    		return;
    		
    	sequence.set_frame(frame mod sequence.length);
    	set_frame(frame, force)
    }
    
    extract_extra = function(element) /*=>*/ {
        sequence = create(new SequenceParser(element.keyframes[0].channels[0].sequence));

        var elements_to_add = sequence.root.elements;
        for ( var i = 0; i < array_length(elements_to_add); i++ ){
            add(elements_to_add[i]);
        }
    	size = sequence.size;
    }
    apply_callback = function() /*=>*/ {
    	origin_summary.x = origin.x + sequence.origin.x;
    	origin_summary.y = origin.y + sequence.origin.y;
    }
} 
function SequenceSprite(_parser) : SequenceElement(_parser) constructor {

	class = "sprite";
	sprite = noone;
    frame = 0;
    start_frame = 0;
	
    extract_extra = function(element) /*=>*/ {
    	var keyframes  = element.keyframes[0].channels[0];
        for(var i = 0; i < array_length(element.keyframes); i++) {
        	start_frame = element.keyframes[i].frame;
        	var channel = element.keyframes[i].channels[0];
        	sprite = channel.spriteIndex;
        }
        
        size.x = sprite_get_width(sprite);
        size.y = sprite_get_height(sprite);
        
        origin_summary.x = origin.x + sprite_get_xoffset(sprite);
        origin_summary.y = origin.y + sprite_get_yoffset(sprite);
    }
	apply_callback = function() {
        origin_summary.x = origin.x + sprite_get_xoffset(sprite);
        origin_summary.y = origin.y + sprite_get_yoffset(sprite);
        
        
    }
    set_frame_root = set_frame;
    set_frame = function(_frame, force = false) /*=>*/ {
    	set_frame_root(_frame, force);
    	
    	if (sprite_get_number(sprite) > 1)
    	if (frames.parameter_get("frame") == undefined) {
        	frame = (current_frame - start_frame) * sprite_get_speed(sprite) / (parser.speed * room_speed);
        }
    }
}
function SequenceParticle(_parser) : SequenceElement(_parser) constructor {

	class = "particle";
	system = noone;
	
    extract_extra = function(element) /*=>*/ {
    	
    	size.x = 32;
    	size.y = 32;
    	
    	var keyframes  = element.keyframes[0].channels[0];
        system = keyframes.particleSystemIndex;
        if (system == undefined)
        	system = keyframes.objectIndex;
    }
}
function SequenceSound(_parser) : SequenceElement(_parser) constructor {

	class = "sound";
	sound = noone;
	
    extract_extra = function(element) /*=>*/ {
    	var keyframes  = element.keyframes[0].channels[0];
        sound = keyframes.soundIndex;
        
        audio_play_sound(sound, 0, 0);
    }
}

function SequenceFrame() constructor {
	data = {};
	active = true;
	
	hashes = [];
	
	add_hash = function(key) /*=>*/ {
		var hash_struct = {hash: variable_get_hash(key), key: key};
		array_push(hashes, hash_struct);
	}
	
	get_data = function() {
		var out = data;
		
		for(var i = 0; i < array_length(hashes); i++) {
			var hash = hashes[i], val = struct_get_from_hash(self, hash);
				
			struct_set_from_hash(data, hash, val);
		}
		return data;
	}
	apply_to = function(element) {
		if (element[$ "apply"] != undefined)
			return element.apply(get_data());
		
		for(var i = 0; i < array_length(hashes); i++) {
			var hash = hashes[i], val = struct_get_from_hash(self, hash);
				
			struct_set_from_hash(element, hash, val);
		}
	}
	
	add_hash("active");
}
function SequenceParameter(_name/*:string*/, _type="any") constructor {
	name = _name;
	type = _type;
	frames = [];
	is_static = false;
	hash = variable_get_hash(name);
	returned_point = /*#cast*/ undefined;
	
	is_curve = false;
	curve = /*#cast*/ undefined;
	length = 1;
	mix_point = new Point(1, 1);
	
	assign_curve = function(_curve, _length) {
		is_curve = true;
		is_static = false;
		
		curve = _curve;
		length = _length;
	}
	add		= function(frame/*:real*/, value/*:any*/) {
		frame = max(frame, 0);
		
		var struct = {
					frame: frame,
					value: value
				}
		
		for(var i = 0; i < array_length(frames); i++) {
			var frame_data = frames[i];
			
			if (frame_data.frame == frame) {
				return;
			}
			
			if (frame_data.frame > frame) {
				array_insert(frames, i, struct);
				is_static = array_length(frames) <= 1;
				return;
			}
		}
		array_push(frames, struct);
		
		is_static = array_length(frames) <= 1;
	} 
	get 	= function(frame/*:real*/, smooth=false)/*->any*/ {
		if (is_curve) {
			var posx = frame / length;
			if (is_struct(curve) && instanceof(curve) == "Point") {
				if (returned_point == undefined)
					returned_point = new Point(0, 0);
					
				returned_point.x = animcurve_channel_evaluate(curve.x, posx);
				returned_point.y = animcurve_channel_evaluate(curve.y, posx);
				
				return returned_point;
			}
			else {
				return animcurve_channel_evaluate(curve, posx);
			}
		}
		
		if (is_static) return frames[0].value;
		
		var frame_last = undefined;
		for(var i = 0; i < array_length(frames); i++) {
			var frame_data = frames[i];
			frame_last = frame_data;
			
			if (frame_data.frame == frame) {
				return frame_data.value;
			}
			
			if (frame_data.frame > frame) {
				if (i > 0) {
					var frame_previous = frames[i - 1];
					var frame_step = (frame - frame_previous.frame) / (frame_data.frame - frame_previous.frame);
					return mix(frame_previous.value, frame_data.value, smooth ? frame_step : 0);
				} else {
					return frame_data.value;
				}
			}
		}
		
		if (frame_last == undefined) 
			return undefined;
			
		return frame_last.value;
	}
	mix		= function(v0, v1, amount) {
		if (type == "color") {
			return merge_color(v0, v1, amount);
		}
		if (is_real(v0)) {
			return lerp(v0, v1, amount);
		}
		if (is_string(v0)) {
			return v0;
		}
		if (is_struct(v0) && instanceof(v0) == "Point") {
			if (returned_point == undefined)
				returned_point = new Point(0, 0);
			returned_point.x = lerp(v0.x, v1.x, amount);
			returned_point.y = lerp(v0.y, v1.y, amount);
			
			return returned_point;
		}
	}
}
function SequenceFrames() constructor {
	parent = other;
	parameters = [];
	
	first = -1;
	last = -1;
	
	keyframes = [];
	
	is_static = true;
	is_initiated = false;
	
	frame_data = new SequenceFrame();
	
	assign_curve = function(param/*:string*/, _curve/*:struct*/, _length/*:number*/) {
		if (first == -1) {
			first = 0;
			last = _length;
		}
		
		var parameter_interface/*:SequenceParameter*/ = parameter_get_or_create(param, "curve")
		parameter_interface.assign_curve(_curve, _length);
		is_static = false;
	}
	insert = function(frame/*:int*/, param/*:string*/, value/*:any*/, type/*:string*/="any") {
		if (first == -1) {
			first = frame;
			last = frame;
		} else {
			first = min(first, frame);
			last = max(last, frame);
		}
		
		var parameter_interface/*:SequenceParameter*/ = parameter_get_or_create(param, type)
		
		parameter_interface.add(frame, value);
		
		if (!parameter_interface.is_static)
			is_static = false;
	}
	parameter_get_or_create = function(param, type) {
		var parameter_interface/*:SequenceParameter*/ = parameter_get(param) /*#as SequenceParameter*/;
		if (parameter_interface == undefined) {
			parameter_interface = parameter_create(param, type);
		}
		return parameter_interface;
	}
	parameter_create = function(param, type) /*=>*/ {
		parameter_interface = new SequenceParameter(param, type);
		array_push(parameters, parameter_interface);
		
		frame_data.add_hash(param);
		
		return parameter_interface;
	}
	get_parameter = function(frame/*:real*/, param/*:string*/, smooth=false)/*->any*/ {
		var parameter_interface = parameter_get(param);
		if (parameter_interface == undefined)
			return undefined;
		return parameter_interface.get(frame, smooth);
	}
	accept = function(target/*:struct*/, frame/*:real*/, smooth/*:bool*/) {
		target.active = array_length(keyframes) == 0;
		
		var changed = false;
		
		if (!is_static || !is_initiated) {
			for(var i = 0; i < array_length(parameters); i++) {
				var parameter/*:SequenceParameter*/ = parameters[i];
				struct_set_from_hash(target, parameter.hash, parameter.get(frame, smooth));
			}
			is_initiated = true;
			changed = true;
		}
		
		if (!target.active)
		for(var i = 0; i < array_length(keyframes); i++) {
			var keyframe = keyframes[i];
			if (keyframe.frame <= frame && keyframe.frame + keyframe.length > frame) {
				target.active = true;
				break;
			}
		}
		
		return changed;
	}
	get = function(frame/*:real*/, smooth/*:bool*/=false)/*->SequenceFrame*/ {
		frame_data.active = array_length(keyframes) == 0;
		
		if (!is_static || !is_initiated) {
			for(var i = 0; i < array_length(parameters); i++) {
				var parameter/*:SequenceParameter*/ = parameters[i];
				
				struct_set_from_hash(frame_data, parameter.hash, parameter.get(frame, smooth));
			}
			is_initiated = true;
		}
		
		if (!frame_data.active)
		for(var i = 0; i < array_length(keyframes); i++) {
			var keyframe = keyframes[i];
			if (keyframe.frame <= frame && keyframe.frame + keyframe.length > frame) {
				frame_data.active = true;
				break;
			}
		}
		
		return frame_data
	}
	parameter_get = function(name)/*->SequenceParameter?*/ {
		for(var i = 0; i < array_length(parameters); i++) {
			if (parameters[i].name == name) return parameters[i];
		}
		return undefined;
	}
	length	= function() {
		if (first == -1) return 0;
		return last - first + 1;
	}
}

function SequenceElementGeometry(_element) constructor {
	element = _element; /// @is {SequenceElement}
	
	parent = /*#cast*/ undefined; /// @is {SequenceElementGeometry}
	children = []; /// @is {array<SequenceElementGeometry>}
	
	position = new Point(0);
	origin = new Point(0);
	size = new Point(0);
	scale = new Point(1, 1);
	angle = 0;
	
	bbox = new Box(0, 0, 0, 0);
	
	static init = function() /*=>*/ {
		if (element == undefined)
			return;
			
		for(var i = 0; i < array_length(element.elements); i++) {
			var new_geometry = new SequenceElementGeometry(element.elements[i]);
			add(new_geometry);
		}
	}
	static add = function(child) /*=>*/ {
		array_push(children, child);
		child.parent = self;
	}
	static children_free = function() /*=>*/ {
		children = [];
		parent = /*#cast*/ undefined;
	}
	
	static calculate = function() /*=>*/ {
		calculate_local();
		
		for(var i = 0; i < array_length(children); i++) {
			children[i].calculate();
		}
	}
	static calculate_local = function() /*=>*/ {
		static null_geometry = new SequenceElementGeometry(undefined);
		
		var parent_geometry = parent == undefined ? null_geometry : parent;
		
		angle = parent_geometry.angle + element.angle;
		
		scale.x = parent_geometry.scale.x * element.scale.x;
		scale.y = parent_geometry.scale.y * element.scale.y;
		
		position.x = parent_geometry.position.x + element.position.x * parent_geometry.scale.x;
		position.y = parent_geometry.position.y + element.position.y * parent_geometry.scale.y;
		
		origin.x = element.origin_summary.x * scale.x;
		origin.y = element.origin_summary.y * scale.y;
		
		size.x = element.size.x * scale.x;
		size.y = element.size.y * scale.y;
		
		bbox.left = position.x - origin.x;
		bbox.top = position.y - origin.y;
		bbox.right = bbox.left + size.x;
		bbox.bottom = bbox.top + size.y;
	}
	
	static get = function(name)/*->SequenceElementGeometry?*/ {
		for(var i = 0; i < array_length(children); i++) {
			if (children[i].element.name == name)
				return children[i];
			
			var find_answer = children[i].get(name);
			if (find_answer != undefined)
				return find_answer;
		}
		return undefined;
	}
	
	static cleanup = function() /*=>*/ {
		for(var i = 0; i < array_length(children); i++) {
			children[i].cleanup();
		}
		children_free();
	}
	
	init();
}

function SequenceMessage(_message/*:string*/, _frame/*:int*/) constructor {
	message = _message;
	frame = _frame;
}