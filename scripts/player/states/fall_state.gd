extends State

@export var idle_state: State
@export var walk_state: State
@export var run_state: State
@export var jump_state: State
@export var brake_state: State
@export var adash_state: State
@export var flight_state: State

func enter(is_loading: bool = false) -> void:
	clear_dash_state()
	player.animation_controller.play_animation("fall")

func process_physics(delta: float) -> State:
	if get_down():
		player.velocity.y += (stats.gravity * 2) * delta
	else:
		player.velocity.y += stats.gravity * delta

	if get_flight() and stats.fp > 0:
			return flight_state

	if get_jump() and stats.jumps >= 1:
		stats.jumps -= 1
		return jump_state
	elif get_jump() and stats.jumps == 0:
		return flight_state
	
	if get_air_dash() != Vector2.ZERO and stats.dashes >= 1:
			stats.dashes -= 1
			return adash_state
	
	var direction = get_movement_input() * player.velocity.x
	if stats.grounded:
		stats.jumps = stats.max_jumps
		stats.dashes = stats.max_dashes
		
		if direction == 0:
			return brake_state if abs(player.velocity.x) >= stats.brake_limit else idle_state
		elif direction <= 0:
			return brake_state if abs(player.velocity.x) >= stats.brake_limit else walk_state
		elif direction < stats.run_move_speed:
			return walk_state
		elif direction < stats.brake_limit:
			return run_state
		else:
			return brake_state
	return null
