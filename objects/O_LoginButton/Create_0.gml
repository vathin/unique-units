/// @description Вставьте описание здесь
// Вы можете записать свой код в этом редакторе

send_to = undefined
type = undefined

set_type = function(new_type) {
	type = new_type
}

set_address = function(new_address) {
	send_to = new_address
}

click = function() {
	send_to.send_data(type)
}