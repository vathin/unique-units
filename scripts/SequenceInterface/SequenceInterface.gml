function InterfaceSequence() : InterfaceBase() constructor {

	ID = "design";
	
	set_size("content", "content");
	
	static_sequence = false;
	sequence = /*#cast*/ undefined; /// @is {sequence}
	data = /*#cast*/ undefined; /// @is {SequenceParser}
	fabric = new UISequenceDesignFabric(self); /// @is {UISequenceDesignFabric}

	root = /*#cast*/ undefined; /// @is {UISequenceDesignInstance}
	frame = 0;
	
	handle_input_key = function(key, value) {
		if (key == "sequence") {
			set_sequence(value);
			return 1;
		}
		if (key == "aspect") {
			set_aspect(value);
			return 1;
		}
	}
	
	set_sequence = function(seq) {
		self.sequence = seq;
		
		data = new SequenceParser(seq);
		
		cleanup_sequence_elements();
		parse(data.root);
		sync_size();
	}
	cleanup_sequence_elements = function() /*=>*/ {
		fabric.element_cleanup_all();
	}
	is_sequence_element = function(ui/*:UIBox*/) /*=>*/ {
		return fabric.get_by_ui(ui) != undefined;
	}
	
	set_aspect = function(_orientation) {
		if (_orientation == orientation.hor) {
			set_h(WUNIT(data.height()/data.width()));
		} else {
			set_w(HUNIT(data.width()/data.height()));
		}
	}
	
	set_frame	= function(frame) {
		if (self.frame == frame) return;
		self.frame = frame;
		root.set_frame(frame);
	}
	
	parse = function(root_element/*:SequenceElement*/) {
		
		root = fabric.parse(root_element);
		for(var i = 0; i < array_length(root.childrens); i++) {
			add(root.childrens[i].ui);
		}
	}
	
	
	/// @returns {UISequenceDesignInstanceAnimator}
	animate_element_by_name = function(element_name) /*=>*/ {
		return animate_ui_element(get(element_name));
	}
	/// @returns {UISequenceDesignInstanceAnimator}
	animate_ui_element = function(element_ui) /*=>*/ {
		return animate_design_instance(fabric.get_by_ui(element_ui));
	}
	/// @returns {UISequenceDesignInstanceAnimator}
	animate_design_instance = function(design_instance/*:UISequenceDesignInstance*/) /*=>*/ {
		design_instance.element_reference.animation_is_isolated = true;
		return new UISequenceDesignInstanceAnimator(design_instance);
	}
	
	
	static sync_size = function() {
		set_size(data.width(), data.height());
		set_anchor(data.anchor.x, data.anchor.y);
	}
	/*on_calculate_begin.add(function() {
		if (data == undefined)
			return;
		box_data.width.content = data.width();
		box_data.height.content = data.height();
		
		box_data.anchor.x.content = data.anchor.x;
		box_data.anchor.y.content = data.anchor.y;
	});*/
	/*on_cleanup.add(function()  {
		if (fabric == undefined) return;
		
		fabric.cleanup();
		delete fabric;
		fabric =  undefined;
		
		if (data == undefined)
			return;
			
		if (!static_sequence) {
			data.cleanup();
			delete data;
		}
	});*/
}

