extends State

@export var idle_state: State
@export var walk_state: State
@export var jump_state: State

func enter(is_loading: bool = false) -> void:
	clear_dash_state()
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))

	player.animation_controller.play_animation("fall")

func process_physics(delta: float) -> State:
	player.velocity.y += stats.gravity * delta

	if get_jump() and stats.jumps >= 1:
		stats.jumps -= 1
		return jump_state

	if stats.grounded:
		stats.jumps = stats.max_jumps

		if player.velocity.x != 0:
			return walk_state
		else:
			return idle_state

	return null
