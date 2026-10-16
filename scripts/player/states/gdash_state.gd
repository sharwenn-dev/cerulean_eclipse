extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

@export var idle_state: State
@export var move_state: State
@export var run_state: State
@export var jump_state: State

var direction: int

func enter(is_loading: bool = false) -> void:
	if not is_loading:
		direction = get_movement_input()
		stats.current_start_frame = MatchManager.current_frame
		if direction != 0:
			var base_dash = direction * stats.dash_force
			var current_x_speed = player.velocity.x
			if sign(current_x_speed) == direction and abs(current_x_speed) > stats.run_move_speed:
				player.velocity.x = base_dash + (current_x_speed * 0.4) # 40% carryover
			else:
				player.velocity.x = base_dash
		var flip = direction < 0
		player.animation_controller.body_sprite.flip_h = flip
	player.animation_controller.play_animation("dash")
	movement_locked = true

func process_physics(_delta: float) -> State:
	if MatchManager.current_frame - stats.current_start_frame >= 5:
		if get_jump():
			return jump_state
	if MatchManager.current_frame - stats.current_start_frame >= 30:
		direction = get_movement_input()
		if direction * player.velocity.x > 0:
			return run_state
		return idle_state
	return null
