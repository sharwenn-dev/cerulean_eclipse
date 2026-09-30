extends State

# this state has movement_locked = true, meaning sprite should not flip if inputs are made during animation
# movement_locked also just means no movement control for the duration of the state besides enter

@export var idle_state: State
@export var move_state: State
@export var jump_state: State

var start_frame: int
var direction: int

func enter(is_loading: bool = false) -> void:
	if not is_loading:
		direction = get_movement_input()
		start_frame = MatchManager.current_frame
		print(start_frame)
		if direction != 0:
			player.velocity.x = stats.dash_force * direction
	if direction > 0:
		player.animation_controller.body_sprite.flip_h = false
	elif direction < 0:
		player.animation_controller.body_sprite.flip_h = true
	player.animation_controller.play_animation("dash")
	movement_locked = true

func process_physics(_delta: float) -> State:
	if MatchManager.current_frame - start_frame >= 5:
		if get_jump():
			return jump_state
	if MatchManager.current_frame - start_frame >= 30:
		return idle_state
	
	return null
