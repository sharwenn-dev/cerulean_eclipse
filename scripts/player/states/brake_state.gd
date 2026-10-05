extends State

@export var idle_state: State
@export var jump_state: State
@export var fall_state: State
@export var run_state: State
@export var walk_state: State
@export var grounddash_state: State

func enter(is_loading: bool = false) -> void:
	player.animation_controller.play_animation("brake")
	
func process_physics(delta: float) -> State:
	if not stats.grounded:
		player.velocity.y += stats.gravity * delta
		
		if player.velocity.y >= 0:
			return fall_state
	
	if get_jump() and player.is_on_floor():
		return jump_state

	if player.is_on_floor() and get_ground_dash() != 0:
		print("gdash brake")
		return grounddash_state
	
	var direction = get_movement_input()
	var movement_check = sign(direction) == sign(player.velocity.x)
	var deceleration = 500.0
	if direction != 0 and not movement_check:
		deceleration = 800.0
	
	player.velocity.x = move_toward(
		player.velocity.x,
		0,
		deceleration * delta
	)
	
	if movement_check and abs(abs(player.velocity.x) - stats.run_move_speed) <= 5:
		return run_state
	if direction != 0 and abs(abs(player.velocity.x) - stats.base_move_speed) <= 5:
		return walk_state
	if abs(player.velocity.x) < 5:
		return idle_state
	return null
