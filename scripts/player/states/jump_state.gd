extends State

@export var fall_state: State
@export var idle_state: State
@export var jump_state: State

func enter(is_loading: bool = false) -> void:
	if not is_loading:
		player.velocity.y = stats.jump_force
		var direction := get_movement_input()
		if stats.grounded:
			if direction == 0:
				pass
			elif direction * player.velocity.x <= 0: 
				player.velocity.x = direction * stats.base_move_speed
		elif not stats.grounded:
			if direction == 0:
				player.velocity.x = 0.0
			elif direction * player.velocity.x <= 0:
				player.velocity.x = direction * stats.base_move_speed
	player.animation_controller.play_animation("jump")

func process_physics(delta: float) -> State:
	if not stats.grounded:
		if get_down():
			player.velocity.y += (stats.gravity * 2) * delta
		else:
			player.velocity.y += stats.gravity * delta
		if get_jump() and stats.jumps >= 1:
			stats.jumps -= 1
			return jump_state

	elif stats.grounded:
		stats.jumps = stats.max_jumps
		return idle_state
	if player.velocity.y >= 0:
		return fall_state
	return null
