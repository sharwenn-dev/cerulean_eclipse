extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

@export var falling_state: State
@export var idle_state: State
@export var run_state: State
@export var walk_state: State
@export var brake_state: State
@export var flight_state: State

var direction: Vector2

func enter(is_loading: bool = false) -> void:
	if not is_loading:
		direction = get_air_dash()
		move_component.clear_air_dash()
		stats.current_start_frame = MatchManager.current_frame
		if direction != Vector2.ZERO:
			var dash_dir = direction.normalized()
			var final_velocity = dash_dir * stats.dash_force
			var aligned_speed = player.velocity.dot(dash_dir)
			if aligned_speed > 0:
				final_velocity += dash_dir * (aligned_speed * 0.5)
			player.velocity = final_velocity
		
		var flip = direction.x < 0
		player.animation_controller.body_sprite.flip_h = flip
	player.animation_controller.play_animation("dash") if not stats.flying else \
	player.animation_controller.play_animation("flydash")
	movement_locked = true

func process_physics(_delta: float) -> State:
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
	
	if get_flight():
		stats.flying = false
	
	if MatchManager.current_frame - stats.current_start_frame >= 30:
		return falling_state if not stats.flying else flight_state
		
	return null
