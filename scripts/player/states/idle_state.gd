extends State

@export var walk_state: State
@export var fall_state: State
@export var jump_state: State
@export var grounddash_state: State

func enter(is_loading: bool = false) -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	player.velocity.x = 0.0
	player.animation_controller.play_animation("idle")

func process_physics(delta: float) -> State:
	if not stats.grounded:
		player.velocity.y += stats.gravity * delta
		if player.velocity.y >= 0:
			return fall_state
	var direction := get_movement_input()
	if direction != 0:
		return walk_state
	if get_jump():
		return jump_state
	if get_ground_dash() != 0:
		print("gdash idle")
		return grounddash_state
	return null
