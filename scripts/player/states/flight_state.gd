extends State

@export var adash_state: State
@export var falling_state: State
@export var idle_state: State
@export var run_state: State
@export var walk_state: State
@export var brake_state: State

var current_max_speed: float = 0.0

func enter(is_loading: bool = false) -> void:
	stats.flying = true
	var entry_speed = player.velocity.length()
	current_max_speed = max(entry_speed, stats.base_flight_speed)
	
	# visual things
	if abs(player.velocity.x) > 300:
		if player.is_moving_backwards():
			player.animation_controller.play_animation("flybackward")
		else:
			player.animation_controller.play_animation("flyforward")
	else:
		player.animation_controller.play_animation("slowflight")

func process_physics(delta: float) -> State:
	if stats.grounded:
		stats.flying = false
		stats.jumps = stats.max_jumps
		stats.dashes = stats.max_dashes
		var speed = abs(player.velocity.x)
		
		if speed >= stats.brake_limit:
			return brake_state
		elif speed >= stats.run_move_speed:
			return run_state
		elif speed > 0:
			return walk_state
		else:
			return idle_state

	if get_flight() and stats.fp > 0:
			stats.flying = false
			return falling_state

	if get_air_dash() != Vector2.ZERO and stats.dashes >= 1:
				stats.dashes -= 1
				return adash_state

	var input_vec = get_movement_vector()
	if input_vec != Vector2.ZERO:
		input_vec = input_vec.normalized()
		player.velocity += input_vec * stats.flight_acceleration * delta
		if current_max_speed > stats.base_flight_speed:
			current_max_speed = move_toward(
				current_max_speed, 
				stats.base_flight_speed, 
				100.0 * delta
				)
		if player.velocity.length() > current_max_speed:
			player.velocity = player.velocity.normalized() * current_max_speed
	else:
		player.velocity = player.velocity.move_toward(
			Vector2.ZERO,stats.air_friction * delta
		)
	
	if abs(player.velocity.x) > 300:
		if player.is_moving_backwards():
			player.animation_controller.play_animation("flybackward")
		else:
			player.animation_controller.play_animation("flyforward")
	else:
		player.animation_controller.play_animation("slowflight")
	return null
