extends State

@export var idle_state: State
@export var fall_state: State
@export var jump_state: State
@export var grounddash_state: State

func enter(is_loading: bool = false) -> void:
	player.animation_controller.set_animation_speed(abs(player.animation_controller.current_anim_speed))
	player.animation_controller.play_animation("walk")

func process_physics(delta: float):
	if not player.is_on_floor():
		player.velocity.y += stats.gravity * delta
		
		if player.velocity.y >= 0:
			return fall_state
			
	var direction := get_movement_input()
	if direction == 0:
		return idle_state
		
	player.velocity.x = direction * stats.base_move_speed
	if get_jump() and player.is_on_floor():
		return jump_state

	if player.is_on_floor() and get_ground_dash() != 0:
		print("gdash move")
		return grounddash_state
	
	return null