function UISequenceDesignFabric(_design) constructor {
	
	design = _design;
	
	elements_map = {};
	elements = [];
	
	parse = function(root_element/*:SequenceElement*/)/*->UISequenceDesignInstance*/ {
		var root = instantiate_recursively(root_element);
		initialyze();
		return root;
	}
	instantiate_recursively = function(root_element/*:SequenceElement*/, parent/*:UISequenceDesignInstance?*/=undefined)/*->UISequenceDesignInstance*/ {
		var root_inst = instantiate_one(root_element, parent);
		for(var i = 0; i < array_length(root_element.elements); i++) {
			instantiate_recursively(root_element.elements[i], root_inst);
		}
		return root_inst;
	}
	instantiate_one = function(element/*:SequenceElement*/, parent/*:UISequenceDesignInstance?*/=undefined)/*->UISequenceDesignInstance*/ {
		var dinst = new UISequenceDesignInstance(self, design, /*#cast*/ element);
		dinst.instantiate_ui();
		
		element_register(dinst);
		
		if (parent != undefined)
			dinst.set_parent(parent);
		
		return dinst;
	}
	initialyze = function() /*=>*/ {
		for(var i = 0; i < array_length(elements); i++)
			elements[i].init();
	}
	
	element_cleanup_all = function() /*=>*/ {
		for(var i = array_length(elements) - 1; i >= 0; i--) {
			element_cleanup(elements[i]);
		}
	}
	element_cleanup = function(element/*:UISequenceDesignInstance*/) /*=>*/ {
		element_unregister(element);
		element.cleanup();
	}
	
	element_register = function(dinst/*:UISequenceDesignInstance*/) /*=>*/ {
		elements_map[$ dinst.ID] = dinst;
		array_push(elements, dinst);
	}
	element_unregister = function(dinst/*:UISequenceDesignInstance*/) /*=>*/ {
		variable_struct_remove(elements_map, dinst.ID);
		array_remove(elements, dinst);
	}
	get = function(ui_id/*:string*/)/*->UISequenceDesignInstance*/ {
		return elements_map[$ ui_id];
	}
	get_by_ui = function(ui/*:UIBox*/)/*->UISequenceDesignInstance*/ {
		for(var i = 0; i < array_length(elements); i++) {
			var element/*:UISequenceDesignInstance*/ = elements[i];
			if (element.ui == ui)
				return element;
		}
		return /*#cast*/ undefined;
	}
	
	set_frame = function(ui/*:UIBox*/, frame) {
		if (ui[$ "sequence_element"] == undefined) return false;
		
		ui[$ "sequence_element"].set_frame(frame);
	}
	
	cleanup = function() /*=>*/ {
		element_cleanup_all();
		elements_map = /*#cast*/ undefined;
		elements = /*#cast*/ undefined;
	}
	
	processors = {
		text: function(e) {
			e.class = InterfaceText;
		},
		sprite: function(e) {
			e.class = InterfaceSprite;
		}
	}
	
	params = /*#cast*/ {
		valign: function(e, val) {
			var valign = /*#cast*/ fa_center;
			
			if (val == "top" or val == "up")
				valign = fa_top;
			if (val == "bottom" or val == "down")
				valign = fa_bottom;
				
			e.add_parameter_applyable("valign", valign);
		},
		halign: function(e, val) {
			var halign = /*#cast*/ fa_center;
			
			if (val == "left")
				halign = fa_left;
			if (val == "right")
				halign = fa_right;
				
			e.add_parameter_applyable("halign", halign);
		}
	}
	postparams = {
		fixed: function(e, val) {
			if (is_string(val)) {
				val = [val];
			}
			
			if (!is_array(val)) {
				e.data_parser.lock = true;
				return;
			}
			
			var val_array/*:array<string>*/ = /*#cast*/ val;
			for(var i = 0; i < array_length(val_array); i++) {
				switch(val_array[i]) {
					case "size": e.data_parser.size_changeable = false; break;
					case "dimensions": e.data_parser.dimensions_changeable = false; break;
					case "position": e.data_parser.position_changeable = false; break;
					case "anchor": e.data_parser.anchor_changeable = false; break;
					case "active": e.data_parser.active_changeable = false; break;
				}
			}
		},
		order: function(e, val) {
			var index = 0;
			try {
				index = real(val);
			} catch (e) {
				Main.logger.ui.error("error while parsing order index: " + string(e.message));
			} finally {
				e.ui.flag_set("order", index);
			}
		},
		autosize: function(e, val) {
			if (val == "w" || val == undefined) {
				e.ui.set_w(AUTO(1))
				e.data_parser.changeable_details.w = false;
			}
			if (val == "h" || val == undefined) {
				e.ui.set_h(AUTO(1))
				e.data_parser.changeable_details.h = false;
			}
		},
		fit_content: function(e, val) {
			if (val == "w" || val == undefined) {
				e.ui.set_w(CUNIT(1));
				e.data_parser.changeable_details.w = false;
			}
			if (val == "h" || val == undefined) {
				e.ui.set_h(CUNIT(1));
				e.data_parser.changeable_details.h = false;
			}
		},
		x: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			if (val == "absolute")
				inst.set_x(e.element_reference.position.x + e.parent.element_reference.origin_summary.x);
			else
				inst.set_x(val);
				
			e.data_parser.changeable_details.x = false;
		},
		y: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			if (val == "absolute")
				inst.set_y(e.element_reference.position.y + e.parent.element_reference.origin_summary.y);
			else
				inst.set_y(val);
				
			e.data_parser.changeable_details.y = false;
		},
		w: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			if (val == "absolute")
				inst.set_w(e.element_reference.size.x);
			else
				inst.set_w(val);
				
			e.data_parser.changeable_details.w = false;
		},
		h: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			if (val == "absolute")
				inst.set_h(e.element_reference.size.y);
			else
				inst.set_h(val);
				
			e.data_parser.changeable_details.h = false;
		},
		ignore_scale: function(e/*:UISequenceDesignInstance*/, val) {
			var inst/*:UIBox*/ = e.ui;
			
			inst.set_w(e.element_reference.size.x * e.element_reference.scale.x);
			inst.set_h(e.element_reference.size.y * e.element_reference.scale.y);
			inst.set_scale(1, 1);
				
			e.data_parser.size_changeable = false;
			e.data_parser.scale_changeable = false;
		},
		right: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			var ref = e.element_reference;
			var ref_parent = e.element_reference.parent;
			
			var box/*:Box*/ = ref.get_box(ref.get_total_scale(), ref.get_total_position());
			var box_parent/*:Box*/ = ref_parent.get_box(ref_parent.get_total_scale(), ref_parent.get_total_position());
			
			if (val == "absolute")
				inst.set_right(box_parent.right - box.right);
			else
				inst.set_right(val); 
				
			e.data_parser.changeable_details.x = false;
		},
		bottom: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			var ref = e.element_reference;
			var ref_parent = e.element_reference.parent;
			
			var box/*:Box*/ = ref.get_box(ref.get_total_scale(), ref.get_total_position());
			var box_parent/*:Box*/ = ref_parent.get_box(ref_parent.get_total_scale(), ref_parent.get_total_position());
			
			if (val == "absolute")
				inst.set_bottom(box_parent.bottom - box.bottom);
			else
				inst.set_bottom(val);
				
			e.data_parser.changeable_details.y = false;
		},
		fill: function(e, val) {
			e.data_parser.size_changeable = false;
			e.ui.set_size("fill", "fill");
		},
		ignore: function(e, val) {
			e.ui.flag_set("ignore", true)
		},
		aspect: function(e, val) {
			if (val == "v" || val == "height") {
				e.ui.set_w(HUNIT(e.element_reference.size.x / e.element_reference.size.y));
				e.data_parser.changeable_details.w = false;
			}
			if (val == "h" || val == "width") {
				e.ui.set_h(WUNIT(e.element_reference.size.y / e.element_reference.size.x));
				e.data_parser.changeable_details.h = false;
			}
		},
		absolute: function(e, val) {
			var inst/*:UIBox*/ = e.ui;
			
			if (val == undefined) val = "x,y,w,h";
			var parameters = string_split(string_replace_all(val, " ", ""), ",", true);
			for(var i = 0; i < array_length(parameters); i++) {
				var param = parameters[i];
				switch(param) {
					case "left":
					case "x": 
						inst.set_x(e.element_reference.position.x + e.parent.element_reference.origin_summary.x); 
						e.data_parser.changeable_details.x = false;
						break;
					case "top":
					case "y": 
						inst.set_y(e.element_reference.position.y + e.parent.element_reference.origin_summary.y); 
						e.data_parser.changeable_details.y = false;
						break;
					case "w":
					case "width":
						inst.set_w(e.element_reference.size.x); 
						e.data_parser.changeable_details.w = false;
						break;
					case "h": 
					case "height":
						inst.set_h(e.element_reference.size.y); 
						e.data_parser.changeable_details.h = false;
						break;
				}
			}
		},
		indent: function(e/*:UISequenceDesignInstance*/, val) {
			var inst/*:UIBox*/ = e.ui;
			
			var ref = e.element_reference;
			var ref_parent = e.element_reference.parent;
			
			var box/*:Box*/ = ref.get_box(ref.get_total_scale(), ref.get_total_position());
			var box_parent/*:Box*/ = ref_parent.get_box(ref_parent.get_total_scale(), ref_parent.get_total_position());
			
			inst.set_scale(1, 1);
			inst.set_anchor(0, 0);
			inst.set_indents(
				box_parent.right - box.right,
				box_parent.bottom - box.bottom,
				box.left - box_parent.left,
				box.top - box_parent.top
			);
			
			e.data_parser.size_changeable = false;
			e.data_parser.position_changeable = false;
			e.data_parser.anchor_changeable = false;
			e.data_parser.scale_changeable = false;
		},
		bounds: function(e/*:UISequenceDesignInstance*/, val) {
			var inst/*:UIBox*/ = e.ui;
			val = dp_parse_array(val);
			
			var ref = e.element_reference;
			var ref_parent = e.element_reference.parent;
			
			var box/*:Box*/ = ref.get_box(ref_parent.scale, ref_parent.position);
			var box_parent/*:Box*/ = ref_parent.get_box();
			
			inst.set_bounds([
				array_get_index(val, "right") >= 0,
				array_get_index(val, "bottom") >= 0,
				array_get_index(val, "left") >= 0,
				array_get_index(val, "top") >= 0
			]);
			
			var looped = false;
			if (inst.box_data.bounds[0] && inst.box_data.bounds[2]) {
				inst.set_anchor_x(0);
				inst.set_scale_x(1);
				looped = true;
			}
			if (inst.box_data.bounds[1] && inst.box_data.bounds[3]) {
				inst.set_anchor_y(0);
				inst.set_scale_y(1);
				looped = true;
			}
			if (looped) {
				e.data_parser.size_changeable = false;
				e.data_parser.scale_changeable = false;
			}
				
			for(var i = 0; i < array_length(val); i++) {
				var cval = val[i];
				switch (cval) {
					case "right": inst.set_right(box_parent.right - box.right - ref.origin_summary.x); break;
					case "bottom": inst.set_bottom(box_parent.bottom - box.bottom - ref.origin_summary.y); break;
					case "left": inst.set_left(box.left - box_parent.left + ref.origin_summary.x); break;
					case "top": inst.set_top(box.top - box_parent.top + ref.origin_summary.y); break;
				}
			}
			e.data_parser.position_changeable = false;
			e.data_parser.anchor_changeable = false;
		},
		shader: function(e, val) {
			var ui = e.ui;
			
			var shader_asset = asset_get_index("sh_" + val);
			if (shader_asset < 0) shader_asset = asset_get_index(val);
			if (shader_asset < 0) {
				Main.logger.ui.error("THERE IS NO SHADER " + string(val) + " IN SEQUENCE ELEMENT " + string(e[$ "ID"]));
				return;
			}
			
			ui._shader = shader_asset;
			ui.on_render_begin.add(method(undefined, function() {
				_shader_previous = shader_current();
				shader_set(_shader);
			}));
			ui.on_render_end.add(method(undefined, function() {
				if (_shader_previous == undefined) 
					shader_reset();
				else
					shader_set(_shader_previous);
			}));
		},
		erase: function(e, val) {
			var ui = e.ui;
			ui.on_render_begin.add(method(undefined, function() {
				_blend_ext = gpu_get_blendmode_ext_sepalpha();
				gpu_set_blendmode(bm_subtract);
				gpu_set_colorwriteenable(false, false, false, true);
			}));
			ui.on_render_end.add(method(undefined, function() {
				gpu_set_blendmode_ext_sepalpha(_blend_ext);
				gpu_set_colorwriteenable(true, true, true, true);
			}));
		},
		write_color: function(e, val) {
			var ui = e.ui;
			
			if (val == undefined) val = "rgb";
			ui.write_color_data = [string_count("r", val), string_count("g", val), string_count("b", val), string_count("a", val)]
			
			ui.on_render_begin.add(method(undefined, function() {
				gpu_set_colorwriteenable(write_color_data);
			}));
			ui.on_render_end.add(method(undefined, function() {
				gpu_set_colorwriteenable(true, true, true, true);
			}));
		},
		alphamask: function(e, val) {
			var ui = e.ui;
			ui.on_render_begin.add(method(undefined, function() {
				gpu_set_colorwriteenable(true, true, true, false);
			}));
			ui.on_render_end.add(method(undefined, function() {
				gpu_set_colorwriteenable(true, true, true, true);
			}));
		},
		active: function(e, val) {
			var ui = e.ui;
			ui.set_active(val != "false");
		},
		visible: function(e, val) {
			var ui = e.ui;
			ui.visible = val != "false";
		},
		wrap: function(e, val) {
			e.ui.wrap = val != "false";
		},
		cached: function(e, val) {
			e.ui.cache = val != "false";
		}
	}
	properties = {
		tooltip: function(e, prop/*:SequenceText*/) {
			if (prop.class != "text")
				return;
				
			Data.ui.screen.tips.register_tip(e.ID, prop.text);
		}
	}

	initialyze();
}
	
