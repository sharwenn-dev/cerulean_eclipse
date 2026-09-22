extends State

@export var fall_state: State
@export var idle_state: State
@export var jump_state: State

func enter() -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	player.animation_controller.play_animation("jump")
	player.velocity.y = stats.jump_force
	var direction := get_movement_input()
	if direction != 0:
		player.velocity.x = direction * stats.base_move_speed
	else:
		player.velocity.x = 0.0
		
func process_physics(delta: float) -> State:
	if not player.is_on_floor():
		player.velocity.y += stats.gravity * delta
		if get_jump() and stats.jumps >= 1:
			stats.jumps -= 1
			return jump_state

	elif player.is_on_floor():
		stats.jumps = stats.max_jumps
		return idle_state
	if player.velocity.y >= 0:
		return fall_state
	return null
