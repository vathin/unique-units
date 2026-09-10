/// Base contract for rules. Effects must return serializable events instead of
/// constructing animation controllers or accessing Game/Field/UI.
function GameEffect(_id = "") constructor {
	id = _id;

	get_inputs = function(_state, _actor_id, _partial_inputs = {}) {
		return [];
	}

	validate_inputs = function(_state, _actor_id, _inputs) {
		return {ok: true, error: ""};
	}

	execute = function(_state, _actor_id, _inputs) {
		return {ok: false, error: "Effect is not implemented", next_state: _state, animation_batches: [], events: []};
	}
}