function UISequenceDesignInstance(_fabric/*:UISequenceDesignFabric*/, _design/*:UISequenceDesign*/, _element_reference/*:SequenceElement*/) constructor {
	fabric = _fabric; /// @is {UISequenceDesignFabric}
	design = _design; /// @is {UISequenceDesign}
	element_reference = _element_reference; /// @is {SequenceElement}
	ui = /*#cast*/ undefined; /// @is {UIBox}
	class = InterfaceBase;
	parent = /*#cast*/ undefined; /// @is {UISequenceDesignInstance}
	childrens = []; /// @is {array<UISequenceDesignInstance>}
	
	ID = "";
	tags = [];
	parameters_applyable = []; /// @is {array<array>}
	parameters_initial = [];
	parameters = [];
	apply_struct = {};
	
	data_parser = UISequenceDesignDataParser_Create(self); /// @is {UISequenceDesignDataParser}
	
	set_frame = function(frame/*:number*/, force/*:bool*/=false) /*=>*/ {
		element_reference.set_frame(frame, force);
		update();
		
		if (!data_parser.lock)
		for(var i = 0; i < array_length(childrens); i++) {
			childrens[i].set_frame(frame);
		}
	}
	
	animate_element = function(to_frame = 0, from_frame = undefined) /*=>*/ {
		
	}
	
	instantiate_ui = function() /*=>*/ {
		prepare_ui();
		
		ui = Interface.create(class);
		ui.set_position_type(flexpanel_position_type.absolute);
		ui.set_name(ID);
		
		setup_ui();
	}
	prepare_ui = function() /*=>*/ {
		parse_class();
		parse_name();
		process_processors();
		process_parameters_initial();
		process_properties();
	}
	setup_ui = function() /*=>*/ {
		data_parser.init();
		
		var interface = self;
		ui.configure({
			sequence_interface: interface
		});
	}
	init = function() /*=>*/ {
		process_parameters_applyable();
		process_parameters();
	}
	cleanup = function() /*=>*/ {
		parameters_applyable = /*#cast*/ undefined;
		parameters_initial = /*#cast*/ undefined;
		parameters = /*#cast*/ undefined;
		apply_struct = /*#cast*/ undefined;
		tags = /*#cast*/ undefined;
		parent = /*#cast*/ undefined;
		childrens = /*#cast*/ undefined;
		fabric = /*#cast*/ undefined;
		design = /*#cast*/ undefined;
		
		ui.destroy();
		ui = /*#cast*/ undefined;
	}
	
	update = function() /*=>*/ {
		if (ui == undefined) {
			show_debug_message("TRYING to update deleted element!")
			show_debug_message(debug_get_callstack());
			return;
		}
		data_parser.update();
	}
	process_processors = function() /*=>*/ {
		for(var i = 0; i < array_length(tags); i++) {
			var processor_name = tags[i];
			processor_name = string_replace(processor_name, "-", "_");
			
			var processor = fabric.processors[$ processor_name];
			if (processor == undefined) {
				var type_of_asset = asset_get_type(processor_name);
				var ui_class = asset_get_index(processor_name);
				
				if (ui_class == -1) {
					ui_class = SequenceInterfaceClasses().get(processor_name);
					if (ui_class == undefined)
						ui_class = -1;
					else {
						type_of_asset = asset_script;
					}
				}
				
				if (ui_class != -1 && type_of_asset == asset_script)
					class = ui_class;
					
				continue;
			}
				
			processor(self);
		}
	}
	process_parameters_initial = function() /*=>*/ {
		for(var i = 0; i < array_length(parameters_initial); i++) {
			var pair = parameters_initial[i];
			var param_name = pair[0],
				param_value = parse_param_value(pair[1]);
			
			param_name = string_replace_all(param_name, "-", "_");
			var param = fabric.params[$ param_name];
			
			param(self, param_value);
		}
	}
	process_parameters = function() /*=>*/ {
		for(var i = 0; i < array_length(parameters); i++) {
			var pair = parameters[i];
			var param_name = pair[0],
				param_value = parse_param_value(pair[1]);
				
			param_name = string_replace_all(param_name, "-", "_");
			var param = fabric.postparams[$ param_name];
			
			param(self, param_value);
		}
	}
	process_parameters_applyable = function() /*=>*/ {
		for(var i = 0; i < array_length(parameters_applyable); i++) {
			var pair = parameters_applyable[i]
			var param_name = pair[0],
				param_value = parse_param_value(pair[1]),
				param_hash = pair[2];
				
			var param = struct_get_from_hash(fabric.postparams, param_hash);
			struct_set_from_hash(apply_struct, param_hash, param_value);
		}
		
		ui.configure(apply_struct);
	}
	process_properties = function() /*=>*/ {
		var keys = variable_struct_get_names(element_reference.properties);
		for(var i = 0; i < array_length(keys); i++) {
			var key = keys[i];
			
			var handler = fabric.properties[$ key];
			
			if (handler != undefined)
				handler(self, element_reference.properties[$ key]);
		}
	}
	
	parse_class = function() /*=>*/ {
		if (!is_instanceof(element_reference, SequenceElement))
			return;
			
		array_push(tags, element_reference.class);
	}
	parse_name = function() /*=>*/ {
		var parsed_name = string_split(element_reference.name, "#", false);
		var tag = /*#cast*/ undefined;
		
		if (array_length(parsed_name) > 1) {
			tag = parsed_name[0];
			array_push(tags, tag);
			ID = parsed_name[1];
		} else {
			ID = element_reference.name;
		}
		
		var parsed_values = string_split(ID, ";", true)
		if (array_length(parsed_values) > 1) {
			ID = parsed_values[0];
			
			for(var i = 1; i < array_length(parsed_values); i++) {
				var parsed_value = string_split(parsed_values[i], "=", true);
				var parsed_value_name = string_replace_all(parsed_value[0], "-", "_")
				var parsed_param;
				
				if (array_length(parsed_value) > 1) {
					parsed_param = [parsed_value_name, parsed_value[1]];
				} else {
					parsed_param = [parsed_value_name, undefined];
				}
				
				var is_initial = fabric.params[$ parsed_value_name] != undefined;
				var is_usual = fabric.postparams[$ parsed_value_name] != undefined;
				
				var list;
				if (is_initial) {
					list = parameters_initial;
				}
				else if (is_usual) {
					list = parameters;
				}
				else {
					add_parameter_applyable(parsed_value_name, parsed_param[1]);
					continue;
				}
				
				array_push(list, parsed_param);
			}
		}
	}
	add_parameter_applyable = function(key, val) /*=>*/ {
		var fixed_key = string_replace_all(key, "-", "_");
		array_push(parameters_applyable, /*#cast*/ [fixed_key, val, variable_get_hash(fixed_key)]);
	}
	
	parse_param_value = function(val) /*=>*/ {
		var val_real = try_parse_real(val);
		if (val_real != undefined)
			return val_real;
		
		if (string_char_at(val, 1) == "@") {
			var element = fabric.get(string_delete(val, 1, 1));
			if (element != undefined) return element.ui;
		}
		
		return val;
	}
	try_parse_real = function(val) /*=>*/ {
		if (is_real_parameter(val)) {
			try {
				return real(val);
			}
			catch(e) {
				return undefined;
			}
		}
		return undefined;
	}
	is_real_parameter = function(val) /*=>*/ {
		var real_characters = "0123456789-.";
		for(var i = 0; i < string_length(val); i++) {
			var symb = string_char_at(val, i + 1);
			if (!string_count(symb, real_characters))
				return false;
		}
		return true;
	}
	
	
	reset_parent = function() /*=>*/ {
		if (parent == undefined) return;
		
		array_remove(parent.childrens, self);
		parent = /*#cast*/ undefined;
	}
	set_parent = function(_parent/*:UISequenceDesignInstance*/) /*=>*/ {
		reset_parent();
		
		parent = _parent;
		array_push(parent.childrens, self);
		
		if (ui != undefined)
			ui.set_parent(parent.ui);
			
		data_parser.update(true);
	}
}

