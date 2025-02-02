function InterfaceRaycast() constructor {

	
	
	static Raycast = function(_x, _y, out_array = [], element = Interface.screen) {
		
		var geometry = element.get_geometry();
		
		if (!is_undefined(element.matrix)) {
			var matrix = element.matrix;
			var mult_result = matrix_transform_vertex(matrix_build_inverse(matrix), _x, _y, 0);
			_x = mult_result[0];
			_y = mult_result[1];
		}
		
		if (_x != clamp(_x, geometry.left, geometry.left + geometry.width))
			return out_array;
		
		if (_y != clamp(_y, geometry.top, geometry.top + geometry.height))
			return out_array;
			
		array_push(out_array, element);
		
		for(var i = 0; i < array_length(element.children); i++) {
			Raycast(_x, _y, out_array, element.children[i]);
		}
		
		return out_array;
	}
	
}

new InterfaceRaycast();


function matrix_build_inverse(m) {
	var results = array_create(16);
    results[0]  =  m[ 5] * m[10] * m[15] - m[ 5] * m[11] * m[14] - m[ 9] * m[ 6] * m[15] + m[ 9] * m[ 7] * m[14] + m[13] * m[ 6] * m[11] - m[13] * m[ 7] * m[10];
    results[1]  = -m[ 1] * m[10] * m[15] + m[ 1] * m[11] * m[14] + m[ 9] * m[ 2] * m[15] - m[ 9] * m[ 3] * m[14] - m[13] * m[ 2] * m[11] + m[13] * m[ 3] * m[10];
    results[2]  =  m[ 1] * m[ 6] * m[15] - m[ 1] * m[ 7] * m[14] - m[ 5] * m[ 2] * m[15] + m[ 5] * m[ 3] * m[14] + m[13] * m[ 2] * m[ 7] - m[13] * m[ 3] * m[ 6];
    results[3]  = -m[ 1] * m[ 6] * m[11] + m[ 1] * m[ 7] * m[10] + m[ 5] * m[ 2] * m[11] - m[ 5] * m[ 3] * m[10] - m[ 9] * m[ 2] * m[ 7] + m[ 9] * m[ 3] * m[ 6];
    results[4]  = -m[ 4] * m[10] * m[15] + m[ 4] * m[11] * m[14] + m[ 8] * m[ 6] * m[15] - m[ 8] * m[ 7] * m[14] - m[12] * m[ 6] * m[11] + m[12] * m[ 7] * m[10];
    results[5]  =  m[ 0] * m[10] * m[15] - m[ 0] * m[11] * m[14] - m[ 8] * m[ 2] * m[15] + m[ 8] * m[ 3] * m[14] + m[12] * m[ 2] * m[11] - m[12] * m[ 3] * m[10];
    results[6]  = -m[ 0] * m[ 6] * m[15] + m[ 0] * m[ 7] * m[14] + m[ 4] * m[ 2] * m[15] - m[ 4] * m[ 3] * m[14] - m[12] * m[ 2] * m[ 7] + m[12] * m[ 3] * m[ 6];
    results[7]  =  m[ 0] * m[ 6] * m[11] - m[ 0] * m[ 7] * m[10] - m[ 4] * m[ 2] * m[11] + m[ 4] * m[ 3] * m[10] + m[ 8] * m[ 2] * m[ 7] - m[ 8] * m[ 3] * m[ 6];
    results[8]  =  m[ 4] * m[ 9] * m[15] - m[ 4] * m[11] * m[13] - m[ 8] * m[ 5] * m[15] + m[ 8] * m[ 7] * m[13] + m[12] * m[ 5] * m[11] - m[12] * m[ 7] * m[ 9];
    results[9]  = -m[ 0] * m[ 9] * m[15] + m[ 0] * m[11] * m[13] + m[ 8] * m[ 1] * m[15] - m[ 8] * m[ 3] * m[13] - m[12] * m[ 1] * m[11] + m[12] * m[ 3] * m[ 9];
    results[10] =  m[ 0] * m[ 5] * m[15] - m[ 0] * m[ 7] * m[13] - m[ 4] * m[ 1] * m[15] + m[ 4] * m[ 3] * m[13] + m[12] * m[ 1] * m[ 7] - m[12] * m[ 3] * m[ 5];
    results[11] = -m[ 0] * m[ 5] * m[11] + m[ 0] * m[ 7] * m[ 9] + m[ 4] * m[ 1] * m[11] - m[ 4] * m[ 3] * m[ 9] - m[ 8] * m[ 1] * m[ 7] + m[ 8] * m[ 3] * m[ 5];
    results[12] = -m[ 4] * m[ 9] * m[14] + m[ 4] * m[10] * m[13] + m[ 8] * m[ 5] * m[14] - m[ 8] * m[ 6] * m[13] - m[12] * m[ 5] * m[10] + m[12] * m[ 6] * m[ 9];
    results[13] =  m[ 0] * m[ 9] * m[14] - m[ 0] * m[10] * m[13] - m[ 8] * m[ 1] * m[14] + m[ 8] * m[ 2] * m[13] + m[12] * m[ 1] * m[10] - m[12] * m[ 2] * m[ 9];
    results[14] = -m[ 0] * m[ 5] * m[14] + m[ 0] * m[ 6] * m[13] + m[ 4] * m[ 1] * m[14] - m[ 4] * m[ 2] * m[13] - m[12] * m[ 1] * m[ 6] + m[12] * m[ 2] * m[ 5];
    results[15] =  m[ 0] * m[ 5] * m[10] - m[ 0] * m[ 6] * m[ 9] - m[ 4] * m[ 1] * m[10] + m[ 4] * m[ 2] * m[ 9] + m[ 8] * m[ 1] * m[ 6] - m[ 8] * m[ 2] * m[ 5];
        
    var determinant = m[0] * results[0] + m[1] * results[4] + m[2] * results[8] + m[3] * results[12];
        
    if (determinant == 0) {
    	return undefined;
    }
        
    for(var i = 0; i < 16; i++) {
    	results[i] /= determinant;
    }
	return results;
}