function SequenceInterfaceClasses() {
	static classes = {
		classes: {},
		register: function(name, class) {
			classes[$ name] = class;
		},
		get: function(name) {
			return classes[$ name];
		}
	}
	return classes;
}


function UISequenceDesignDataParser_Create(_element/*:UISequenceDesignInstance*/) {
	switch (_element.element_reference.class) {
		case "text":
			return new UISequenceDesignDataParser_Text(_element);
		case "sprite":
			return new UISequenceDesignDataParser_Sprite(_element);
		case "group":
			return new UISequenceDesignDataParser_Group(_element);
		
		case "particle":
			return new UISequenceDesignDataParser_Particle(_element);
		
		default:
			return new UISequenceDesignDataParser(_element);
	}
}

function UISequenceDesignDataParser(_element/*:UISequenceDesignInstance*/) constructor {
	element = _element; /// @is {UISequenceDesignInstance}
	
	lock = false;
	dimensions_changeable = true;
	scale_changeable = true;
	size_changeable = true;
	position_changeable = true;
	anchor_changeable = true;
	active_changeable = true;
	changeable_details = {
		x: true,
		y: true,
		w: true,
		h: true
	}
	
	init = function() /*=>*/ {
		var init_struct = {
			visible: element.element_reference.visible
		}
		
		init_append(init_struct);
		
		element.ui.configure(init_struct);
	}
	init_append = function(struct) /*=>*/ {
		
	}
	
	update = function(force = false) /*=>*/ {
		if (lock && !force)
			return;
		
		var update_struct = {
			angle: element.element_reference.get_total_angle(),
			color: element.element_reference.color,
			alpha: element.element_reference.alpha
		}
		
		if (active_changeable || force)
			element.ui.set_active(element.element_reference.active);
		
		element.ui.configure(update_struct);
		
		update_dimensions(force);
	}
	update_dimensions = function(force = false) /*=>*/ {
		var element_reference = element.element_reference;
		var ui = element.ui;
		var parent = element.parent;
		
		if (element_reference.parent == undefined) {
			ui.set_size(element_reference.size.x, element_reference.size.y);
			return;
		}
		if (!dimensions_changeable && !force) return;
		
		var element_w = max(get_element_size().x, 1);
		var element_h = max(get_element_size().y, 1);
		
		if (anchor_changeable || force) {
			ui.set_anchor(
				element_reference.origin_summary.x, 
				element_reference.origin_summary.y
			);
		}
		
		if (position_changeable || force) {
			if (changeable_details.x)
				ui.set_left(element_reference.position.x + parent.element_reference.origin_summary.x);
			if (changeable_details.y)
				ui.set_top(element_reference.position.y + parent.element_reference.origin_summary.y);
		}
		
		if (scale_changeable || force) {
			//ui.set_scale_x(element_reference.scale.x);
			//ui.set_scale_y(element_reference.scale.y);
		}
				
		if (size_changeable || force) {
			if (changeable_details.w)
				ui.set_width(element_w);
			if (changeable_details.h)
				ui.set_height(element_h);
		}
		
	}
	
	static get_element_size = function() {
		return element.element_reference.size;
	}

}
function UISequenceDesignDataParser_Group(_element/*:UISequenceDesignInstance*/) : UISequenceDesignDataParser(_element) constructor {
	
	element_group = /*#cast*/ element.element_reference; /// @is {SequenceGroup}
	
	init_append = function(struct) /*=>*/ {
		element_group.calculate_dimensions_enable = true;
		//element_group.calculate_dimensions();
	}
}
function UISequenceDesignDataParser_Text(_element/*:UISequenceDesignInstance*/) : UISequenceDesignDataParser(_element) constructor {
	
	element_text = /*#cast*/ element.element_reference /*#as SequenceText*/;
	
	init_append = function(struct) /*=>*/ {
		struct.text = element_text.text;
		struct.font = element_text.font;
		struct.halign = element_text.halign;
		struct.valign = element_text.valign;
		struct.text = element_text.text;
	}
}
function UISequenceDesignDataParser_Sprite(_element/*:UISequenceDesignInstance*/) : UISequenceDesignDataParser(_element) constructor {
	
	element_sprite = /*#cast*/ element.element_reference /*#as SequenceSprite*/;
	
	init_append = function(struct) /*=>*/ {
		struct.sprite = element_sprite.sprite;
		struct.frame = element_sprite.frame;
	}
	
	static get_element_size = function() {
		static point = new Point();
		point.set(
					element.element_reference.size.x * element.element_reference.scale.x,
					element.element_reference.size.y * element.element_reference.scale.y,
					);
		return point;
	}
}
function UISequenceDesignDataParser_Particle(_element/*:UISequenceDesignInstance*/) : UISequenceDesignDataParser(_element) constructor {
	
	element_particle = /*#cast*/ element.element_reference /*#as SequenceParticle*/;
	
	init_append = function(struct) /*=>*/ {
		struct.system = element_particle.system;
	}
}



SequenceInterfaceClasses().register("Base", InterfaceBase);
SequenceInterfaceClasses().register("base", InterfaceBase);
SequenceInterfaceClasses().register("empty", InterfaceBase);